# Phishing Defense 프론트엔드 MVP — 구현 진행 상황

> 이 문서는 `docs/superpowers/plans/2026-07-13-frontend-mvp.md` 계획을 기준으로
> 2026-07-13 세션에서 실제로 구현된 내용을 정리한 현황 보고서입니다.
> 아래 "설계 정정" 절에서 설명하듯, Task 14 진행 중 계획서의 일부 내용이
> 실제 코드베이스(`types/game.ts`)·PRD와 어긋난다는 것이 발견되어 사용자 승인 하에
> 남은 작업은 계획서 대신 PRD를 기준으로 재설계했습니다.

## 한 줄 요약

**Task 1~23 전체 완료, 최종 브랜치 코드 리뷰 완료, 테스트 80/80 통과, 타입체크·린트 클린.**
로그인부터 챕터 1 시나리오 플레이 → 채팅 → 판단 → 증거 제출 → 신고 → 결과/보상
수령까지 전 구간이 화면 단위로 구현되어 있고, 각 단계는 실제 백엔드 대신
MSW(Mock Service Worker) 인메모리 서버로 완전히 동작합니다. 전체 플레이 1회를
실제 컴포넌트 트리로 검증하는 캡스톤 통합 테스트(Task 23)까지 통과했습니다.

---

## 1. 아키텍처

- **스택**: Vite + React 19 + TypeScript, Zustand(클라이언트 상태), TanStack Query
  + Axios(서버 통신), React Router 7, MSW 2(모의 API 서버). Tailwind는 사용하지
  않고 `src/index.css`에 다크 테마 디자인 시스템(`docs/DESIGN_SYSTEM.md` 기준)을
  직접 구현.
- **모의 백엔드**: `frontend/src/mocks/db.ts`의 인메모리 `mockDb` + `msw` 핸들러들이
  실제 스프링 백엔드가 없는 상태에서 전체 플로우를 시연 가능하게 함. 나중에 실제
  백엔드가 준비되면 `src/mocks/**`와 `main.tsx`의 부트스트랩 조건만 제거하면 됨.
- **시나리오**: Chapter 1 / Scenario 101 "은행 사칭 스미싱" 1개 시나리오로 MVP 범위
  한정 (`docs/PRD.md` §22.1).

## 2. 완료된 작업 (Task 1–22)

| Task | 내용 | 상태 |
|---|---|---|
| 1–7 | 프로젝트 스캐폴딩, 타입 정의, 레벨/점수 유틸, 목 데이터, MSW 인프라, 인증 핸들러, Axios/authService | ✅ (세션 시작 전 이미 구현되어 있던 것을 확인·정리) |
| 8 | authStore + useAuth 훅 | ✅ (Node 25 실험적 `localStorage`가 jsdom과 충돌하는 버그 수정 + 누락된 훅 추가) |
| 9 | 로그인/회원가입 페이지, ProtectedRoute, 라우팅 셸 | ✅ (새로고침 시 세션 복원 로직 추가) |
| 10 | 챕터/시나리오 목 핸들러 | ✅ |
| 11 | gameService, useChapters/useScenario 훅 | ✅ |
| 12 | 대시보드 페이지(챕터 목록, 레벨/XP 표시) | ✅ |
| 13 | 채팅 목 핸들러 (송신/이력/힌트) | ✅ (아래 "설계 정정" 참고, 이후 재작업됨) |
| 14 | chatService, useChat 훅 | ✅ (설계 정정 발견 및 수정 지점) |
| 15 | gameStore, GameLayout, 공용 ProgressBar | ✅ |
| 16 | Stage1_SMS (문자 메시지 수신 화면) | ✅ |
| 17 | Stage2_Chat (범인과의 채팅 + 롱프레스 증거 저장) | ✅ |
| 18 | 판단 핸들러 + Stage3_Judgment (피싱 여부 판단) | ✅ |
| 19 | 증거 목록/제출 핸들러 + Stage4_Evidence | ✅ |
| 20 | Stage5_Report (경찰 신고 채팅) | ✅ |
| 21 | 리포트 핸들러 + Stage6_Result (평가/보상 수령) | ✅ |
| 22 | GamePage 스테이지 라우터 + 레벨업 플로우 | ✅ |
| 23 | 캡스톤 통합 테스트 (전체 플레이 1회 완주) | ✅ (`GamePage.integration.test.tsx`, REVISED brief 기준) |
| — | 전체 브랜치 최종 코드 리뷰 | ✅ (Critical/Important 0건 발견, Important 2건은 즉시 수정 후 재확인) |

