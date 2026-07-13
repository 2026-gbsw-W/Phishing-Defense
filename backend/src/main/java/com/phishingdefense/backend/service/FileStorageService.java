package com.phishingdefense.backend.service;

import com.phishingdefense.backend.exception.FileStorageException;
import com.phishingdefense.backend.exception.InvalidFileException;
import com.phishingdefense.backend.exception.ProfileImageNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

@Service
public class FileStorageService {

    private static final Set<String> ALLOWED_CONTENT_TYPES = Set.of("image/jpeg", "image/png", "image/webp");
    private static final String PROFILE_IMAGE_URL_PREFIX = "/images/profile/";
    private static final Map<String, MediaType> MEDIA_TYPE_BY_EXTENSION = Map.of(
            ".png", MediaType.IMAGE_PNG,
            ".jpg", MediaType.IMAGE_JPEG,
            ".jpeg", MediaType.IMAGE_JPEG,
            ".webp", MediaType.valueOf("image/webp")
    );

    public record StoredImage(byte[] content, MediaType mediaType) {
    }

    private final Path profileImageDir;
    private final long maxFileSizeBytes;

    public FileStorageService(
            @Value("${file.profile-image.upload-dir}") String uploadDir,
            @Value("${file.profile-image.max-size-bytes}") long maxFileSizeBytes
    ) {
        this.profileImageDir = Path.of(uploadDir).toAbsolutePath().normalize();
        this.maxFileSizeBytes = maxFileSizeBytes;
        try {
            Files.createDirectories(this.profileImageDir);
        } catch (IOException e) {
            throw new FileStorageException("업로드 디렉토리를 생성할 수 없습니다.", e);
        }
    }

    public String storeProfileImage(Long userId, MultipartFile file) {
        validate(file);

        String extension = extractExtension(file.getOriginalFilename());
        String filename = userId + "_" + UUID.randomUUID() + extension;
        Path target = profileImageDir.resolve(filename).normalize();

        if (!target.getParent().equals(profileImageDir)) {
            throw new InvalidFileException("올바르지 않은 파일 이름입니다.");
        }

        try {
            file.transferTo(target);
        } catch (IOException e) {
            throw new FileStorageException("파일을 저장하는 중 오류가 발생했습니다.", e);
        }

        return PROFILE_IMAGE_URL_PREFIX + filename;
    }

    public StoredImage loadProfileImage(String imageUrl) {
        if (!StringUtils.hasText(imageUrl) || !imageUrl.startsWith(PROFILE_IMAGE_URL_PREFIX)) {
            throw new ProfileImageNotFoundException();
        }
        String filename = imageUrl.substring(PROFILE_IMAGE_URL_PREFIX.length());
        Path target = profileImageDir.resolve(filename).normalize();
        if (!target.getParent().equals(profileImageDir) || !Files.isRegularFile(target)) {
            throw new ProfileImageNotFoundException();
        }

        try {
            byte[] content = Files.readAllBytes(target);
            return new StoredImage(content, resolveMediaType(filename));
        } catch (IOException e) {
            throw new FileStorageException("파일을 읽는 중 오류가 발생했습니다.", e);
        }
    }

    private MediaType resolveMediaType(String filename) {
        String extension = extractExtension(filename).toLowerCase(Locale.ROOT);
        return MEDIA_TYPE_BY_EXTENSION.getOrDefault(extension, MediaType.APPLICATION_OCTET_STREAM);
    }

    public void deleteProfileImageIfExists(String imageUrl) {
        if (!StringUtils.hasText(imageUrl) || !imageUrl.startsWith(PROFILE_IMAGE_URL_PREFIX)) {
            return;
        }
        String filename = imageUrl.substring(PROFILE_IMAGE_URL_PREFIX.length());
        Path target = profileImageDir.resolve(filename).normalize();
        if (!target.getParent().equals(profileImageDir)) {
            return;
        }
        try {
            Files.deleteIfExists(target);
        } catch (IOException e) {
            // 기존 파일 삭제 실패는 치명적이지 않으므로 무시한다.
        }
    }

    private void validate(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new InvalidFileException("업로드할 파일이 비어 있습니다.");
        }
        if (file.getSize() > maxFileSizeBytes) {
            throw new InvalidFileException("파일 크기는 " + (maxFileSizeBytes / (1024 * 1024)) + "MB를 초과할 수 없습니다.");
        }
        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_CONTENT_TYPES.contains(contentType.toLowerCase())) {
            throw new InvalidFileException("이미지 파일(JPEG, PNG, WEBP)만 업로드할 수 있습니다.");
        }
    }

    private String extractExtension(String originalFilename) {
        if (!StringUtils.hasText(originalFilename) || !originalFilename.contains(".")) {
            return "";
        }
        String ext = originalFilename.substring(originalFilename.lastIndexOf('.'));
        return ext.replaceAll("[^a-zA-Z0-9.]", "");
    }
}
