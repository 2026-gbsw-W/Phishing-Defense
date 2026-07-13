# Phishing Defense - 개발 계획

작성일: 2026-07-13
기반 문서: [PRD.md](PRD.md), [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md), [PACKAGE_CONFIG.md](PACKAGE_CONFIG.md), [TECH_SUMMARY.md](TECH_SUMMARY.md), 루트 [README.md](../README.md), 현재 [`backend/`](../backend) 실제 구성

---

## 0. 문서 간 확인된 불일치 (먼저 팀 합의 필요)

계획 수립 중 문서와 실제 저장소 상태 사이에서 아래 차이를 발견했습니다. 스프린트 시작 전 팀 내 확정이 필요합니다.

| 항목 | PRD/IMPLEMENTATION_GUIDE 기준 | 현재 저장소 실제 상태 | 확인 필요 사항 |
|---|---|---|---|
| 모바일 대응 | "네이티브 앱 없음, 반응형 웹으로만 대응" | 루트 README에 `mobile/` = **Flutter** 앱으로 명시 | Flutter 네이티브 앱을 실제로 만드는지, 반응형 웹만으로 갈지 확정 |
| AI 모듈 위치 | Backend(Spring)가 OpenAI API를 직접 호출 (별도 AI 서버 없음) | 루트 README에 `ai/` = **Python 피싱 탐지 모델** 별도 폴더 존재 | AI 모듈이 (a) 챗봇 응답 생성까지 겸하는지 (b) 별도의 "탐지 모델"(분류기) 역할만 하는지, 그리고 backend와 통신 방식(REST 내부 호출? 같은 프로세스?) |
| 빌드 도구 | Maven, `groupId: com.phishing`, `artifactId: phishing-defense` | 실제로는 **Gradle**, 패키지 `com.phishingdefense.backend`, 프로젝트명 `backend` | 이미 Gradle로 세팅되어 있으므로 이 계획은 실제 상태(Gradle) 기준으로 진행 |
| Backend 버전/의존성 | Java 17, Spring Boot 3.1.0, Flyway 마이그레이션, OpenAI Java SDK 직접 포함 | Java 21, Spring Boot 4.1.0, QueryDSL 5.1.0, springdoc-openapi 3.0.2, JWT(jjwt 0.12.5), log4j2, Flyway 없음, OpenAI SDK 없음 | Flyway 도입 여부, OpenAI 연동 방식(SDK vs REST 직접 호출) 결정 필요 |

아래 계획은 **실제 저장소 상태(Gradle/Java 21/Flutter 모바일/Python AI 별도 모듈)를 기준**으로 하되, 기능 범위와 우선순위는 PRD/IMPLEMENTATION_GUIDE를 따릅니다.

---

## 1. 프로젝트 한 줄 요약

AI 범죄자와 실시간 채팅으로 피싱 상황을 체험하고, 증거를 수집해 신고까지 진행하는 게이미피케이션 기반 피싱 대응 훈련 플랫폼. 6-Stage(수신→대화→판단→증거수집→신고→리포트) × Chapter 진행 구조.

## 2. 모노레포 구성 및 담당 스택

| 폴더 | 스택 | 역할 |
|---|---|---|
| `backend/` | Java 21, Spring Boot 4.1.0, Gradle, MySQL, QueryDSL, springdoc-openapi, JWT | 인증, 게임 진행, XP/레벨/업적, 리더보드, AI 채팅 오케스트레이션 API |
| `frontend/` | React 18 + TypeScript + Vite (PRD 기준) | 웹 대시보드, Stage 1-6 게임 UI |
| `mobile/` | Flutter | 모바일 앱 (범위는 §0 확정 필요) |
| `ai/` | Python | 피싱 탐지/분류 모델, 증거 추출(NER) 등 (범위는 §0 확정 필요) |
| `docs/` | - | 기획/설계 문서 |

## 3. 시스템 아키텍처 (제안)

```
[Frontend(React) / Mobile(Flutter)]
            │  HTTPS + JWT
            ▼
      [Backend: Spring Boot API]
      ├─ Auth (JWT, Kakao/Naver OAuth)
      ├─ Game (Chapter/Stage/XP/별평가/업적/리더보드/미션)
      ├─ Chat Orchestration ── OpenAI GPT-4 API 호출 (페르소나 프롬프트)
      └─ REST 연동 ──────────▶ [ai/: Python 피싱 탐지·분석 모델]
            │
            ▼
        [MySQL] (+ Redis, Phase 2 캐시)
```

- Backend가 게임 상태/인증/DB를 전담하고, OpenAI 호출(대화 생성)과 `ai/` Python 모델(증거 NER, 위험도 분류 등) 호출을 오케스트레이션.
- `ai/`는 독립 프로세스로 배포하고 Backend가 내부 REST로 호출하는 것을 기본 가정으로 함 (§0 확정 필요).

## 4. 핵심 도메인 모델 (PRD §13 기준, 12개 테이블)

