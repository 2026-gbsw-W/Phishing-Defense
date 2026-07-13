package com.phishingdefense.backend.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record SignupRequest(
        @NotBlank @Email String email,
        @NotBlank @Size(min = 8, max = 100) String password,
        @NotBlank @Size(min = 2, max = 50)
        @Pattern(regexp = "^[a-zA-Z0-9가-힣_-]+$", message = "닉네임은 한글/영문/숫자/_/-만 사용할 수 있습니다.")
        String nickname
) {
}
