# 트러블슈팅 기록

모바일 인증 연동 → 훈련 플로우 실시간 API 전환 → 백엔드 증거/힌트 구현 과정에서 실제로 겪은 문제와 원인, 해결 방법을 정리한다. 같은 문제를 다시 겪을 때 빠르게 참고하기 위한 문서다.

---

## 1. Spring Boot 4.1 + Jackson 2/3 혼재로 `ObjectMapper` 빈 주입 실패

**증상**: `EvidenceExtractor`에 `ObjectMapper`를 생성자 주입(`@RequiredArgsConstructor`)했더니 앱 시작 시 다음 에러로 죽음.
```
No qualifying bean of type 'com.fasterxml.jackson.databind.ObjectMapper' available
```

**원인**: 이 프로젝트의 클래스패스에 Jackson 2(`com.fasterxml.jackson.core`)와 Jackson 3(`tools.jackson.core`)이 동시에 존재한다 (Spring Boot 4.1은 기본적으로 Jackson 3 계열을 자동 구성하고, `jjwt-jackson` 등 일부 의존성은 Jackson 2를 요구). Spring이 자동 생성하는 `ObjectMapper` 빈은 Jackson 3 타입이라 Jackson 2 `ObjectMapper`를 찾는 주입은 실패한다.

**해결**: 빈 주입을 포기하고 클래스 내부에서 `private final ObjectMapper objectMapper = new ObjectMapper();`로 직접 생성. 이 프로젝트에서 Jackson 관련 빈을 주입받아야 할 일이 생기면 항상 이 혼재 이슈를 의심할 것.

---

## 2. `required_evidence`가 항상 빈 배열이라 증거 기능이 통째로 죽어있었음

**증상**: `GET /scenarios/{recordId}/evidence`가 항상 `[]`, 채팅 응답의 `extractedEvidence`도 항상 빈 배열.

**원인**: DB 스키마(`scenarios.required_evidence` JSON 컬럼)와 엔티티(`Stage.requiredEvidence`)는 존재했지만, 시드 데이터(V3 마이그레이션)가 15개 시나리오 전부 `'[]'`로만 채워져 있었고, 이 컬럼을 읽는 코드가 애초에 한 줄도 없었음(`ChatService.sendMessage()`가 `List.of()`를 하드코딩 반환).

**해결**:
- 실제 키워드 카탈로그를 담은 `V9__Seed_Required_Evidence.sql` 마이그레이션 추가 (이미 적용된 V3를 수정하는 대신 새 버전으로 UPDATE — Flyway는 이미 실행된 마이그레이션 파일을 변경하면 체크섬 불일치로 에러가 남).
- `EvidenceExtractor`(키워드 포함 여부로 매칭)를 만들어 `ScenarioPlayService.start()`(초기 메시지 대상)와 `ChatService.sendMessage()`(매 턴 AI 응답 대상)에 연결.
- 중복 저장 방지를 위해 `EvidenceRepository.existsByRecordIdAndEvidenceType()` 추가.

**교훈**: DB 컬럼/엔티티 필드가 존재한다고 해서 실제로 쓰이고 있다고 가정하면 안 된다. `grep`으로 실제 호출부(call site)가 있는지 반드시 확인.

---

## 3. iOS 시뮬레이터 자동 입력(cliclick)이 한글 IME 때문에 계속 깨짐

**증상**: `cliclick t:"claude-test-login@example.com"`으로 이메일 필드에 영문을 입력했는데 화면에는 `명ㄷ-ㅅㄷㄴㅅ-...` 같은 한글 자모가 찍힘.

**원인**: macOS의 현재 입력 소스가 2벌식 한글로 설정되어 있으면, `cliclick`이 보내는 가상 키 입력이 시스템의 현재 입력 소스를 그대로 거쳐 한글 자모로 변환된다. 이건 코드 버그가 아니라 자동화 환경의 한계.

**시도했지만 안 통한 것**: 클립보드 붙여넣기(`pbcopy` + Cmd+V)도 세션에 따라 필드가 그냥 비어있는 채로 남는 등 불안정.

**결론/우회**: 
- 실제 사람이 시뮬레이터를 직접 타이핑할 때는 문제 없음(사람은 필요시 입력 소스를 스스로 전환하므로). 자동화(Claude가 대신 클릭·타이핑)에서만 발생.
- 실전에서는 curl로 백엔드 API 계약을 먼저 검증하고, 시뮬레이터에서는 화면 diff/네비게이션 흐름 위주로만 확인하는 방식으로 우회. 실제 로그인은 사용자가 한 번 수동으로 해두면 세션이 기기에 저장되어(`SessionStore`) 이후 자동 로그인되므로, 그 세션을 이용해 로그아웃 이후 화면 등은 검증 가능했다.

