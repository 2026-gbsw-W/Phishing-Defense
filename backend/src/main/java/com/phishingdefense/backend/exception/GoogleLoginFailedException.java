package com.phishingdefense.backend.exception;

public class GoogleLoginFailedException extends RuntimeException {

    public GoogleLoginFailedException(String message, Throwable cause) {
        super(message, cause);
    }
}
