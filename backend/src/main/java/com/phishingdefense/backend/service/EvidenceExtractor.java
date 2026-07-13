package com.phishingdefense.backend.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

/**
 * AI 연동 전까지, 시나리오의 {@code required_evidence} 카탈로그에 등록된 키워드가
 * 주어진 텍스트(초기 메시지 또는 AI 응답)에 포함되어 있는지로 증거를 판정하는
 * 규칙 기반(rule-based) 추출기.
 *
 * <p>프로젝트 클래스패스에 Jackson 2/3이 혼재되어 있어 Spring이 관리하는
 * {@code ObjectMapper} 빈과 타입이 어긋날 수 있으므로, 여기서는 빈 주입 없이
 * 전용 인스턴스를 직접 생성해 사용한다.</p>
 */
@Component
@Slf4j
public class EvidenceExtractor {

    private final ObjectMapper objectMapper = new ObjectMapper();

    public List<RequiredEvidenceEntry> parseCatalog(String requiredEvidenceJson) {
        if (!StringUtils.hasText(requiredEvidenceJson)) {
            return List.of();
        }
        try {
            return objectMapper.readValue(requiredEvidenceJson, new TypeReference<List<RequiredEvidenceEntry>>() {
            });
        } catch (Exception e) {
            log.warn("required_evidence JSON 파싱 실패: {}", e.getMessage());
            return List.of();
        }
    }

    public List<RequiredEvidenceEntry> match(String requiredEvidenceJson, String text) {
        if (!StringUtils.hasText(text)) {
            return List.of();
        }
        return parseCatalog(requiredEvidenceJson).stream()
                .filter(entry -> entry.keywords() != null
                        && entry.keywords().stream().anyMatch(text::contains))
                .toList();
    }
}
