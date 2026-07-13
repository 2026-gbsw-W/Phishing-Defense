# Phishing Defense - 기술 스택 & API 빠른 참고
**개발자용 한 페이지 요약**

---

## 1. 기술 스택 (한눈에 보기)

```
┌─────────────────────────────────────────────────┐
│          PHISHING DEFENSE TECH STACK             │
└─────────────────────────────────────────────────┘

Frontend                    Backend                 Database
─────────────────────────────────────────────────────────────
React 18.2                  Spring Boot 3.1         MySQL 8.0
Vite 4.4                    Spring Data JPA         Redis (추후)
TypeScript 5.1              Spring Security         
Zustand 4.3                 JWT 0.11.5              
React Query 4.3             OpenAI API 0.14        
Tailwind CSS 3.3            Lombok 1.18            
Framer Motion 10.1          Maven                  
Recharts 2.7                Java 17                
Axios 1.4                                          

API: REST (JSON)
통신: HTTPS + JWT
배포: AWS (ECS/S3/RDS)
```

---

## 2. 의존성 목록 (정확한 버전)

### Frontend npm 패키지

| 패키지 | 버전 | 용도 |
|--------|------|------|
| react | 18.2.0 | UI 라이브러리 |
| react-dom | 18.2.0 | DOM 렌더링 |
| react-router-dom | 6.14.0 | 라우팅 |
| axios | 1.4.0 | HTTP 클라이언트 |
| zustand | 4.3.9 | 상태 관리 |
| @tanstack/react-query | 4.32.0 | 서버 상태 관리 |
| typescript | 5.1.6 | 타입 체크 |
| vite | 4.4.9 | 번들러 |
| tailwindcss | 3.3.2 | CSS 프레임워크 |
| framer-motion | 10.16.4 | 애니메이션 |
| recharts | 2.7.3 | 차트 라이브러리 |
| react-hot-toast | 2.4.1 | 토스트 알림 |
| lucide-react | 0.263.1 | 아이콘 라이브러리 |

### Backend Maven 의존성

| 라이브러리 | 버전 | 용도 |
|-----------|------|------|
| spring-boot-starter-web | 3.1.0 | 웹 프레임워크 |
| spring-boot-starter-data-jpa | 3.1.0 | ORM |
| spring-boot-starter-security | 3.1.0 | 인증 |
| mysql-connector-java | 8.0.33 | MySQL 드라이버 |
| jjwt-api/impl | 0.11.5 | JWT 토큰 |
| openai-java | 0.14.0 | ChatGPT API |
| lombok | 1.18.30 | 코드 생성 |
| jackson-databind | 2.15.0 | JSON 처리 |
| flyway-core | 9.20.0 | DB 마이그레이션 |

---

## 3. 외부 API 통합

### OpenAI GPT API

```
모델: gpt-4-turbo (또는 gpt-3.5-turbo 저비용)
엔드포인트: https://api.openai.com/v1/chat/completions
인증: Bearer {OPENAI_API_KEY}
가격: $0.01-0.03 per 1K 토큰
한글 지원: ✅ 완벽

사용 예시:
POST /v1/chat/completions
{
  "model": "gpt-4-turbo",
  "messages": [
    {"role": "system", "content": "당신은 피싱 사기범입니다..."},
    {"role": "user", "content": "안녕하세요"}
  ],
  "temperature": 0.7,
  "max_tokens": 500
}
```

### Kakao OAuth 2.0

```
로그인 URL: https://kauth.kakao.com/oauth/authorize
토큰 URL: https://kauth.kakao.com/oauth/token
사용자정보: https://kapi.kakao.com/v2/user/me
범위: account_email, profile_nickname

인증 흐름:
1. 사용자가 카카오 로그인 버튼 클릭
2. 동의 화면 표시
3. code 획득
4. Backend에서 code → token 교환
5. token으로 사용자정보 조회
6. JWT 발급
```

### Naver OAuth 2.0

```
로그인 URL: https://nid.naver.com/oauth2.0/authorize
토큰 URL: https://nid.naver.com/oauth2.0/token
사용자정보: https://openapi.naver.com/v1/nid/me
범위: profile, email
```

---

## 4. 데이터베이스 스키마 (주요 테이블)

```
users (사용자)
├─ user_id (PK)
├─ email, password_hash
├─ level, current_xp, total_xp
├─ coins, hints
└─ created_at, updated_at

scenario_records (플레이 기록)
├─ record_id (PK)
├─ user_id (FK)
├─ chapter_id, scenario_id
├─ is_correct_judgment
├─ total_score, star_rating
└─ duration_seconds

chat_history (채팅 기록)
├─ chat_id (PK)
├─ record_id (FK)
├─ turn, sender (user/ai_criminal/ai_police/ai_bank)
├─ message_text
└─ extracted_entities (JSON)

evidence (증거)
├─ evidence_id (PK)
├─ record_id (FK)
├─ evidence_type (사용자 저장 시 자동 분류: phone, account, url, etc)
├─ evidence_value (사용자가 지목한 원문/메모)
├─ message_turn (대화 중 저장한 턴)
├─ is_submitted_at_report (Stage 5 신고 시 제출 여부)
├─ is_valid_evidence (Stage 6 AI 최종 판정)
├─ validity_reason (AI 판정 근거)
└─ importance_level

achievements (업적)
├─ achievement_id (PK)
├─ name, description
├─ xp_reward, coin_reward

user_achievements (사용자 업적)
├─ user_id (FK), achievement_id (FK)
├─ unlocked_at
```

