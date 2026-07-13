package com.phishingdefense.backend.exception;

public class AiServerCommunicationException extends RuntimeException {

    public AiServerCommunicationException(String message, Throwable cause) {
        super(message, cause);
    }
}
