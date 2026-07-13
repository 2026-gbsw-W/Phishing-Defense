package com.phishingdefense.backend.service;

import com.phishingdefense.backend.dto.user.UserAchievementStatusResponse;
import com.phishingdefense.backend.dto.user.UserInventoryResponse;
import com.phishingdefense.backend.dto.user.UserProfileResponse;
import com.phishingdefense.backend.dto.user.UserStatisticsResponse;
import com.phishingdefense.backend.dto.user.UserUpdateRequest;
import com.phishingdefense.backend.entity.Achievement;
import com.phishingdefense.backend.entity.ScenarioRecord;
import com.phishingdefense.backend.entity.Stage;
import com.phishingdefense.backend.entity.User;
import com.phishingdefense.backend.entity.UserAchievement;
import com.phishingdefense.backend.exception.DuplicateNicknameException;
import com.phishingdefense.backend.exception.InvalidCurrentPasswordException;
import com.phishingdefense.backend.exception.MissingCurrentPasswordException;
import com.phishingdefense.backend.exception.ProfileImageNotFoundException;
import com.phishingdefense.backend.exception.UserNotFoundException;
import com.phishingdefense.backend.repository.AchievementRepository;
import com.phishingdefense.backend.repository.ScenarioRecordRepository;
import com.phishingdefense.backend.repository.StageRepository;
import com.phishingdefense.backend.repository.UserAchievementRepository;
import com.phishingdefense.backend.repository.UserRepository;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {

    private static final String UNKNOWN_PHISHING_TYPE = "unknown";

    private final UserRepository userRepository;
    private final ScenarioRecordRepository scenarioRecordRepository;
    private final StageRepository stageRepository;
    private final AchievementRepository achievementRepository;
    private final UserAchievementRepository userAchievementRepository;
    private final PasswordEncoder passwordEncoder;
    private final FileStorageService fileStorageService;

    public UserProfileResponse getProfile(Long userId) {
        return UserProfileResponse.from(getUserOrThrow(userId));
    }

    @Transactional
    public UserProfileResponse updateProfile(Long userId, UserUpdateRequest request) {
        User user = getUserOrThrow(userId);

        if (StringUtils.hasText(request.nickname()) && !request.nickname().equals(user.getNickname())) {
            if (userRepository.existsByNickname(request.nickname())) {
                throw new DuplicateNicknameException(request.nickname());
            }
            user.changeNickname(request.nickname());
        }

        if (request.bio() != null) {
            user.changeBio(request.bio());
        }

        if (StringUtils.hasText(request.newPassword())) {
            if (!StringUtils.hasText(request.currentPassword())) {
                throw new MissingCurrentPasswordException();
            }
            if (!passwordEncoder.matches(request.currentPassword(), user.getPasswordHash())) {
                throw new InvalidCurrentPasswordException();
            }
            user.changePasswordHash(passwordEncoder.encode(request.newPassword()));
        }

        return UserProfileResponse.from(user);
    }

    @Transactional
    public UserProfileResponse updateProfileImage(Long userId, MultipartFile file) {
        User user = getUserOrThrow(userId);

        String oldImageUrl = user.getProfileImageUrl();
        String newImageUrl = fileStorageService.storeProfileImage(userId, file);
        user.changeProfileImageUrl(newImageUrl);

        fileStorageService.deleteProfileImageIfExists(oldImageUrl);

        return UserProfileResponse.from(user);
    }

    public FileStorageService.StoredImage getProfileImage(Long userId) {
        User user = getUserOrThrow(userId);
        if (!StringUtils.hasText(user.getProfileImageUrl())) {
            throw new ProfileImageNotFoundException();
        }
        return fileStorageService.loadProfileImage(user.getProfileImageUrl());
    }

    public UserStatisticsResponse getStatistics(Long userId) {
        List<ScenarioRecord> records = scenarioRecordRepository.findByUserIdOrderByCreatedAtDesc(userId);

        Set<Long> scenarioIds = records.stream().map(ScenarioRecord::getScenarioId).collect(Collectors.toSet());
        Map<Long, String> phishingTypeByScenario = stageRepository.findAllById(scenarioIds).stream()
                .collect(Collectors.toMap(Stage::getStageId,
                        stage -> StringUtils.hasText(stage.getPhishingType()) ? stage.getPhishingType() : UNKNOWN_PHISHING_TYPE));

        List<ScenarioRecord> completed = records.stream()
                .filter(record -> Boolean.TRUE.equals(record.getCompleted()))
                .toList();

        long totalPlays = completed.size();
        double averageStar = completed.stream()
                .mapToInt(record -> record.getStarRating() == null ? 0 : record.getStarRating())
                .average()
                .orElse(0.0);

        Map<String, List<ScenarioRecord>> judgedByType = records.stream()
                .filter(record -> record.getCorrectJudgment() != null)
                .collect(Collectors.groupingBy(record ->
                        phishingTypeByScenario.getOrDefault(record.getScenarioId(), UNKNOWN_PHISHING_TYPE)));

        Map<String, Double> accuracyByType = judgedByType.entrySet().stream()
                .collect(Collectors.toMap(Map.Entry::getKey, entry -> {
                    long correct = entry.getValue().stream()
                            .filter(record -> Boolean.TRUE.equals(record.getCorrectJudgment()))
                            .count();
                    return Math.round((double) correct / entry.getValue().size() * 100) / 100.0;
                }));

        Map<String, Integer> hintsByType = records.stream()
                .collect(Collectors.groupingBy(
                        record -> phishingTypeByScenario.getOrDefault(record.getScenarioId(), UNKNOWN_PHISHING_TYPE),
                        Collectors.summingInt(record -> record.getHintsUsed() == null ? 0 : record.getHintsUsed())));

        String mostUsedHintType = hintsByType.entrySet().stream()
                .filter(entry -> entry.getValue() > 0)
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse(null);

        return new UserStatisticsResponse(
                totalPlays,
                Math.round(averageStar * 100) / 100.0,
                accuracyByType,
                mostUsedHintType
        );
    }

    public List<UserAchievementStatusResponse> getAchievements(Long userId) {
        List<Achievement> achievements = achievementRepository.findAllByOrderByAchievementIdAsc();
        Map<Integer, UserAchievement> unlockedByAchievementId = userAchievementRepository.findByUserId(userId).stream()
                .collect(Collectors.toMap(UserAchievement::getAchievementId, ua -> ua));

        return achievements.stream()
                .map(achievement -> {
                    UserAchievement unlocked = unlockedByAchievementId.get(achievement.getAchievementId());
                    return new UserAchievementStatusResponse(
                            achievement.getAchievementId(),
                            achievement.getName(),
                            achievement.getDescription(),
                            achievement.getIconUrl(),
                            unlocked != null,
                            unlocked != null ? unlocked.getUnlockedAt() : null
                    );
                })
                .toList();
    }

    public UserInventoryResponse getInventory(Long userId) {
        User user = getUserOrThrow(userId);
        return new UserInventoryResponse(user.getCoins(), user.getHints(), List.of());
    }

    private User getUserOrThrow(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException(userId));
    }
}
