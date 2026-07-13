package com.phishingdefense.backend.service;

import com.phishingdefense.backend.dto.game.DailyMissionResponse;
import com.phishingdefense.backend.dto.game.MissionCompleteRequest;
import com.phishingdefense.backend.dto.game.MissionCompleteResponse;
import com.phishingdefense.backend.entity.DailyMission;
import com.phishingdefense.backend.entity.ScenarioRecord;
import com.phishingdefense.backend.entity.Stage;
import com.phishingdefense.backend.entity.User;
import com.phishingdefense.backend.exception.DailyMissionAccessDeniedException;
import com.phishingdefense.backend.exception.DailyMissionAlreadyCompletedException;
import com.phishingdefense.backend.exception.DailyMissionNotFoundException;
import com.phishingdefense.backend.exception.ScenarioRecordAccessDeniedException;
import com.phishingdefense.backend.exception.ScenarioRecordNotCompletedException;
import com.phishingdefense.backend.exception.ScenarioRecordNotFoundException;
import com.phishingdefense.backend.exception.UserNotFoundException;
import com.phishingdefense.backend.repository.DailyMissionRepository;
import com.phishingdefense.backend.repository.ScenarioRecordRepository;
import com.phishingdefense.backend.repository.StageRepository;
import com.phishingdefense.backend.repository.UserRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MissionService {

    private static final String UNKNOWN_PHISHING_TYPE = "unknown";
    private static final int FIXED_MISSION_REWARD_XP = 100;
    private static final int DYNAMIC_MISSION_REWARD_XP = 100;
    private static final int BONUS_MISSION_REWARD_XP = 200;

    private final DailyMissionRepository dailyMissionRepository;
    private final ScenarioRecordRepository scenarioRecordRepository;
    private final StageRepository stageRepository;
    private final UserRepository userRepository;

    @Transactional
    public List<DailyMissionResponse> getDailyMissions(Long userId) {
        LocalDate today = LocalDate.now();
        List<DailyMission> missions = dailyMissionRepository.findByUserIdAndCreatedDate(userId, today);

        if (missions.isEmpty()) {
            missions = dailyMissionRepository.saveAll(generateDailyMissions(userId, today));
        }

        return missions.stream().map(DailyMissionResponse::from).toList();
    }

    @Transactional
    public MissionCompleteResponse completeMission(Long userId, Long missionId, MissionCompleteRequest request) {
        DailyMission mission = dailyMissionRepository.findById(missionId)
                .orElseThrow(() -> new DailyMissionNotFoundException(missionId));

        if (!mission.isOwnedBy(userId)) {
            throw new DailyMissionAccessDeniedException();
        }
        if (Boolean.TRUE.equals(mission.getCompleted())) {
            throw new DailyMissionAlreadyCompletedException();
        }

        ScenarioRecord record = scenarioRecordRepository.findById(request.recordId())
                .orElseThrow(() -> new ScenarioRecordNotFoundException(request.recordId()));
        if (!record.isOwnedBy(userId)) {
            throw new ScenarioRecordAccessDeniedException();
        }
        if (!Boolean.TRUE.equals(record.getCompleted())) {
            throw new ScenarioRecordNotCompletedException(request.recordId());
        }

        mission.complete();

        User user = userRepository.findById(userId).orElseThrow(() -> new UserNotFoundException(userId));
        user.addXp(mission.getRewardXp());

        return new MissionCompleteResponse(true, mission.getRewardXp());
    }

    private List<DailyMission> generateDailyMissions(Long userId, LocalDate today) {
        String weakestType = findWeakestPhishingType(userId);

        DailyMission fixed = DailyMission.create(
                userId, DailyMission.TYPE_FIXED, "일일 1스테이지 클리어", null, FIXED_MISSION_REWARD_XP, today);

        DailyMission dynamic = DailyMission.create(
                userId, DailyMission.TYPE_DYNAMIC,
                (weakestType != null ? weakestType : "새로운") + " 시나리오 도전!",
                weakestType != null ? "취약 유형: " + weakestType : null,
                DYNAMIC_MISSION_REWARD_XP, today);

        DailyMission bonus = DailyMission.create(
                userId, DailyMission.TYPE_BONUS, "고난도 시나리오 무사고 클리어", null, BONUS_MISSION_REWARD_XP, today);

        return List.of(fixed, dynamic, bonus);
    }

    private String findWeakestPhishingType(Long userId) {
        List<ScenarioRecord> records = scenarioRecordRepository.findByUserIdOrderByCreatedAtDesc(userId);

        Set<Long> scenarioIds = records.stream().map(ScenarioRecord::getScenarioId).collect(Collectors.toSet());
        Map<Long, String> phishingTypeByScenario = stageRepository.findAllById(scenarioIds).stream()
                .collect(Collectors.toMap(Stage::getStageId,
                        stage -> StringUtils.hasText(stage.getPhishingType()) ? stage.getPhishingType() : UNKNOWN_PHISHING_TYPE));

        Map<String, List<ScenarioRecord>> judgedByType = records.stream()
                .filter(record -> record.getCorrectJudgment() != null)
                .collect(Collectors.groupingBy(record ->
                        phishingTypeByScenario.getOrDefault(record.getScenarioId(), UNKNOWN_PHISHING_TYPE)));

        return judgedByType.entrySet().stream()
                .map(entry -> {
                    long correct = entry.getValue().stream()
                            .filter(record -> Boolean.TRUE.equals(record.getCorrectJudgment()))
                            .count();
                    double accuracy = (double) correct / entry.getValue().size();
                    return Map.entry(entry.getKey(), accuracy);
                })
                .min(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse(null);
    }
}
