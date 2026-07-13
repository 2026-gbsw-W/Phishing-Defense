package com.phishingdefense.backend.service;

import java.util.List;

/**
 * {@code scenarios.required_evidence} JSON 컬럼의 항목 하나를 나타낸다.
 * 예: {"type":"url_click","value":"출처가 불분명한 링크 클릭 유도","keywords":["링크","클릭"],"importance":3}
 */
public record RequiredEvidenceEntry(
        String type,
        String value,
        List<String> keywords,
        Integer importance
) {
}
