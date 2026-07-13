package com.phishingdefense.backend.dto.auth;

public record AuthResponse(
        String accessToken,
        String refreshToken,
        String tokenType,
        long expiresIn,
        Long userId,
        String email,
        String nickname,
        Integer level
) {
    public static AuthResponse of(String accessToken, String refreshToken, long expiresIn, Long userId,
                                   String email, String nickname, Integer level) {
        return new AuthResponse(accessToken, refreshToken, "Bearer", expiresIn, userId, email, nickname, level);
    }
}