`users`, `chapters`, `scenarios`, `chapter_progress`, `scenario_records`, `chat_history`, `evidence`, `achievements`, `user_achievements`, `daily_missions`, `attendance`, `phishing_index`

핵심 게임 루프: `scenario_records`(1회 플레이 기록) 중심으로 `chat_history`(대화) / `evidence`(증거) 가 연결되고, 완료 시 XP·별평가가 산출되어 `chapter_progress`/`users`에 반영됨.

## 5. 기능 우선순위 (MVP → Phase 3)

### MVP (P0, 목표 4주)
- Chapter 1 (1개 시나리오), Stage 1~6 전체 플로우
- GPT-4 기반 AI 채팅 엔진 (범죄자 페르소나)
- 정규식 기반 증거 자동 추출
- XP/레벨(1~30) · 별평가(0~3) 시스템
- MySQL 스키마 기본 구성, JWT 인증
- React 반응형 웹 프론트엔드, Spring Boot 백엔드

### Phase 1-1 (P1, +2주)
- Chapter 2~3 추가, 업적 10개, 출석 시스템(7/14일), 고정 일일미션
- 홈 대시보드 완성, 프로필/통계 화면, 알림
- 친구 추가 + 리더보드(Top 100) + 결과 공유

### Phase 1-2 (P1, +3주)
- Chapter 4~5 추가 (총 15개 이상 시나리오)
- AI 고도화 (페르소나 다양화, 난이도 자동조절), NER 기반 증거 추출 확장(10개 이상 타입)
- LLM 기반 동적 리포트 생성, 은행 AI 추가(2단계 신고 완성)
- 맞춤형 훈련(약점 분석 기반 동적 미션)

### Phase 2 (P2, +4~8주)
- STT/TTS 통화 모드, 멀티플레이(협력/경쟁/클랜), 고급 분석, 스토어/아이템

### Phase 3 (Month 4+)
- 국제화(다국어), ML 기반 개인화, Enterprise 버전(조직 대시보드/커스텀 시나리오), API 개방(B2B)

## 6. 로드맵 타임라인 (제안)

| 주차 | 목표 | 비고 |
|---|---|---|
| Week 1 | 저장소/CI/DB 스키마 확정, 인증 API, Backend 보일러플레이트 | §0 결정사항 반영 |
| Week 2 | Chapter/Scenario API, Frontend 기본 컴포넌트, 홈 대시보드 | |
| Week 3 | Stage 1~6 UI + AI 채팅 통합 (OpenAI 연동) | 증거추출/신고 NPC 포함 |
| Week 4 | 별평가/XP/리포트 로직, 전체 E2E QA, **MVP Go-Live** | 내부 테스트 + 지인 초대 |
| Week 5-6 | Phase 1-1 (Chapter 2-3, 업적/출석/리더보드) | 소규모 정식 출시 |
| Week 7-9 | Phase 1-2 (Chapter 4-5, AI 고도화, 신고 완성) | 기관 파일럿 시작 |
| Week 10-13 | Phase 2 (STT/TTS, 멀티플레이 등) | 전국 서비스 확대 |
| Month 4+ | Phase 3 (국제화, Enterprise, API 개방) | 글로벌 확장 |

## 7. QA / 검증 게이트

- MVP 런칭 전 체크리스트(IMPLEMENTATION_GUIDE §13, PRD §22.1)를 스프린트 종료 기준(Definition of Done)으로 채택
- 각 Phase 종료 시 회귀 테스트 + 신규 기능 E2E 테스트 수행

## 8. 리스크 및 대응

| 리스크 | 대응 |
|---|---|
| OpenAI API 비용/지연 | 경량 모델(GPT-3.5) 폴백, 응답 캐싱, 3초 타임아웃 시 로딩 UX 처리 |
| §0의 미확정 사항으로 인한 작업 중복 | Week 1 킥오프에서 반드시 확정 후 착수 |
| 문서-실제 구현 버전 불일치 누적 | 이 문서와 PRD/IMPLEMENTATION_GUIDE를 스프린트마다 동기화, 변경 시 `docs/` 갱신을 PR 체크리스트에 포함 |
| 팀 인력 (FE1+BE1+PM1 가정, PRD 기준) | 모바일(Flutter)/AI(Python) 담당 인력 별도 확보 여부 확인 필요 |

## 9. 다음 액션 아이템

1. §0 표의 4개 항목 팀 합의 (모바일 범위, AI 모듈 통신 방식, 빌드도구는 확정됨, Backend 의존성 방향)
2. Backend: `entity`/`repository`/`controller` 패키지 구조 착수 (PACKAGE_CONFIG.md 기준 조정)
3. Frontend: Vite + TS 프로젝트 초기화 (`frontend/` 현재 README만 존재)
4. `ai/`: Python 프로젝트 초기화 및 backend와의 인터페이스(REST 스펙) 정의
5. DB 마이그레이션 도구 채택 결정 (Flyway 도입 여부)