---

## 5. REST API 엔드포인트 (완전 목록)

### Auth API
```
POST   /api/v1/auth/signup                  회원가입
POST   /api/v1/auth/login                   로그인
POST   /api/v1/auth/login/oauth             OAuth 로그인
POST   /api/v1/auth/logout                  로그아웃
POST   /api/v1/auth/refresh                 토큰 갱신
GET    /api/v1/auth/verify                  토큰 검증
```

### Game API (Core)
```
GET    /api/v1/chapters                     모든 Chapter 조회
GET    /api/v1/chapters/{id}/scenarios      Chapter 내 Scenario 조회
POST   /api/v1/scenarios/{id}/start         게임 시작 (record 생성)
GET    /api/v1/scenarios/{id}/status        게임 상태 조회

POST   /api/v1/chat/{record_id}/send        채팅 메시지 전송
GET    /api/v1/chat/{record_id}/history     채팅 히스토리 조회
POST   /api/v1/chat/{record_id}/hint        힌트 요청
POST   /api/v1/chat/{record_id}/evidence/mark   증거 저장(대화 중, 사용자가 직접 지목)

POST   /api/v1/scenarios/{id}/judgment      피싱 판단
GET    /api/v1/scenarios/{id}/evidence      증거 조회 (사용자가 저장한 전체 목록)
POST   /api/v1/scenarios/{id}/evidence/submit   증거 제출(Stage 5 신고 시 선택 제출)

GET    /api/v1/scenarios/{id}/report        결과 리포트
POST   /api/v1/scenarios/{id}/report/claim  XP 청구
```

### User API
```
GET    /api/v1/users/me                     사용자 정보
PUT    /api/v1/users/me                     프로필 수정
GET    /api/v1/users/me/statistics          통계
GET    /api/v1/users/me/achievements        업적 조회
GET    /api/v1/users/me/inventory           인벤토리
```

---

## 6. 프롬프트 예제 (LLM)

### 범죄자 페르소나 (Stage 2-3)
```
당신은 피싱 사기범입니다.

목표: 사용자를 속여 개인정보나 금액을 빼앗기

시나리오: {scenario_context}
사용자 유형: {phishing_type}
말투: {tone}

행동 규칙:
1. 자신의 정체를 숨기되 그럴듯하게 연기
2. 사용자가 의심하면 설득하거나 시간을 끌기
3. 개인정보 수집에 집중
4. 금액은 현실적으로 조정
5. 실제 범죄자처럼 행동

사용자 메시지: {user_message}
이에 자연스럽게 응답하세요 (2-3문장).
```

### 경찰 페르소나 (Stage 5)
```
당신은 경찰청 사이버범죄수사팀 담당자입니다.

역할:
- 피싱 신고를 정중하게 접수
- 사용자가 제출하는 증거 검토(최종 유효 판정은 하지 않음, 부족하면 추가 제출 요청)
- 대응 절차 안내
- 조사 진행

사용자 메시지: {user_message}
전문적으로 대응하세요.
```
※ 최종 증거 유효 판정("증거 맞음"/"증거 아님")은 이 대화가 아닌 Stage 6 리포트 생성 단계에서 수행.

### 리포트 생성
```
다음 훈련 세션을 분석하여 상세 평가를 생성하세요.

사용자 정보:
- 정확도: {accuracy}%
- 제출 증거: {submitted_evidence} (정답: {ground_truth_evidence})
- 대응 능력: {ability}
- 신고 품질: {report_quality}

생성할 내용:
1. 대응 능력 평가
2. 증거 판정 (제출한 항목별 유효/무효 + 근거, 놓친 증거)
3. 신고 대처 평가
4. 교육적 피드백
5. 취약점 분석
6. 다음 추천

JSON 형식으로 응답하세요.
```

---

## 7. 환경 변수 (필수)

```bash
# OpenAI
OPENAI_API_KEY=sk-...

# Kakao OAuth
KAKAO_CLIENT_ID=...
KAKAO_CLIENT_SECRET=...
KAKAO_REDIRECT_URI=http://localhost:3000/auth/kakao/callback

# Naver OAuth
NAVER_CLIENT_ID=...
NAVER_CLIENT_SECRET=...
NAVER_REDIRECT_URI=http://localhost:3000/auth/naver/callback

# Database
DB_PASSWORD=root
DB_URL=jdbc:mysql://localhost:3306/phishing_defense

# JWT
JWT_SECRET=your-super-secret-key-change-in-production

# Server
PORT=8080
REACT_APP_API_URL=http://localhost:8080
```

---

## 8. 성능 최적화 포인트

