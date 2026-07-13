package com.phishingdefense.backend.exception;

public class MissingCurrentPasswordException extends RuntimeException {

    public MissingCurrentPasswordException() {
        super("비밀번호를 변경하려면 현재 비밀번호를 입력해야 합니다.");
    }
}