각 Task는 "구현 → 테스트 작성 → 리뷰 서브에이전트 검증 → (필요시) 수정 → 재검증"
과정을 거쳐 완료 처리했습니다 (subagent-driven-development 방식).

## 3. 중요 설계 정정 (Task 14 시점 발견)

Task 14(chatService) 구현 중, **계획 문서(`2026-07-13-frontend-mvp.md`)의 채팅/증거/
판정/리포트 관련 Task 서술이 실제로 이미 작성되어 있던 `types/game.ts` 및
`docs/PRD.md`의 설계와 다르다는 것을 발견**했습니다.

- **계획 문서가 가정한 설계**: AI가 대화 중 증거를 자동 추출, 채팅 응답에
  `stage_complete` 신호 포함.
- **실제 설계 (`types/game.ts` 주석이 `docs/PRD.md §11.1 F2/§13.1.5/§17` 직접 인용)**:
  AI는 절대 증거를 자동 추출하지 않음. 사용자가 채팅 메시지를 **직접 길게 눌러
  (본 구현에서는 버튼 클릭으로 단순화)** 증거로 저장. 스테이지 전환은 자동이 아니라
  사용자의 명시적 행동(판단하기, 다음으로 등)으로 이루어짐. Stage 6에서 AI가
  제출된 증거 하나하나의 유효성을 판정.

사용자에게 확인 후 **"실제 타입 시스템/PRD를 기준으로 진행"** 결정을 받아, Task 13·14를
PRD §14.2.2 규격에 맞게 재수정했고, 이후 Task 17~23은 계획 문서 대신 `docs/PRD.md`
§11.1, §14.2.3, §14.2.4, §17, §18을 직접 근거로 새로 브리프를 작성해 진행했습니다
(각 Task 산출물 커밋 메시지에 "REVISED brief" 로 표시).

## 4. 실제 API 계약 (Mock 서버 기준, `docs/PRD.md` §14.2 정합)

```
POST /api/v1/auth/signup, /login, GET /verify, GET /users/me
GET  /api/v1/chapters
GET  /api/v1/chapters/:chapterId/scenarios
POST /api/v1/scenarios/:scenarioId/start
GET  /api/v1/scenarios/:recordId/status

POST /api/v1/chat/:recordId/send            → { ai_response, turn, hint_available }
GET  /api/v1/chat/:recordId/history         → [{ turn, sender, message, timestamp, stage }]
POST /api/v1/chat/:recordId/hint            → { hint_text, remaining_hints }
POST /api/v1/chat/:recordId/evidence/mark   → { evidence_id, evidence_type_guess, saved }

POST /api/v1/scenarios/:recordId/judgment          → { is_correct, feedback, wrong_attempts, stage_progression }
GET  /api/v1/scenarios/:recordId/evidence          → [{ evidence_id, type, value, turn }]
POST /api/v1/scenarios/:recordId/evidence/submit   → { submitted_count }

GET  /api/v1/scenarios/:recordId/report            → { accuracy_score, star_rating, xp_earned, detailed_feedback, evidence_analysis, recommendations }
POST /api/v1/scenarios/:recordId/report/claim      → { xp_added, level_up, new_total_xp }
```

## 5. 화면(6단계) 구성

