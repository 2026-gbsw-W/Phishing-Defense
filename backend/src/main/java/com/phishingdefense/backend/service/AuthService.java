package com.phishingdefense.backend.service;

import com.phishingdefense.backend.dto.auth.AuthResponse;
import com.phishingdefense.backend.dto.auth.LoginRequest;
import com.phishingdefense.backend.dto.auth.SignupRequest;
import com.phishingdefense.backend.entity.User;
import com.phishingdefense.backend.exception.DuplicateEmailException;
import com.phishingdefense.backend.exception.DuplicateNicknameException;
import com.phishingdefense.backend.exception.InvalidCredentialsException;
import com.phishingdefense.backend.repository.UserRepository;
import com.phishingdefense.backend.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AuthService {

    private final UserRepository userRepository;
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

    private AuthResponse issueToken(User user) {
        String token = jwtTokenProvider.generateToken(user.getUserId(), user.getEmail());
        return AuthResponse.of(
                token,
                jwtTokenProvider.getExpirationMillis(),
                user.getUserId(),
                user.getEmail(),
                user.getNickname(),
                user.getLevel()
        );
    }
}
