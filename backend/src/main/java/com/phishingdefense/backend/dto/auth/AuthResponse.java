package com.phishingdefense.backend.dto.auth;

public record AuthResponse(
        String accessToken,
        String tokenType,
        long expiresIn,
        Long userId,
        String email,
        String nickname,
        Integer level
) {
    public static AuthResponse of(String accessToken, long expiresIn, Long userId, String email,
                                   String nickname, Integer level) {
        return new AuthResponse(accessToken, "Bearer", expiresIn, userId, email, nickname, level);
    }
}
