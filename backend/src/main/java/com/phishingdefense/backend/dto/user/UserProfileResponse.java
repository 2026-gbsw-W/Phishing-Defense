package com.phishingdefense.backend.dto.user;

import com.phishingdefense.backend.entity.User;

public record UserProfileResponse(
        Long userId,
        String email,
        String nickname,
        String bio,
        String profileImageUrl,
        Integer level,
        Integer currentXp,
        Integer totalXp
) {
    public static UserProfileResponse from(User user) {
        return new UserProfileResponse(
                user.getUserId(),
                user.getEmail(),
                user.getNickname(),
                user.getBio(),
                user.getProfileImageUrl(),
                user.getLevel(),
                user.getCurrentXp(),
                user.getTotalXp()
        );
    }
}
