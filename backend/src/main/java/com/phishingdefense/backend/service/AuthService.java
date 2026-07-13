package com.phishingdefense.backend.service;

import com.phishingdefense.backend.client.GoogleOAuthClient;
import com.phishingdefense.backend.dto.auth.AuthResponse;
import com.phishingdefense.backend.dto.auth.GoogleLoginRequest;
import com.phishingdefense.backend.dto.auth.GoogleTokenResponse;
import com.phishingdefense.backend.dto.auth.GoogleUserInfoResponse;
import com.phishingdefense.backend.dto.auth.LoginRequest;
import com.phishingdefense.backend.dto.auth.RefreshTokenRequest;
import com.phishingdefense.backend.dto.auth.SignupRequest;
import com.phishingdefense.backend.entity.RefreshToken;
import com.phishingdefense.backend.entity.User;
import com.phishingdefense.backend.exception.DuplicateEmailException;
import com.phishingdefense.backend.exception.DuplicateNicknameException;
import com.phishingdefense.backend.exception.GoogleLoginFailedException;
import com.phishingdefense.backend.exception.InvalidCredentialsException;
import com.phishingdefense.backend.exception.InvalidRefreshTokenException;
import com.phishingdefense.backend.repository.RefreshTokenRepository;
import com.phishingdefense.backend.repository.UserRepository;
import com.phishingdefense.backend.security.JwtTokenProvider;
import java.time.LocalDateTime;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AuthService {

    private static final String GOOGLE_PROVIDER = "google";

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final GoogleOAuthClient googleOAuthClient;

    @Transactional
    public AuthResponse signup(SignupRequest request) {
        if (userRepository.existsByEmail(request.email())) {
            throw new DuplicateEmailException(request.email());
        }
        if (userRepository.existsByNickname(request.nickname())) {
            throw new DuplicateNicknameException(request.nickname());
        }

        User user = User.createLocalUser(
                request.email(),
                passwordEncoder.encode(request.password()),
                request.nickname()
        );
        User saved = userRepository.save(user);

        return issueToken(saved);
    }

    @Transactional
    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.email())
                .orElseThrow(InvalidCredentialsException::new);

        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new InvalidCredentialsException();
        }

        user.recordLogin();

        return issueToken(user);
    }

    @Transactional
    public AuthResponse loginWithGoogle(GoogleLoginRequest request) {
        GoogleTokenResponse token = googleOAuthClient.exchangeCode(request.code());
        if (!StringUtils.hasText(token.accessToken())) {
            throw new GoogleLoginFailedException("Google로부터 access token을 받지 못했습니다.", null);
        }

        GoogleUserInfoResponse userInfo = googleOAuthClient.fetchUserInfo(token.accessToken());

        User user = userRepository.findByProviderAndProviderId(GOOGLE_PROVIDER, userInfo.sub())
                .orElseGet(() -> registerOrLinkGoogleUser(userInfo));

        user.recordLogin();

        return issueToken(user);
    }

    private User registerOrLinkGoogleUser(GoogleUserInfoResponse userInfo) {
        return userRepository.findByEmail(userInfo.email())
                .map(existing -> {
                    existing.linkSocialAccount(GOOGLE_PROVIDER, userInfo.sub());
                    return existing;
                })
                .orElseGet(() -> userRepository.save(User.createSocialUser(
                        userInfo.email(),
                        generateUniqueNickname(userInfo),
                        GOOGLE_PROVIDER,
                        userInfo.sub(),
                        passwordEncoder.encode(UUID.randomUUID().toString())
                )));
    }

    private String generateUniqueNickname(GoogleUserInfoResponse userInfo) {
        String base = StringUtils.hasText(userInfo.name()) ? userInfo.name() : userInfo.email().split("@")[0];
        String candidate = base;
        int suffix = 1;
        while (userRepository.existsByNickname(candidate)) {
            candidate = base + suffix++;
        }
        return candidate;
    }

    @Transactional
    public AuthResponse refresh(RefreshTokenRequest request) {
        RefreshToken stored = refreshTokenRepository.findByToken(request.refreshToken())
                .orElseThrow(InvalidRefreshTokenException::new);

        if (stored.isExpired()) {
            refreshTokenRepository.delete(stored);
            throw new InvalidRefreshTokenException();
        }

        User user = userRepository.findById(stored.getUserId())
                .orElseThrow(InvalidRefreshTokenException::new);

        refreshTokenRepository.delete(stored);

        return issueToken(user);
    }

    private AuthResponse issueToken(User user) {
        String accessToken = jwtTokenProvider.generateToken(user.getUserId(), user.getEmail());
        String refreshToken = jwtTokenProvider.generateRefreshToken();
        LocalDateTime refreshExpiresAt = LocalDateTime.now()
                .plusSeconds(jwtTokenProvider.getRefreshExpirationMillis() / 1000);

        refreshTokenRepository.save(RefreshToken.issue(user.getUserId(), refreshToken, refreshExpiresAt));

        return AuthResponse.of(
                accessToken,
                refreshToken,
                jwtTokenProvider.getExpirationMillis(),
                user.getUserId(),
                user.getEmail(),
                user.getNickname(),
                user.getLevel()
        );
    }
}