1. **Stage1_SMS** — 스미싱 문자 수신 화면
2. **Stage2_Chat** — 범인 AI와 자유 대화, 메시지별 "증거로 저장" 버튼, 힌트 요청
3. **Stage3_Judgment** — "피싱이 맞습니다" / "정상적인 문자입니다" 판단, 오답 2회까지 재시도 후 정답 공개
4. **Stage4_Evidence** — 수집한 증거 목록에서 신고에 제출할 항목 선택
5. **Stage5_Report** — 경찰 AI와 신고 대화 (범인과의 대화와 분리 표시)
6. **Stage6_Result** — 별점/정확도/증거별 유효성 판정/피드백 표시, 보상(XP) 수령 → 대시보드로 복귀 시 레벨업 반영

`GamePage`가 URL(`/game/:recordId`)에 따라 이 6개 컴포넌트를 순서대로 라우팅하며,
새로고침 시 서버의 `record.stage` 값으로 최대한 복원을 시도합니다(중간 대화 상태
완전 복원은 MVP 범위 밖으로 명시).

## 6. 구현 중 함께 고친 실제 버그

- Node 25의 실험적 전역 `localStorage`가 jsdom의 것을 가려 인증 테스트 5개가
  전부 실패하던 문제 (`NODE_OPTIONS=--no-experimental-webstorage`로 해결)
- 새로고침 시 로그인 세션이 복원되지 않던 문제 (`main.tsx`에 `hydrate()` 호출 누락)
- 채팅 메시지에 스테이지 태그가 없어 Stage5(경찰 신고) 화면에 Stage2(범인 채팅)
  내역이 섞여 보이던 문제
- `record.stage`가 대화 중 전혀 갱신되지 않아 힌트 텍스트가 항상 1단계 힌트만
  나오던 문제, 그리고 보상 수령 후에도 `is_completed`가 영원히 `false`로 남던 문제

## 7. 최종 리뷰 결과 및 남은 항목

최종 브랜치 코드 리뷰(가장 상위 모델로 수행)에서 Critical 이슈는 0건이었고,
Important 2건은 바로 수정·재검증까지 완료했습니다:

- ✅ **수정 완료**: `useChat.ts`/`GamePage.tsx`의 `getHistory()` 호출과
  `main.tsx`의 `bootstrap()`에 `.catch` 누락으로 인한 unhandled promise
  rejection 위험 — 기존 `ApiError`/`toast.error` 컨벤션에 맞춰 에러 처리 추가.
- ✅ **수정 완료**: `Stage2_Chat`/`Stage5_Report`에서 전송 실패 시 이미 비워진
  입력창 텍스트가 복구되지 않던 문제 — 실패 시 draft 텍스트 복원.
  (커밋 `4ebf814`, 테스트 80/80·타입체크·린트 클린 유지)

Minor로 분류되어 **의도적으로 후속 작업으로 미룬 항목** (데모에 영향 없음):

- `game.ts`의 챕터/시나리오 핸들러가 URL의 `chapterId`/`scenarioId`를 검증하지
  않음 (MVP가 챕터 1개·시나리오 1개뿐이라 현재는 실질적 영향 없음; 실제 백엔드
  포팅 시 반드시 검증 로직 추가 필요)
- 로그인 상태에서 `/login`·`/signup` 접근 시 자동 리다이렉트 없음
- 토스트 다크테마 미적용, 힌트 소진 케이스 테스트 누락
- `MockRecord.isCompleted` 필드가 실제로는 읽히지도 쓰이지도 않는 죽은 필드
- `ApiError`가 실제 백엔드가 `{message}` 형태가 아닌 에러 바디를 반환할 경우
  취약할 수 있음 (MSW 목 서버 기준으로는 문제 없음)
- `GamePage.integration.test.tsx`가 `.stage2-chat-bubble` CSS 클래스에
  결합되어 있고 타임아웃(20000ms) 값에 설명 주석이 없음

## 8. 테스트/검증 현황

```
Test Files  18 passed (18)
     Tests  80 passed (80)
type-check: clean
lint (oxlint): clean
```

## 9. 다음 단계

계획서(Task 1~23)와 최종 브랜치 코드 리뷰까지 모두 완료했습니다. 남은 결정은
`superpowers:finishing-a-development-branch`를 통한 브랜치 마무리(머지 방식,
PR 생성 여부 등)뿐입니다.
