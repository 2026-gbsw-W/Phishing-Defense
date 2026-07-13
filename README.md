# Phishing-Defense

피싱 방어 서비스 모노레포입니다.

## 구성

| 폴더 | 스택 | 설명 |
|---|---|---|
| [`frontend/`](frontend) | React | 웹 프론트엔드 |
| [`backend/`](backend) | Spring | API 서버 |
| [`mobile/`](mobile) | Flutter | 모바일 앱 |
| [`ai/`](ai) | Python | 피싱 탐지 모델 |
| [`docs/`](docs) | - | 설계 문서, 회의록 등 |

각 폴더의 README에 초기 셋업 방법이 안내되어 있습니다.

## Run-a-B 협업 가이드

### 📌 기본 규칙

- `main` 브랜치에는 직접 push 하지 않습니다.
- 모든 작업은 브랜치 → Pull Request(PR) → Merge 방식으로 진행합니다.
- 하나의 PR에는 하나의 작업 주제만 포함합니다.

### 🔀 Pull Request 작업 순서

**1. main 최신화**

작업 시작 전에 main 브랜치를 최신 상태로 맞춥니다.

```bash
git checkout main
git pull origin main
```

**2. 브랜치 생성**

작업 내용을 기준으로 새로운 브랜치를 생성합니다.

```bash
git checkout -b feat/web-login
```

**3. 작업 후 커밋**

```bash
git add .
git commit -m "feat: 로그인 페이지 추가"
```

**4. 원격 브랜치로 push**

```bash
git push -u origin feat/web-login
```

**5. Pull Request 생성**

- GitHub 레포로 이동
- Compare & pull request 클릭
- PR 제목과 내용을 작성
- Pull Request 생성

**6. 리뷰 후 merge**

리뷰가 완료되면 main 브랜치로 merge 합니다.

### 🌿 브랜치 이름 규칙

**형식**

```
타입/작업내용
```

**브랜치 타입**

| 타입 | 설명 |
|---|---|
| `feat` | 새로운 기능 |
| `fix` | 버그 수정 |
| `docs` | 문서 수정 |
| `refactor` | 코드 구조 개선 |
| `style` | UI / CSS 수정 |
| `chore` | 설정 / 기타 작업 |
| `test` | 테스트 코드 |

**브랜치 예시**

프론트엔드 (web)
```
feat/web-login
feat/web-dashboard
style/web-navbar
fix/web-routing
```

백엔드 (api)
```
feat/api-auth
feat/api-policy-list
fix/api-error
```

모바일 (mobile)
```
feat/mobile-login
feat/mobile-scan-ui
fix/mobile-navigation
```

AI (ai)
```
feat/ai-classifier
fix/ai-preprocessing
refactor/ai-pipeline
```

문서 / 설정
```
docs/readme-update
chore/project-structure
```

### 📝 커밋 메시지 규칙

**형식**

```
타입: 작업 내용
```

**예시**

```
feat: 로그인 페이지 추가
fix: 정책 목록 조회 오류 수정
docs: README 협업 가이드 추가
chore: 프로젝트 초기 구조 생성
```

### 📌 Pull Request 작성 예시

**PR 제목**

```
feat: 로그인 페이지 구현
```

**PR 내용**

```markdown
## 작업 내용
- 로그인 페이지 UI 구현
- 입력 폼 구성
- 버튼 스타일 적용

## 확인 사항
- 로컬 실행 확인 완료
- 불필요한 파일 없음
- main 브랜치에서 작업하지 않음
```

### ⚠️ 협업 시 주의사항

- 작업 시작 전 항상 main 최신화
- 반드시 새 브랜치에서 작업
- 의미 있는 브랜치 이름 사용
- 의미 있는 커밋 메시지 작성
- merge 전 변경 사항 확인

### 🚫 금지 사항

- main 브랜치 직접 push 금지
- 의미 없는 브랜치 이름 사용 (예: `test`, `123`)
- 의미 없는 커밋 메시지 사용 (예: `수정`, `dd`)