```javascript
// Frontend 최적화
1. Code Splitting (Vite 자동)
2. React Query 캐싱
3. Zustand 상태 정규화
4. 이미지 최적화 (WebP)

// Backend 최적화
1. JPA N+1 문제 (eager loading)
2. 데이터베이스 인덱싱
3. 쿼리 캐싱 (Redis - Phase 2)
4. 연결 풀 설정 (Hikari)
5. 페이징 처리 (offset/limit)

// API 최적화
1. 응답 압축 (gzip)
2. 요청 배칭 (여러 데이터)
3. API 버전 관리
4. Rate Limiting
5. CDN (정적 자산)
```

---

## 9. 보안 체크리스트

- [ ] JWT 토큰 만료 시간 설정 (24시간)
- [ ] 리프레시 토큰 저장 (httpOnly 쿠키)
- [ ] 비밀번호 해싱 (bcrypt)
- [ ] CORS 설정 (허가 도메인만)
- [ ] HTTPS 강제 (프로덕션)
- [ ] SQL Injection 방지 (Parameterized Query)
- [ ] XSS 방지 (React 자동)
- [ ] CSRF 토큰 (폼)
- [ ] Rate Limiting (API)
- [ ] 데이터 암호화 (민감 정보)
- [ ] 권한 체크 (API)
- [ ] 감사 로깅

---

## 10. 테스트 전략

### Frontend 테스트
```bash
# 단위 테스트
npm run test

# E2E 테스트 (향후)
npm run test:e2e

# 커버리지
npm run test:coverage
```

### Backend 테스트
```bash
# 단위 & 통합 테스트
mvn test

# 특정 테스트만
mvn test -Dtest=UserServiceTest

# 커버리지
mvn jacoco:report
```

---

## 11. 배포 체크리스트

### 프로덕션 배포 전
- [ ] 모든 환경 변수 설정
- [ ] DB 백업
- [ ] SSL 인증서 설정
- [ ] CDN 설정 (이미지)
- [ ] 로드 밸런싱 설정
- [ ] 모니터링 (Sentry, DataDog)
- [ ] 로그 수집 (ELK)
- [ ] 자동 스케일링 설정
- [ ] 배포 전 풀스택 테스트
- [ ] 롤백 계획 수립

---

## 12. 트러블슈팅

### 503 Service Unavailable
```
→ OpenAI API 호출 실패
해결: API 키 확인, Rate Limit 확인, 재시도 로직 추가
```

### 401 Unauthorized
```
→ JWT 토큰 만료 또는 무효
해결: 토큰 갱신, 다시 로그인
```

### 데이터베이스 연결 실패
```
→ 연결 문자열 오류 또는 DB 다운
해결: DB URL 확인, Docker 상태 확인
```

### CORS 에러
```
→ Frontend/Backend 도메인 불일치
해결: application.yml의 CORS 설정 확인
```

---

## 13. 개발 및 배포 명령어

### Frontend
```bash
npm install              # 의존성 설치
npm run dev             # 개발 서버 (localhost:3000)
npm run build           # 프로덕션 빌드
npm run preview         # 빌드 결과 미리보기
npm run lint            # ESLint 실행
npm run type-check      # TypeScript 타입 체크
npm run test            # 테스트 실행
```

### Backend
```bash
mvn clean install               # 의존성 설치
mvn spring-boot:run             # 개발 서버 (localhost:8080)
mvn clean package               # 프로덕션 빌드 (.jar)
mvn test                        # 테스트 실행
mvn test -Dtest=UserServiceTest # 특정 테스트
```

### Docker
```bash
docker-compose up -d            # 개발 DB 실행
docker-compose down             # 중지
docker ps                       # 실행 중인 컨테이너 확인
docker logs phishing-defense-db # 로그 확인
```

---

## 14. 참고 문서

| 문서 | 위치 | 내용 |
|------|------|------|
| PRD | ./docs/PRD.md | 전체 기획서 (21개 섹션) |
| 구현 가이드 | ./docs/IMPLEMENTATION_GUIDE.md | 기술 상세 설명 |
| 패키지 설정 | ./docs/PACKAGE_CONFIG.md | 즉시 실행 가능한 설정 |
| API 명세 | IMPLEMENTATION_GUIDE.md Section 5 | REST API 엔드포인트 |
| DB 스키마 | IMPLEMENTATION_GUIDE.md Section 4 | DDL 스크립트 |

---

## 15. 빠른 시작 (5분)

```bash
# 1. Frontend 시작
npm create vite@latest phishing-defense -- --template react-ts
cd phishing-defense
npm install
npm install zustand @tanstack/react-query axios framer-motion recharts
npm run dev
# → http://localhost:3000 에서 확인

# 2. Backend 시작 (새 터미널)
mvn archetype:generate -DgroupId=com.phishing -DartifactId=backend
cd backend
mvn clean install
mvn spring-boot:run
# → http://localhost:8080 에서 확인

# 3. Database 시작 (새 터미널)
docker-compose up -d
# → MySQL 8.0 + Redis 실행
```

---

**더 자세한 정보는 `/docs` 폴더의 다른 문서를 참고하세요! 📚**