---

## 4. `flutter test` 환경에서는 실제 네트워크 호출이 항상 400으로 대체됨

**증상**: 로그인 실패 테스트를 작성했는데 기대한 에러 메시지 대신 다른 메시지가 나옴.

**원인**: `TestWidgetsFlutterBinding`은 `HttpClient`를 가로채서 실제 네트워크 요청 대신 항상 상태코드 400을 반환한다(플러터 테스트 프레임워크의 알려진 동작). 즉 `flutter test`에서는 백엔드가 떠 있어도 실제로 연결되지 않는다.

**해결**: 이 제약을 받아들이고, "네트워크 실패 시 보여줄 에러 메시지"를 검증하는 방향으로 테스트를 설계. 세션 관련 테스트는 `SharedPreferences.setMockInitialValues(...)`로 로컬 상태만 조작해서 검증.

---

## 5. Flyway 마이그레이션은 이미 적용된 버전을 수정하면 안 됨

**증상**: 처음엔 `V3__Seed_Chapters_And_Stages.sql`을 직접 고쳐서 `required_evidence`를 채우려고 했음.

**원인**: 로컬 DB에 V3가 이미 적용된 상태라, 파일 내용을 바꾸면 Flyway가 체크섬 불일치로 기동 시 실패한다.

**해결**: 항상 새 버전 번호로 마이그레이션을 추가(`UPDATE ... WHERE scenario_id = ...`). `git log`/DB의 `flyway_schema_history`로 이미 적용된 버전 확인 후 작업할 것.

---

## 6. 백엔드 아키텍처 설계 문서(`docs/TECH_SUMMARY.md`)와 실제 구현(`ai/`)이 어긋나 있음

**증상**: "AI 연동하면 알려줄게" 이후 실제로 뭘 연동해야 하는지 조사했더니, 문서는 "Java 백엔드가 OpenAI API를 직접 호출"하는 설계인데, 실제로 만들어진 `ai/` 디렉터리는 FastAPI + LangChain + **Ollama(로컬 llama3.1:8b)** 기반의 완전히 다른 서비스였음. 게다가 백엔드(Java) 쪽에는 `ai/` 서비스나 OpenAI를 호출하는 코드가 단 한 줄도 없음 (`pom.xml`에 `openai-gpt3-java` 의존성만 들어있고 미사용).

**결론**: 코드/문서/실제 배포물 세 곳이 서로 다른 얘기를 하고 있을 수 있으니, "설계 문서에 이렇게 되어 있다"만 보고 실제 구현 상태를 추정하지 말 것. 이번 건은 사용자가 "AI 연동 아키텍처는 일단 보류"로 결정해서 실제 연동은 보류 중.

---

## 7. `GameProgress`(모바일 로컬 레벨/XP 상태)가 앱 재시작 시 초기화되던 버그

**증상**: 백엔드 DB에는 XP가 정상적으로 쌓이는데, 앱을 껐다 켜면 시나리오 선택 화면의 레벨/총 XP/완료 횟수가 다시 0으로 보임.

**원인**: `GameProgress`가 `ChangeNotifier` 싱글턴이지만 메모리에만 값을 들고 있었고(디스크/서버 동기화 없음), 로그인 세션은 영속화했지만 게임 진행도는 영속화 대상에서 빠져 있었음.

**해결**: 이미 존재하던 `GET /api/v1/users/me`, `GET /api/v1/users/me/statistics` 엔드포인트를 연동해서, 화면 진입 시/리포트 클레임 후 서버의 실제 값으로 동기화(`syncFromServer()`).

**교훈**: "저장된 것처럼 보이는 값"이 실제로 어디서 오는지(메모리 vs 디스크 vs 서버) 항상 구분해서 볼 것. 특히 싱글턴 상태 클래스는 새로 만들 때 영속성 여부를 명시적으로 결정해야 한다.

---

## 8. 로컬 DB/테스트 계정 다루는 법 (docker exec + mysql 클라이언트 미설치)

이 환경에는 로컬에 `mysql` CLI가 설치되어 있지 않다. 대신 MySQL이 Docker 컨테이너(`phishing-mysql`)로 떠 있으므로 다음과 같이 접근한다.

```bash
docker exec phishing-mysql mysql -u root phishing_defense -e "SELECT ..."
```

curl로 회원가입/시나리오 진행 등 실제 API를 검증할 때마다 테스트 계정과 관련 레코드(`scenario_records`, `chat_history`, `evidence`, `refresh_tokens` 등, FK 순서 주의하며 `SET FOREIGN_KEY_CHECKS=0`)를 검증 직후 삭제해서 로컬 DB를 깨끗하게 유지했다.
