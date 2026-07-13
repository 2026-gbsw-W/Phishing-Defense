package com.phishingdefense.backend.service;

import com.phishingdefense.backend.dto.auth.AuthResponse;
import com.phishingdefense.backend.dto.auth.LoginRequest;
import com.phishingdefense.backend.dto.auth.RefreshTokenRequest;
import com.phishingdefense.backend.dto.auth.SignupRequest;
import com.phishingdefense.backend.entity.RefreshToken;
import com.phishingdefense.backend.entity.User;
import com.phishingdefense.backend.exception.DuplicateEmailException;
import com.phishingdefense.backend.exception.DuplicateNicknameException;
import com.phishingdefense.backend.exception.InvalidCredentialsException;
import com.phishingdefense.backend.exception.InvalidRefreshTokenException;
import com.phishingdefense.backend.repository.RefreshTokenRepository;
import com.phishingdefense.backend.repository.UserRepository;
import com.phishingdefense.backend.security.JwtTokenProvider;
import java.time.LocalDateTime;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AuthService {

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

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
