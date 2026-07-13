package com.phishingdefense.backend.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.json.JsonMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

@Configuration
public class JacksonConfig {

    @Bean
    @Primary
    public ObjectMapper objectMapper() {
        return JsonMapper.builder()
                // 1. Spring 7.0/Boot 4.0의 표준 날짜 라이브러리 모듈 등록 (Java 8 날짜 포맷 지원)
                .addModule(new JavaTimeModule())

                // 2. 날짜를 타임스탬프(숫자)가 아닌 ISO-8601 문자열(기본포맷)로 쓰기
                .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS)

                // 3. JSON 출력 시 줄바꿈 및 들여쓰기 적용 (Indent Output)
                .enable(SerializationFeature.INDENT_OUTPUT)

                // 4. DTO에 없는 필드가 JSON에 포함되어 있어도 오류 없이 파싱 허용
                .disable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES)

                .build();
    }
}