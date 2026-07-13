package com.phishingdefense.backend.dto.user;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record UserUpdateRequest(
        @Schema(requiredMode = Schema.RequiredMode.NOT_REQUIRED, description = "변경할 닉네임 (선택)")
        @Size(min = 2, max = 50)
        @Pattern(regexp = "^[a-zA-Z0-9가-힣_-]+$", message = "닉네임은 한글/영문/숫자/_/-만 사용할 수 있습니다.")
        String nickname,

        @Schema(requiredMode = Schema.RequiredMode.NOT_REQUIRED, description = "변경할 자기소개 (선택)")
        @Size(max = 255)
        String bio,

        @Schema(requiredMode = Schema.RequiredMode.NOT_REQUIRED, description = "현재 비밀번호 (newPassword를 보낼 때만 필수)")
        String currentPassword,

        @Schema(requiredMode = Schema.RequiredMode.NOT_REQUIRED, description = "변경할 새 비밀번호 (선택, 비밀번호를 바꾸지 않으면 생략)")
        @Size(min = 8, max = 100)
        String newPassword
) {
}
