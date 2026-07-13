package com.phishingdefense.backend.exception;

public class ChapterNotFoundException extends RuntimeException {

    public ChapterNotFoundException(Integer chapterId) {
        super("챕터를 찾을 수 없습니다: " + chapterId);
    }
}
