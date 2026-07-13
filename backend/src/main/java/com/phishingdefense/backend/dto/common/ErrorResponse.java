package com.phishingdefense.backend.dto.common;

import java.time.LocalDateTime;
import java.util.List;

public record ErrorResponse(
        LocalDateTime timestamp,
        int status,
        String code,
        String message,
        List<FieldError> fieldErrors
) {
    public record FieldError(String field, String reason) {
    }

    public static ErrorResponse of(int status, String code, String message) {
        return new ErrorResponse(LocalDateTime.now(), status, code, message, List.of());
    }

    public static ErrorResponse of(int status, String code, String message, List<FieldError> fieldErrors) {
        return new ErrorResponse(LocalDateTime.now(), status, code, message, fieldErrors);
    }
}
