package com.phishingdefense.backend.exception;

public class ProfileImageNotFoundException extends RuntimeException {

    public ProfileImageNotFoundException() {
        super("등록된 프로필 이미지가 없습니다.");
    }
}
