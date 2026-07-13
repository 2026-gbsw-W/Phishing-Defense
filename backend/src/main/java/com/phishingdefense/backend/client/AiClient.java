package com.phishingdefense.backend.client;

import com.phishingdefense.backend.dto.training.AiChatEndRequestPayload;
import com.phishingdefense.backend.dto.training.AiChatEndResponse;
import com.phishingdefense.backend.dto.training.AiChatMessageResponse;
import com.phishingdefense.backend.dto.training.AiChatRequestPayload;
import com.phishingdefense.backend.dto.training.AiEvidenceRequestPayload;
import com.phishingdefense.backend.dto.training.AiEvidenceResponse;
import com.phishingdefense.backend.dto.training.AiHintRequestPayload;
import com.phishingdefense.backend.dto.training.AiHintResponse;
import com.phishingdefense.backend.dto.training.VoiceChatResult;
import com.phishingdefense.backend.exception.AiServerCommunicationException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Optional;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.MultipartBodyBuilder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.multipart.MultipartFile;

/**
 * 외부 AI 서버(/chat, /chat/end)와 통신한다.
 */
@Component
public class AiClient {

    private final RestClient restClient;

    public AiClient(
            @Value("${ai.server.base-url}") String baseUrl,
            @Value("${ai.server.api-key:}") String apiKey
    ) {
        RestClient.Builder builder = RestClient.builder().baseUrl(baseUrl);
        if (StringUtils.hasText(apiKey)) {
            builder.defaultHeader(HttpHeaders.AUTHORIZATION, "Bearer " + apiKey);
        }
        this.restClient = builder.build();
    }

    /**
     * @param sessionId    이어갈 세션. null이면 AI 서버가 새 세션을 발급한다.
     * @param scenarioType null이면 AI 서버 기본값("prosecutor")이 적용된다.
     */
    public AiChatMessageResponse chat(String sessionId, String message, String scenarioType) {
        try {
            return restClient.post()
                    .uri("/chat")
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(new AiChatRequestPayload(message, sessionId, scenarioType))
                    .retrieve()
                    .body(AiChatMessageResponse.class);
        } catch (RestClientException e) {
            throw new AiServerCommunicationException("AI 서버와의 대화 요청에 실패했습니다.", e);
        }
    }

    public AiChatEndResponse endChat(String sessionId) {
        try {
            return restClient.post()
                    .uri("/chat/end")
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(new AiChatEndRequestPayload(sessionId))
                    .retrieve()
                    .body(AiChatEndResponse.class);
        } catch (RestClientException e) {
            throw new AiServerCommunicationException("AI 서버로부터 훈련 리포트를 받아오지 못했습니다.", e);
        }
    }

    private static final String DEFAULT_EVIDENCE_SPEAKER = "AI(사기꾼)";

    public AiEvidenceResponse saveEvidence(String sessionId, String message) {
        try {
            return restClient.post()
                    .uri("/evidence")
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(new AiEvidenceRequestPayload(sessionId, message, DEFAULT_EVIDENCE_SPEAKER))
                    .retrieve()
                    .body(AiEvidenceResponse.class);
        } catch (RestClientException e) {
            throw new AiServerCommunicationException("AI 서버에 증거를 저장하지 못했습니다.", e);
        }
    }

    public AiHintResponse getHint(String sessionId) {
        try {
            return restClient.post()
                    .uri("/hint")
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(new AiHintRequestPayload(sessionId))
                    .retrieve()
                    .body(AiHintResponse.class);
        } catch (RestClientException e) {
            throw new AiServerCommunicationException("AI 서버로부터 힌트를 받아오지 못했습니다.", e);
        }
    }

    public AiChatEndResponse getReport(String sessionId) {
        try {
            return restClient.get()
                    .uri("/report/{sessionId}", sessionId)
                    .retrieve()
                    .body(AiChatEndResponse.class);
        } catch (RestClientException e) {
            throw new AiServerCommunicationException("AI 서버로부터 훈련 리포트를 받아오지 못했습니다.", e);
        }
    }

    /**
     * @param sessionId    이어갈 세션. null이면 AI 서버가 새 세션을 발급한다.
     * @param scenarioType 새 세션일 때만 사용된다(기존 세션이면 AI 서버가 무시함).
     */
    public VoiceChatResult voiceChat(String sessionId, String scenarioType, MultipartFile audioFile) {
        MultipartBodyBuilder multipartBodyBuilder = new MultipartBodyBuilder();
        multipartBodyBuilder.part("audio_file", audioFile.getResource())
                .filename(audioFile.getOriginalFilename());

        try {
            ResponseEntity<byte[]> response = restClient.post()
                    .uri(uriBuilder -> uriBuilder
                            .path("/voice-chat")
                            .queryParamIfPresent("session_id", Optional.ofNullable(sessionId))
                            .queryParam("scenario_type", scenarioType)
                            .build())
                    .contentType(MediaType.MULTIPART_FORM_DATA)
                    .body(multipartBodyBuilder.build())
                    .retrieve()
                    .toEntity(byte[].class);

            HttpHeaders headers = response.getHeaders();
            byte[] audioContent = response.getBody() != null ? response.getBody() : new byte[0];
            return new VoiceChatResult(
                    headers.getFirst("X-Session-Id"),
                    decodeHeaderValue(headers.getFirst("X-User-Text")),
                    decodeHeaderValue(headers.getFirst("X-AI-Text")),
                    audioContent,
                    headers.getContentType()
            );
        } catch (RestClientException e) {
            throw new AiServerCommunicationException("AI 음성 대화 요청에 실패했습니다.", e);
        }
    }

    private static String decodeHeaderValue(String value) {
        return value == null ? null : URLDecoder.decode(value, StandardCharsets.UTF_8);
    }
}
