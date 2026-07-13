package com.phishingdefense.backend.service;

import com.phishingdefense.backend.client.AiClient;
import com.phishingdefense.backend.client.AiScenarioTypeMapper;
import com.phishingdefense.backend.dto.game.AiRiskAnalysisResponse;
import com.phishingdefense.backend.dto.game.EvidenceAnalysisResponse;
import com.phishingdefense.backend.dto.game.EvidenceConfirmRequest;
import com.phishingdefense.backend.dto.game.EvidenceConfirmResponse;
import com.phishingdefense.backend.dto.game.EvidenceItemResponse;
import com.phishingdefense.backend.dto.game.JudgmentRequest;
import com.phishingdefense.backend.dto.game.JudgmentResponse;
import com.phishingdefense.backend.dto.game.ReportClaimResponse;
import com.phishingdefense.backend.dto.game.ScenarioReportResponse;
import com.phishingdefense.backend.dto.game.ScenarioStartResponse;
import com.phishingdefense.backend.dto.game.ScenarioStatusResponse;
import com.phishingdefense.backend.dto.training.AiChatMessageResponse;
import com.phishingdefense.backend.entity.ChatHistory;
import com.phishingdefense.backend.entity.Evidence;
import com.phishingdefense.backend.entity.ScenarioRecord;
import com.phishingdefense.backend.entity.Stage;
import com.phishingdefense.backend.entity.TrainingResult;
import com.phishingdefense.backend.entity.TrainingSession;
import com.phishingdefense.backend.entity.User;
import com.phishingdefense.backend.exception.ReportAlreadyClaimedException;
import com.phishingdefense.backend.exception.ScenarioRecordAccessDeniedException;
import com.phishingdefense.backend.exception.ScenarioRecordAlreadyCompletedException;
import com.phishingdefense.backend.exception.ScenarioRecordNotCompletedException;
import com.phishingdefense.backend.exception.ScenarioRecordNotFoundException;
import com.phishingdefense.backend.exception.StageNotFoundException;
import com.phishingdefense.backend.exception.UserNotFoundException;
import com.phishingdefense.backend.repository.ChatHistoryRepository;
import com.phishingdefense.backend.repository.EvidenceRepository;
import com.phishingdefense.backend.repository.ScenarioRecordRepository;
import com.phishingdefense.backend.repository.StageRepository;
import com.phishingdefense.backend.repository.TrainingResultRepository;
import com.phishingdefense.backend.repository.TrainingSessionRepository;
import com.phishingdefense.backend.repository.UserRepository;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ScenarioPlayService {

    private static final String CORRECT_JUDGMENT_FEEDBACK = "정확한 판단입니다! 다음 단계로 진행합니다.";
    private static final String INCORRECT_JUDGMENT_FEEDBACK = "다시 한번 생각해보세요.";
    private static final String SCENARIO_START_MESSAGE = "안녕하세요.";
    private static final String AI_MODEL_NAME = "ai-server";

    private static final int DEFAULT_REPORT_HANDLING_SCORE = 15;
    private static final int BASE_XP = 150;
    private static final Map<Integer, Integer> STAR_BONUS_XP = Map.of(0, 0, 1, 10, 2, 30, 3, 70);

    private final StageRepository stageRepository;
    private final ScenarioRecordRepository scenarioRecordRepository;
    private final EvidenceRepository evidenceRepository;
    private final UserRepository userRepository;
    private final EvidenceExtractor evidenceExtractor;
    private final TrainingSessionRepository trainingSessionRepository;
    private final TrainingResultRepository trainingResultRepository;
    private final ChatHistoryRepository chatHistoryRepository;
    private final AiClient aiClient;

    @Transactional
    public ScenarioStartResponse start(Long userId, Long scenarioId) {
        Stage stage = stageRepository.findById(scenarioId)
                .orElseThrow(() -> new StageNotFoundException(scenarioId));

        ScenarioRecord record = ScenarioRecord.start(userId, stage.getChapterId(), stage.getStageId());
        ScenarioRecord saved = scenarioRecordRepository.save(record);

        String scenarioType = AiScenarioTypeMapper.map(stage.getPhishingType());
        AiChatMessageResponse response = aiClient.chat(null, SCENARIO_START_MESSAGE, scenarioType);
        String openingMessage = response.answer();

        trainingSessionRepository.save(
                TrainingSession.create(response.sessionId(), userId, saved.getRecordId(), scenarioType));
        chatHistoryRepository.save(
                ChatHistory.aiMessage(saved.getRecordId(), 0, openingMessage, AI_MODEL_NAME, null));

        for (RequiredEvidenceEntry entry : evidenceExtractor.match(stage.getRequiredEvidence(), openingMessage)) {
            evidenceRepository.save(
                    Evidence.discovered(saved.getRecordId(), entry.type(), entry.value(), 0, entry.importance()));
        }

        return new ScenarioStartResponse(saved.getRecordId(), openingMessage, LocalDateTime.now());
    }

    public ScenarioStatusResponse getStatus(Long userId, Long recordId) {
        ScenarioRecord record = getOwnedRecordOrThrow(userId, recordId);
        return ScenarioStatusResponse.from(record);
    }

    @Transactional
    public JudgmentResponse judge(Long userId, Long recordId, JudgmentRequest request) {
        ScenarioRecord record = getOwnedRecordOrThrow(userId, recordId);
        if (record.isCompleted()) {
            throw new ScenarioRecordAlreadyCompletedException(recordId);
        }

        Stage stage = stageRepository.findById(record.getScenarioId())
                .orElseThrow(() -> new StageNotFoundException(record.getScenarioId()));

        boolean isCorrect = request.isPhishing().equals(stage.getPhishing());
        int stageProgression = record.recordJudgment(isCorrect);

        String feedback = isCorrect ? CORRECT_JUDGMENT_FEEDBACK : INCORRECT_JUDGMENT_FEEDBACK;
        return new JudgmentResponse(isCorrect, feedback, stageProgression);
    }

    public List<EvidenceItemResponse> getEvidence(Long userId, Long recordId) {
        getOwnedRecordOrThrow(userId, recordId);
        return evidenceRepository.findByRecordId(recordId).stream()
                .map(EvidenceItemResponse::from)
                .toList();
    }

    @Transactional
    public EvidenceConfirmResponse confirmEvidence(Long userId, Long recordId, EvidenceConfirmRequest request) {
        ScenarioRecord record = getOwnedRecordOrThrow(userId, recordId);
        if (record.isCompleted()) {
            throw new ScenarioRecordAlreadyCompletedException(recordId);
        }

        List<Evidence> allEvidence = evidenceRepository.findByRecordId(recordId);
        Set<Long> selectedIds = Set.copyOf(request.selectedEvidenceIds());

        List<Evidence> selected = allEvidence.stream()
                .filter(evidence -> selectedIds.contains(evidence.getEvidenceId()))
                .toList();
        List<Evidence> missed = allEvidence.stream()
                .filter(evidence -> !selectedIds.contains(evidence.getEvidenceId()))
                .toList();

        selected.forEach(Evidence::markSubmitted);
        record.recordEvidenceSubmission(allEvidence.size(), selected.size());

        int percentage = allEvidence.isEmpty() ? 0 : Math.round(selected.size() * 100f / allEvidence.size());

        return new EvidenceConfirmResponse(percentage, missed.stream().map(EvidenceItemResponse::from).toList());
    }

    @Transactional
    public ScenarioReportResponse getReport(Long userId, Long recordId) {
        ScenarioRecord record = getOwnedRecordOrThrow(userId, recordId);
        TrainingResult aiResult = findAiResult(recordId).orElse(null);

        if (!record.isCompleted()) {
            applyScoring(record, aiResult);
            record.markCompleted();
        }

        List<Evidence> allEvidence = evidenceRepository.findByRecordId(recordId);
        List<Evidence> missed = allEvidence.stream()
                .filter(evidence -> !Boolean.TRUE.equals(evidence.getSubmittedAtReport()))
                .toList();
        int submittedCount = allEvidence.size() - missed.size();

        EvidenceAnalysisResponse evidenceAnalysis = new EvidenceAnalysisResponse(
                submittedCount, allEvidence.size(), missed.stream().map(EvidenceItemResponse::from).toList());

        int accuracyScorePercent = record.getAccuracyScore() == null
                ? 0 : Math.round(record.getAccuracyScore() / 50f * 100);

        return new ScenarioReportResponse(
                accuracyScorePercent,
                record.getStarRating(),
                computeXpEarned(record, aiResult),
                buildFeedback(record, aiResult),
                evidenceAnalysis,
                buildRecommendations(record, aiResult),
                aiResult == null ? null : AiRiskAnalysisResponse.from(aiResult)
        );
    }

    @Transactional
    public ReportClaimResponse claimReport(Long userId, Long recordId) {
        ScenarioRecord record = getOwnedRecordOrThrow(userId, recordId);

        if (!record.isCompleted()) {
            throw new ScenarioRecordNotCompletedException(recordId);
        }
        if (record.isReported()) {
            throw new ReportAlreadyClaimedException(recordId);
        }

        TrainingResult aiResult = findAiResult(recordId).orElse(null);
        int xpEarned = computeXpEarned(record, aiResult);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException(userId));
        int levelBefore = user.getLevel();
        user.addXp(xpEarned);
        boolean levelUp = user.getLevel() > levelBefore;

        record.markReported();

        return new ReportClaimResponse(xpEarned, levelUp, user.getTotalXp());
    }

    private Optional<TrainingResult> findAiResult(Long recordId) {
        return trainingSessionRepository.findByRecordId(recordId)
                .flatMap(session -> trainingResultRepository.findById(session.getSessionId()));
    }

    private void applyScoring(ScenarioRecord record, TrainingResult aiResult) {
        int accuracyScore = computeAccuracyScore(record);
        int evidenceScore = computeEvidenceScore(record);
        int reportHandlingScore = computeReportHandlingScore(aiResult);
        int hintScore = computeHintScore(record);
        int totalScore = accuracyScore + evidenceScore + reportHandlingScore + hintScore;
        int starRating = computeStarRating(totalScore);

        record.applyScoring(accuracyScore, evidenceScore, reportHandlingScore, hintScore, totalScore, starRating);
    }

    private int computeAccuracyScore(ScenarioRecord record) {
        Boolean correct = record.getCorrectJudgment();
        if (correct == null) {
            return 0;
        }
        if (!correct) {
            return 15;
        }
        int turn = record.getJudgmentAtTurn() == null ? Integer.MAX_VALUE : record.getJudgmentAtTurn();
        if (turn <= 2) {
            return 50;
        }
        if (turn <= 4) {
            return 42;
        }
        return 35;
    }

    private int computeEvidenceScore(ScenarioRecord record) {
        Integer marked = record.getEvidenceMarkedCount();
        Integer submitted = record.getEvidenceSubmittedCount();
        if (marked == null || marked == 0) {
            return 0;
        }
        double ratio = (submitted == null ? 0 : submitted) / (double) marked;
        return Math.round((float) (ratio * 20));
    }

    /**
     * AI 분석 결과가 없으면(아직 AI 채팅을 하지 않은 경우) 기본값을 유지한다.
     * 있으면 risk_score가 낮을수록(=위험 대응을 잘했을수록), 실제로 낚이지 않았을수록 높은 점수를 준다.
     */
    private int computeReportHandlingScore(TrainingResult aiResult) {
        if (aiResult == null || aiResult.getRiskScore() == null) {
            return DEFAULT_REPORT_HANDLING_SCORE;
        }

        int riskScore = aiResult.getRiskScore();
        int score = Math.round((100 - riskScore) * DEFAULT_REPORT_HANDLING_SCORE / 100f);
        if (Boolean.TRUE.equals(aiResult.getUserFellForIt())) {
            score -= 5;
        }
        return Math.max(0, Math.min(DEFAULT_REPORT_HANDLING_SCORE, score));
    }

    private int computeHintScore(ScenarioRecord record) {
        int hints = record.getHintsUsed() == null ? 0 : record.getHintsUsed();
        if (hints == 0) {
            return 10;
        }
        if (hints == 1) {
            return 9;
        }
        if (hints == 2) {
            return 7;
        }
        if (hints == 3) {
            return 4;
        }
        return 0;
    }

    private int computeStarRating(int totalScore) {
        if (totalScore >= 90) {
            return 3;
        }
        if (totalScore >= 80) {
            return 2;
        }
        if (totalScore >= 60) {
            return 1;
        }
        return 0;
    }

    private int computeXpEarned(ScenarioRecord record, TrainingResult aiResult) {
        int starRating = record.getStarRating() == null ? 0 : record.getStarRating();
        int starBonus = STAR_BONUS_XP.getOrDefault(starRating, 0);

        int hints = record.getHintsUsed() == null ? 0 : record.getHintsUsed();
        int hintBonus = hints == 0 ? 20 : 0;
        int hintPenalty = hints > 0 ? hints * 5 : 0;

        boolean evidencePerfect = record.getEvidenceMarkedCount() != null
                && record.getEvidenceMarkedCount() > 0
                && record.getEvidenceMarkedCount().equals(record.getEvidenceSubmittedCount());
        int evidenceBonus = evidencePerfect ? 40 : 0;

        int aiFellForItPenalty = aiResult != null && Boolean.TRUE.equals(aiResult.getUserFellForIt()) ? 20 : 0;

        return Math.max(0, BASE_XP + starBonus + hintBonus + evidenceBonus - hintPenalty - aiFellForItPenalty);
    }

    private String buildFeedback(ScenarioRecord record, TrainingResult aiResult) {
        String judgment = Boolean.TRUE.equals(record.getCorrectJudgment())
                ? "정확하게 판단했습니다" : "판단이 정확하지 않았습니다";
        int hints = record.getHintsUsed() == null ? 0 : record.getHintsUsed();
        String base = String.format("%s. 힌트를 %d회 사용했습니다.", judgment, hints);

        if (aiResult == null) {
            return base + " (AI 대화 분석 결과가 없습니다. 채팅을 진행한 뒤 다시 확인해보세요.)";
        }
        return base + " " + aiResult.getGoodPoints() + " " + aiResult.getMistakes();
    }

    private List<String> buildRecommendations(ScenarioRecord record, TrainingResult aiResult) {
        List<String> recommendations = new ArrayList<>();
        if (Boolean.FALSE.equals(record.getCorrectJudgment())) {
            recommendations.add("이 유형의 시나리오를 다시 연습해보세요.");
        } else {
            recommendations.add("다음 챕터에 도전해보세요!");
        }
        if (aiResult != null && aiResult.getImprovementTips() != null) {
            recommendations.add(aiResult.getImprovementTips());
        }
        return recommendations;
    }

    private ScenarioRecord getOwnedRecordOrThrow(Long userId, Long recordId) {
        ScenarioRecord record = scenarioRecordRepository.findById(recordId)
                .orElseThrow(() -> new ScenarioRecordNotFoundException(recordId));

        if (!record.isOwnedBy(userId)) {
            throw new ScenarioRecordAccessDeniedException();
        }

        return record;
    }
}
