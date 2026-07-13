# Backend (Spring)

피싱 방어 서비스의 API 서버입니다.

## 초기 셋업

Gradle + Java 21 기반 Spring Boot 프로젝트입니다 (패키지: `com.phishingdefense.backend`).
    
## 실행

```bash
./gradlew bootRun
```

## DB

MySQL 연결 정보는 `src/main/resources/application.yml`에 설정합니다 (커밋 금지, `.gitignore` 처리 필요 시 `application-local.yml` 사용 권장).

## 브랜치 네이밍

`feat/api-*`, `fix/api-*`, `refactor/api-*` (자세한 규칙은 루트 [README.md](../README.md) 참고)
