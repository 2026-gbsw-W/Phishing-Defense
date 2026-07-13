package com.phishingdefense.backend.service;

import com.phishingdefense.backend.dto.user.UserProfileResponse;
import com.phishingdefense.backend.dto.user.UserUpdateRequest;
import com.phishingdefense.backend.entity.User;
import com.phishingdefense.backend.exception.DuplicateNicknameException;
import com.phishingdefense.backend.exception.InvalidCurrentPasswordException;
import com.phishingdefense.backend.exception.MissingCurrentPasswordException;
import com.phishingdefense.backend.exception.ProfileImageNotFoundException;
import com.phishingdefense.backend.exception.UserNotFoundException;
import com.phishingdefense.backend.repository.UserRepository;
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

    private final UserRepository userRepository;
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

    private User getUserOrThrow(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException(userId));
    }
}
