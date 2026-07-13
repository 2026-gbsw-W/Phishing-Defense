# Phishing Defense - 서비스 기획서(PRD)
**AI 기반 실전형 피싱 대응 훈련 플랫폼**

최종 수정: 2026-07-13  
프로젝트 코드명: `PHISHING_DEFENSE`  
버전: 1.0 (MVP)

---

## 1. 프로젝트 소개

### 1.1 프로젝트명
**Phishing Defense** - AI 기반 실전형 피싱 대응 훈련 플랫폼

### 1.2 한 줄 설명
"게임을 하듯 피싱을 경험하고, AI 범죄자와 대화하며, 증거를 수집하고, 신고까지 진행하는 실전형 게임형 교육 플랫폼"

### 1.3 프로젝트 개요
Phishing Defense는 기존의 일방향 교육 콘텐츠(포스터, 영상, 이론)의 한계를 **게이미피케이션**으로 극복하는 플랫폼입니다. 사용자는:

- **AI 범죄자**와 직접 문자/전화로 대화
- **증거 수집** 미니게임을 통해 실전 감각 습득
- **경험치 시스템**으로 성장 중심의 게임플레이 경험
- **신고 시뮬레이션**으로 사후 대처까지 학습
- **리더보드, 업적, 레벨 시스템**으로 계속 플레이하고 싶은 동기 부여

### 1.4 프로젝트 배경
- 2024년 보이스피싱 피해: 약 200억원 규모 (경찰청 통계)
- 피해자 대부분이 "피싱인 줄 몰라서" 피해 입음
- 기존 교육은 이론 중심이라 실제 대응 능력 부족
- **게이미피케이션이 교육 효과 극대화**할 수 있는 기회

---

## 2. 문제 정의

### 2.1 사용자의 문제
| 문제 | 현황 | 영향 |
|------|------|------|
| **낮은 피싱 인식도** | 일상에서 피싱을 만났을 때 실시간 판단 불가 | 연간 수천억대 피해 |
| **이론 중심 교육** | 포스터, 영상, 수칙으로 배우는 일방향 학습 | 금세 잊혀짐, 실전에서 대응 못함 |
| **재미없음** | 의무적 안전교육 → 참여도 낮음 | 완수율 50% 미만 |
| **실전 경험 부족** | 실제 범죄자처럼 행동하는 대상과 상호작용 불가 | 대응 능력 검증 불가능 |

### 2.2 기존 솔루션의 한계
1. **일반 교육 콘텐츠**: 수동적 학습, 장기 기억 어려움
2. **선택지 기반 퀴즈**: 정답 추측 가능, 실전과 무관함
3. **텍스트 기반 시뮬레이션**: 단조로움, 범죄자의 실제 수법 미반영
4. **목표 부재**: 명확한 성장 경로 없음

### 2.3 우리의 접근
**게임 플레이처럼 느껴지는 실전 훈련** → 높은 참여도, 실제 능력 개발, 지속적 재참여

---

## 3. 서비스 목표

### 3.1 주요 목표 (OKR)
| Objective | Key Result |
|-----------|-----------|
| **사용자 참여도 극대화** | 월 활성 사용자(MAU) 대비 평균 플레이 시간 15시간 이상 |
| **피싱 대응 능력 향상** | 훈련 전후 피싱 인식도 테스트 점수 40% 상향 |
| **반복 플레이 유도** | 모든 Chapter 클리어 시간: 4주, 재플레이율 60% |
| **교육 기관 채택** | 3개월 내 5개 기관 파일럿 진행 |

### 3.2 엔드 게임
사용자가 **"피싱 대응 게임"**을 생각하면 Phishing Defense를 떠올리도록, 
교육이 아닌 **재미 있는 게임**으로 인식되는 것

---

## 4. 핵심 가치

### 4.1 사용자 가치
| 가치 | 설명 |
|------|------|
| **즉각적 피드백** | 각 선택지마다 AI가 반응 → "내가 잘했나?" 즉시 확인 |
| **성장의 재미** | 레벨, XP, 업적으로 가시적 성장 → 게임처럼 중독성 있음 |
| **자유로운 선택** | 객관식 아님 → 자신의 전략대로 플레이, 여러 방법 시도 가능 |
| **현실 기반 학습** | 실제 범죄자 수법 AI로 재현 → 진짜 경험처럼 느껴짐 |
| **실용적 지식** | "증거는 이렇게 수집한다" "경찰에는 이렇게 말한다" 등 실전 노하우 |

### 4.2 조직 가치
- **기업**: 직원 보안 교육을 "재미있는 게임"으로 추진 가능
- **정부기관**: 국민 피싱 예방 교육의 획기적 전환
- **학교**: 학생 사이버 범죄 대응 능력 강화

---

## 5. 경쟁 서비스 비교

| 서비스 | 방식 | 게임화 | 자유도 | 실전성 | 피드백 | 평가 |
|--------|------|--------|---------|--------|--------|------|
| **기존 포스터/영상** | 수동 시청 | ✗ | ✗ | △ | ✗ | ✗ |
| **일반 교육 퀴즈** | 객관식 | △ | ✗ | △ | △ | ✗ |
| **웹 기반 시뮬레이터** | 상황 제시 | △ | △ | △ | △ | △ |
| **Phishing Defense** | AI 대화형 | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |

**차별점**: 자유로운 입력 + AI 응답 + 게임 시스템 + 신고까지의 완전한 사이클

---

## 6. Persona

### Persona 1: 김영준 (20대 후반, 일반 직장인)
- **상황**: 회사 보안 교육 시간
- **pain point**: "또 교육이네...", 지루함, 실제 도움이 되지 않는 느낌
- **목표**: "빨리 끝내고 싶다" → (우리 앱으로) "다음엔 몇 성까지 가볼까?"
- **행동**: 틈틈이 플레이, 친구에게 자랑 ("내가 피싱 헌터여!")

### Persona 2: 박미영 (50대, 비교적 디지털 약자)
- **상황**: 보이스피싱에 대한 불안감
- **pain point**: "나는 피싱에 약한 것 같은데", 정확한 대응법 모름
- **목표**: "자신감 있게 대응하고 싶다"
- **행동**: 천천히 플레이, 힌트 자주 사용, 자신의 약점 파악 후 반복 플레이

### Persona 3: 이준석 (30대, 회사 보안 담당자)
- **상황**: 직원 보안 교육 프로그램 구축 필요
- **pain point**: "기존 교육은 완수율 낮고, 실효성 없음"
- **목표**: "모든 직원이 피싱을 제대로 대응하는 역량 갖추기"
- **행동**: 플랫폼 도입 검토, 조직 내 도입, 리더보드로 직원 참여 유도

---

## 7. User Journey

### 7.1 신규 사용자 여정 (Day 1~7)

```
Day 1: 앱 설치 → 온보딩 (게임 컨셉 소개)
  └─ "당신은 피싱 헌터입니다" 임무 브리핑
  
Day 1-2: Chapter 1 첫 Stage 체험
  └─ AI 기본 SMS 수신 → 채팅 대화 시작
  └─ 반응형 AI의 신기함에 놀람 ("진짜 사람처럼 하네?")
  
Day 2-3: Chapter 1 완료
  └─ 증거 수집, 경찰·은행 신고 흐름 체험
  └─ 첫 별★ 획득, 경험치 200XP 획득
  └─ "레벨 2 달성!" 알림 → 보상함 오픈 (게임처럼)
  
Day 3-7: Chapter 2 시작
  └─ 일일 미션 참여 (보너스 XP)
  └─ 친구에게 "이거 게임인데 진짜 배워"라고 추천
```

### 7.2 지속 사용자 여정 (주차별)

```
1주: Chapter 2 진행 (난이도 약간 상향)
2주: Chapter 3 도전, 어려운 부분에서 힌트 사용
3주: Chapter 3 ★★★ 달성을 위해 2회 반복 플레이
4주: Chapter 4 진행, 본격 성장 기대감 높음
5-6주: "피싱 헌터 달성" 업적 목표로 플레이
이후: 일일 미션 중심, 난이도 자동 조절로 맞춤 훈련
```

---

## 8. User Flow

### 8.1 메인 게임플레이 Flow

```
┌─ 로그인 ─┐
│          │
├─ 홈 (Dashboard) ── 진행상황, 레벨, XP, 보상함
│          │
├─ Chapter 선택 ── 잠금해제된 Chapter만 표시
│          │
├─ Stage 1: SMS 수신 ── "안녕하세요, 이것은..."
│          │
├─ Stage 2: AI와 자유 채팅 대화 ── 사용자 입력 → AI 응답 (1~3회)
│          │
├─ Stage 3: 피싱 여부 판단 ── "피싱인 것 같습니다" / "일반 메시지입니다"
│          │
├─ Stage 4: 증거 수집 ── 대화 내용에서 자동 추출된 증거 확인·선택
│          │
├─ Stage 5: 신고 프로세스 
│  ├─ 경찰 AI와 신고 대화
│  └─ 은행 AI와 지급정지 요청 대화
│          │
├─ Stage 6: AI 리포트 & 결과
│  ├─ 대응 능력 평가
│  ├─ 별★ 부여
│  ├─ XP 지급
│  ├─ 놓친 증거 안내
│  └─ "이번엔 은행에 전화했어야 함"같은 팁 제공
│          │
└─ 결과화면 → 다음 Chapter 또는 홈으로
```

### 8.2 로그인/온보딩 Flow

```
앱 실행
  ↓
로그인 (카카오/네이버/이메일)
  ↓
신규 가입 여부 판단
  ├─ [신규] → 온보딩
  │  ├─ "당신은 피싱 헌터입니다" 애니메이션
  │  ├─ 게임 컨셉 3단계 설명
  │  └─ Chapter 1 첫 Stage 자동 시작
  │
  └─ [기존] → 홈 대시보드
```

### 8.3 일일 미션 Flow

```
매일 자정에 새 미션 생성
  ├─ 고정 미션 (일일 1스테이지 클리어)
  ├─ 동적 미션 (사용자 약점 기반)
  │  └─ "당신은 금융 사칭에 약하네요 - 금융 시나리오 도전!"
  └─ 보너스 미션 (난이도 높음) → XP 2배

사용자가 미션 클리어
  → 보상함에 보상 표시
  → 클릭하면 XP/코인 획득
  → 알림: "오늘의 미션 완료! +100XP"
```

---

## 9. Information Architecture (IA)

```
Phishing Defense
├─ 홈 (Dashboard)
│  ├─ 사용자 프로필 (레벨, XP, 랭킹)
│  ├─ Chapter 진행 상황
│  ├─ 일일 미션
│  ├─ 보상함
│  └─ 퀵 스타트 (마지막 플레이 지점)
│
├─ Story / Chapter
│  ├─ Chapter 1: 기초 스미싱 사건
│  │  ├─ Stage 1-6 (순차 진행)
│  │  └─ 결과 리포트
│  ├─ Chapter 2: 택배 사칭 사건
│  ├─ Chapter 3: 가족 사칭 사건
│  ├─ Chapter 4: 금융기관 사칭 사건
│  ├─ Chapter 5: 검찰 사칭 사건
│  └─ Chapter 6+: AI 랜덤 사건 (무한 재생성)
│
├─ My Stats (내 통계)
│  ├─ 레벨 & 경험치 진행률
│  ├─ 별 평가 분포
│  ├─ 취약 유형 분석 (예: "금융 사칭 73% 정확도")
│  ├─ 힌트 사용률
│  ├─ 증거 수집률 평균
│  └─ 업적 목록
│
├─ Achievements (업적)
│  ├─ 🏆 첫 훈련 완료
│  ├─ 🏆 피싱 헌터 (Lv.30 달성)
│  ├─ 🏆 힌트 없이 5연속 클리어
│  ├─ 🏆 증거 수집 완벽주의자
│  ├─ 🏆 7일 연속 로그인
│  └─ [미달성 업적들] ← 동기부여
│
├─ Leaderboard (리더보드)
│  ├─ Global (전체 사용자)
│  ├─ Friends (친구)
│  ├─ Weekly (주간) / Monthly (월간)
│  └─ Category (유형별)
│
├─ Settings (설정)
│  ├─ 프로필 수정
│  ├─ 음성 알림 (STT/TTS)
│  ├─ 난이도 설정
│  ├─ 링크/공유
│  └─ 로그아웃
│
└─ Store (미래)
   ├─ 더블 XP 부스트
   ├─ 힌트 충전
   └─ 커스텀 프로필 스킨
```

---

## 10. 화면 설계

### 10.1 주요 화면 목록

#### 1. 홈 (Dashboard)
```
┌─────────────────────────────────┐
│ ⬅︎  Phishing Defense      ⚙︎   │  ← Header
├─────────────────────────────────┤
│                                 │
│  👤 김영준          Lv. 5        │  ← 프로필
│     XP: 2,340 / 3,000          │
│     ████████░░  78%            │
│                                 │
│  🏅 랭킹: #234 / 15,000        │  ← 랭킹
│  ⭐ 보상함: 3개 신규            │  ← 알림
│                                 │
├─────────────────────────────────┤
│  📚 Story Progress              │  ← Story Section
│                                 │
│  Chapter 1 ✓ ★★★              │  ← 완료
│  Chapter 2 ✓ ★★☆              │  ← 완료 (재플레이 가능)
│  Chapter 3 🔄 진행중... 60%    │  ← 진행 중
│  Chapter 4 🔒 잠금해제 필요    │  ← 잠김
│                                 │
├─────────────────────────────────┤
│  🎯 오늘의 미션                 │
│                                 │
│  □ 일일 1스테이지 클리어        │  ← 미완료
│  ✓ 금융사칭 도전               │  ← 완료
│  ⭐ 힌트없이 클리어 (+50XP)    │  ← 보너스
│                                 │
├─────────────────────────────────┤
│  [▶ 계속 진행하기] [📊 통계]   │  ← 액션
└─────────────────────────────────┘
```

#### 2. Stage 2: AI와 채팅 대화
```
┌─────────────────────────────────┐
│ ⬅︎  Chapter 3 - Stage 2   [?💡] │  ← Header + 힌트
├─────────────────────────────────┤
│                                 │
│  🕐 00:43 / 10:00    📌 메모   │  ← 타이머, 메모
│                                 │
│  ┌─────────────────────────────┐│
│  │AI: 안녕하세요. 엄마인데,    ││  ← AI 메시지
│  │    지금 급할 일이 있어서.   ││
│  │    가능하면 금액 얘기하기전││
│  │    에 내 상황부터 들어줄    ││
│  │    수 있나?                 ││
│  │                       13:45  ││
│  └─────────────────────────────┘│
│                                 │
│  ┌─────────────────────────────┐│
│  │You: (이전 메시지들...)      ││
│  │                       13:44  ││
│  └─────────────────────────────┘│
│                                 │
│                                 │
│  ┌─────────────────────────────┐│
│  │ [입력란] 응 뭐야? 뭔데?    ││  ← 텍스트 입력
│  └─────────────────────────────┘│
│           [전송] 또는            │
│     [🎬 이전부터 다시시작]      │
│                                 │
└─────────────────────────────────┘
```

#### 3. Stage 3: 피싱 여부 판단
```
┌─────────────────────────────────┐
│ ⬅︎  Chapter 3 - Stage 3         │
├─────────────────────────────────┤
│                                 │
│  🎯 이 메시지의 의도를          │
│     판단하세요.                 │
│                                 │
│  📋 대화 내용 요약:             │
│  - "엄마"가 급할 일 있다고      │
│  - 금액에 대해 언급 없음        │
│  - 먼저 상황 설명해달라         │
│                                 │
│                                 │
│  ┌──────────────────────────────┐│
│  │ [이것은 피싱입니다]          ││  ← 선택지
│  └──────────────────────────────┘│
│                                 │
│  ┌──────────────────────────────┐│
│  │ [정상적인 메시지입니다]      ││
│  └──────────────────────────────┘│
│                                 │
│  [⏸︎ 일시정지] [💡 힌트 요청]  │
│                                 │
└─────────────────────────────────┘
```

#### 4. Stage 4: 증거 수집
```
┌─────────────────────────────────┐
│ ⬅︎  Chapter 3 - Stage 4         │
├─────────────────────────────────┤
│                                 │
│  🔍 증거를 수집하세요!          │
│     (중요한 정보를 체크)         │
│                                 │
│  수집률: ████████░░ 80%        │
│                                 │
│  ☑︎ 송신자 번호: 01X-XXXX-5678 │  ← 자동 체크됨
│  ☑︎ "엄마"라고 사칭             │
│  ☐ 금액 요구 내용               │  ← 미수집
│  ☑︎ 급함을 강조                 │
│  ☑︎ 말투가 어색함               │
│  ☐ 계좌번호                     │  ← 미수집
│  ☐ URL/링크                     │  ← 제시되지 않음
│                                 │
│  💡 Tip: 계좌번호는 이 유형의   │
│     중요한 증거입니다. 더 파고   │
│     들어서 계좌정보를 유도해보세│
│     요!                         │
│                                 │
│         [다음: Stage 5 신고]     │
│                                 │
└─────────────────────────────────┘
```

#### 5. Stage 5: 신고 - 경찰 대화
```
┌─────────────────────────────────┐
│ ⬅︎  Chapter 3 - Stage 5 신고   │
├─────────────────────────────────┤
│  📞 신고 진행 현황              │
│  ├─ ✓ 경찰 신고                │
│  ├─ ⏳ 은행 지급정지 요청       │
│  └─ ⏳ 피해금 회수              │
├─────────────────────────────────┤
│                                 │
│  👮 경찰: "신고가 접수되었습니다│
│     다시 한번 사건을 정리해주   │
│     실래요?"                   │
│                                 │
│                                 │
│  You: 누군가 엄마인 척 해서...  │
│  (이전 대화들)                  │
│                                 │
│                                 │
│  ┌─────────────────────────────┐│
│  │ 자세히 설명...              ││  ← 텍스트 입력
│  └─────────────────────────────┘│
│          [전송] [💡 힌트]       │
│                                 │
└─────────────────────────────────┘
```

#### 6. Stage 6: 결과 리포트
```
┌─────────────────────────────────┐
│         🎯 Mission Complete!    │  ← 게임 완료 연출
│                                 │
│  ⭐ ⭐ ⭐  (3/3)               │  ← 별 표시
│                                 │
├─────────────────────────────────┤
│ 📊 상세 평가                    │
│                                 │
│ ✓ 대응 능력: 우수               │
│   └─ 빠르게 의심하고 깊게 파고  │
│   └─ 답: 2-3번 대화 중 의심   │
│                                 │
│ ✓ 증거 수집: 양호 (80%)        │
│   └─ 놓친 증거 1개: 계좌번호   │
│   └─ Tip: 금융사기의 계좌는    │
│      매우 중요한 증거입니다!   │
│                                 │
│ ✓ 힌트 사용: 0회 (무사용)       │
│   └─ 보너스: +20XP             │
│                                 │
│ ✓ 신고 대응: 우수               │
│   └─ 경찰/은행 대화 모두 적절  │
│                                 │
├─────────────────────────────────┤
│ 💰 보상                         │
│                                 │
│ Base XP: +150                   │
│ Bonus (+20XP, ★★★): +70       │
│ ─────────────────────────────   │
│ Total: +220 XP                  │
│                                 │
│ 레벨 업!  Lv.5 → Lv.6 🎉      │
│ 2,560/3,500 XP                  │
│                                 │
├─────────────────────────────────┤
│ 🎮 다음 추천                    │
│                                 │
│ "당신은 가족 사칭에는 강합니다  │
│  금융기관 사칭에는 약해 보여요. │
│  Chapter 4를 먼저 추천합니다!"  │
│                                 │
│  [다음 Chapter]  [보상함 확인]  │
│                                 │
└─────────────────────────────────┘
```

#### 7. 업적 화면 (Achievements)
```
┌─────────────────────────────────┐
│ ⬅︎  업적                    🔍  │
├─────────────────────────────────┤
│  진행중: 23 / 40               │
│  완료율: ████░░░░░░ 58%        │
├─────────────────────────────────┤
│                                 │
│  🏆 일반                       │
│  ├─ ✓ 시작하기                 │
│  │  └─ 첫 훈련 완료            │
│  ├─ ✓ 레벨 5 달성              │
│  │  └─ 2024년 7월 15일         │
│  ├─ ⭐ 레벨 30 달성            │
│  │  └─ 진행도: ███░░░░░░ 18%  │
│  │     (XP 필요: 50,000/100,000)
│  └─ ⭐ 무한 사냥꾼              │
│     └─ 일일 미션 100일 연속 성공
│                                 │
│  🎯 숙련도                      │
│  ├─ ✓ 처음 대응                │
│  │  └─ 피싱 판단 1회 성공      │
│  ├─ ✓ 증거 수집가               │
│  │  └─ 증거 100개 수집         │
│  ├─ ⭐ 완벽한 증거             │
│  │  └─ 한 시나리오에서 증거 100%
│  └─ ⭐ 신고 달인                │
│     └─ 신고 대응 완벽 10회     │
│                                 │
└─────────────────────────────────┘
```

---

## 11. 기능 명세서

### 11.1 핵심 게임플레이 기능

#### F1. AI 채팅 엔진
```
기능명: AI와의 자유로운 대화
상세:
- 사용자의 자유로운 텍스트 입력 (객관식 X)
- LLM이 범죄자 페르소나로 대응
- Stage별로 AI 행동 패턴 설정
  ├─ Stage 1-2: 사용자를 속이려고 함
  ├─ Stage 3: 판단 대기
  └─ Stage 5: 신고 기관 페르소나 (경찰, 은행)

구현:
- 프롬프트 엔지니어링: 범죄자 페르소나 + 상황 컨텍스트
- 컨텍스트 윈도우: 현재 대화 + 이전 메시지 5개
- 응답 시간: 3초 이내 (로딩 애니메이션)
- 폴백: 응답 없으면 "생각 중입니다..." → 재시도
```

#### F2. 증거 자동 추출
```
기능명: 대화에서 증거 자동 인식 및 추출
상세:
- AI 대화 과정에서 언급된 정보 자동 추출
- 증거 카테고리:
  ├─ 발신자 정보 (전화번호, 이름)
  ├─ 금액 (얼마를 요구)
  ├─ 계좌 정보
  ├─ URL/링크
  ├─ 기관 사칭 내용
  └─ 말투 이상성 (NLP로 감지)

구현:
- NER(Named Entity Recognition): 전화번호, 금액, URL 패턴 인식
- 키워드 매칭: 특정 단어 (계좌, 송금, 은행)
- 수동 선택: 증거화면에서 사용자가 최종 선택
- 저장: 증거 DB에 자동 저장
```

#### F3. 피싱 판단 로직
```
기능명: 사용자 판단이 맞는지 검증
상세:
- 정답: 실제 설정된 시나리오 피싱 여부
- 검증:
  ├─ 정답 맞음: 다음 단계 진행
  ├─ 오답: "다시 생각해보세요" + 힌트 옵션
  └─ 2회 오답: 정답 공개 + 약간 감점 (-10XP)

구현:
- Chapter 설계 시 각 시나리오의 정답 사전 설정
- 판단 로직은 시간 기반 (언제 의심했는가)
  └─ 1-2회 대화: 우수 판단력
  └─ 3-5회: 양호
  └─ 5회 이상 또는 오답: 요주의
```

#### F4. 신고 프로세스
```
기능명: 경찰, 은행과의 신고 대화
상세:
- Stage 5에서 두 개의 AI 페르소나와 대화
- 경찰 AI:
  ├─ 범죄 신고 절차
  ├─ 필요 정보 확인
  └─ 증거 수집 방법 안내
- 은행 AI:
  ├─ 지급정지 요청
  ├─ 계좌 동결 절차
  └─ 피해금 회수 안내

구현:
- AI 대화 방식은 Stage 2와 동일
- 채팅 UI는 전화 통화 UI처럼 시뮬레이션
- 평가: 신고 내용이 명확하고 증거를 제시했는가?
```

#### F5. 동적 결과 리포트
```
기능명: AI가 생성하는 맞춤형 평가
상세:
- 수집된 모든 데이터 기반 자동 생성
- 포함 내용:
  ├─ 대응 능력 평가 (점수 + 피드백)
  ├─ 증거 수집률 (% + 놓친 증거 명시)
  ├─ 시간 효율성
  ├─ 신고 대처 평가
  └─ 취약점 분석 ("금융사기 약함")

구현:
- LLM 프롬프트: 데이터 입력 → 텍스트 생성
- 템플릿 + 동적 생성 조합
- 교육적 피드백: "이 증거는 실제 신고에 매우 중요합니다"
```

### 11.2 게임 시스템 기능

#### F6. XP & 레벨 시스템
```
기능명: 사용자 성장 시스템
상세:
- XP 획득 기준:
  ├─ Base: Chapter 클리어 +150XP
  ├─ ⭐ 별 평가: ★★★ +70XP, ★★ +30XP, ★ +10XP
  ├─ Bonus: 힌트미사용 +20, 빠른 대응 +10, 증거100% +40
  └─ Penalty: 힌트다사용 -5/회, 대응실패 -30

- 레벨 진행 (5,000XP마다 레벨업)
- 레벨 보상: 특수 배지, 힌트 충전, 코인
```

#### F7. 별(★) 평가 시스템
```
기능명: Chapter별 성취도 표시
상세:
- 각 Chapter 클리어 시 ★☆☆ ~ ★★★ 평가
- 평가 기준 (합산):
  ├─ 대응 정확도: 50점
  ├─ 증거 수집률: 20점
  ├─ 신고 대처: 20점
  ├─ 힌트 사용량: 10점
  └─ 시간 효율성: 10점 (총 100점)
  
- 등급:
  ├─ ★☆☆: 60~79점
  ├─ ★★☆: 80~89점
  └─ ★★★: 90점 이상

- 활용:
  ├─ UI에 표시 (Chapter 목록)
  ├─ ★★★ 달성 시 보너스 XP +70
  └─ 재플레이 유도 ("★★★을 목표로!")
```

#### F8. 챕터(Chapter) 시스템
```
기능명: 스토리 진행 시스템
상세:
- Chapter 구조:
  ├─ Chapter 1: 기초 스미싱 (난이도 ★)
  ├─ Chapter 2: 택배 사칭 (난이도 ★★)
  ├─ Chapter 3: 가족 사칭 (난이도 ★★)
  ├─ Chapter 4: 금융기관 사칭 (난이도 ★★★)
  ├─ Chapter 5: 검찰 사칭 (난이도 ★★★)
  └─ Chapter 6+: AI 랜덤 (난이도 자동조절)

- 진행 방식:
  ├─ 순차적 잠금해제 (Chapter N 완료 후 N+1 오픈)
  ├─ Chapter 별 3개 시나리오 (같은 주제, 다른 상황)
  └─ 각 시나리오마다 별 평가 가능

- 목표:
  ├─ 모든 Chapter 클리어: 약 4주
  ├─ 재플레이로 ★★★ 달성: 2주
```

#### F9. 스테이지(Stage) 시스템
```
기능명: Chapter 내 세분화된 진행
상세:
- 1 Chapter = 6 Stages
  ├─ Stage 1: SMS/전화 수신
  ├─ Stage 2: AI 범죄자와 자유 대화 (2-3회)
  ├─ Stage 3: 피싱 여부 판단
  ├─ Stage 4: 증거 수집 확인
  ├─ Stage 5: 경찰·은행 신고 대화
  └─ Stage 6: AI 리포트 및 보상

- 특징:
  ├─ 각 Stage마다 다른 게임 메카닉
  ├─ 중간 저장 가능 (언제든 재시작 가능)
  └─ 별 평가는 6개 Stage 전체 완료 후
```

#### F10. 업적(Achievements) 시스템
```
기능명: 도전 과제 및 보상
상세:
- 업적 카테고리 (약 40개)
  ├─ 🏆 일반 (레벨, 로그인 등)
  ├─ 🎯 숙련도 (피싱 판단, 증거 수집)
  ├─ ⚡ 도전과제 (힌트없이, 빠른 클리어)
  └─ 🌟 특별 (이벤트)

- 보상:
  ├─ 첫 달성: XP + 배지 + 알림
  ├─ 완료도 표시 (예: 40대 업적 중 23개)
  └─ 리더보드 연동 (몇 % 달성했나)
```

#### F11. 일일 미션
```
기능명: 매일 새로운 도전
상세:
- 종류:
  ├─ 고정 미션: 일일 1개 Stage 클리어 (+100XP)
  ├─ 동적 미션: 사용자 약점 기반 (예: 금융 사칭 도전)
  └─ 보너스 미션: 높은 난이도 (+XP 2배)

- 생성:
  ├─ 매일 자정 초기화
  ├─ AI 분석: 사용자 약점 자동 감지
  └─ 성공 시 보상함에 추가

- 활용:
  ├─ 일일 활성 유도
  ├─ 취약점 보강
  └─ 연속 출석 도전
```

#### F12. 연속 출석 시스템
```
기능명: 로그인 연속성 보상
상세:
- 출석 일수:
  ├─ 7일: 힌트 +3개, 코인 +500
  ├─ 14일: 더블 XP 부스트 1일권
  ├─ 30일: 특별 배지 + 코인 +1000
  └─ 연속 유지 시 보너스 증가

- 시각화:
  ├─ 홈 화면에 출석 달력
  ├─ 연속일수 표시
  └─ 다음 보상까지 카운트다운
```

#### F13. AI 맞춤형 훈련
```
기능명: 플레이 데이터 기반 추천
상세:
- 누적 분석:
  ├─ 정확도 분석 (유형별)
  ├─ 약점 자동 감지
  └─ 성장 추세 분석

- 기반 서비스:
  ├─ 부족한 Chapter 추천
  ├─ 난이도 자동 조절
  ├─ 맞춤형 일일 미션
  └─ "금융사기에만 약하네요" 피드백

- 구현:
  ├─ 각 리포트 결과 DB 저장
  ├─ 주간 분석 실행
  └─ 다음 미션/추천 자동 생성
```

### 11.3 소셜 기능

#### F14. 리더보드
```
기능명: 사용자 순위 표시
상세:
- 종류:
  ├─ Global: 전체 사용자 (상위 100)
  ├─ Friends: 친구만
  ├─ Weekly: 주간 순위 (리셋)
  ├─ Monthly: 월간 순위
  └─ Category: 유형별 (택배사칭 최고 점수 등)

- 순위 기준:
  ├─ 주: 총 XP (모든 활동)
  ├─ 월: 이번달 획득 XP
  ├─ 카테고리: 특정 Chapter 별 점수

- 표시:
  ├─ 내 순위 강조 (상위 20 또는 주변 5명)
  ├─ 1-3위 특수 배지
  └─ 친구와 비교 (Δ ±XX%)
```

#### F15. 친구 추가 & 공유
```
기능명: 친구 경쟁 및 공유
상세:
- 친구 추가:
  ├─ 수동 ID 검색
  ├─ QR코드 공유
  └─ 초대 링크

- 공유:
  ├─ 업적 달성 시
  ├─ ★★★ 달성 시
  └─ 리더보드 순위

- 메시지 예시:
  └─ "🎉 Phishing Defense에서 금융기관사칭 훈련을 완료했습니다! (★★★) 당신도 피싱헌터가 되세요!"
```

---

## 12. 게임 시스템 설계

### 12.1 XP 및 레벨 시스템

#### 12.1.1 XP 획득 공식

```
Total XP = Base XP + Star Bonus + Completion Bonus - Penalty

기본값 (Base XP)
├─ Chapter 완료: 150XP (모든 Chapter)
└─ Stage 별 소량: 30XP (선택)

별(★) 보너스
├─ ★☆☆: +10XP
├─ ★★☆: +30XP
└─ ★★★: +70XP

완료 보너스 (최대 +140)
├─ 힌트 미사용 (0회): +20XP
├─ 증거 100% 수집: +40XP
├─ 신고 완벽 대처: +50XP
└─ 5분 이내 완료: +30XP

감점 (최대 -50)
├─ 힌트 1회 사용: -5XP
├─ 증거 미수집 (10% 미만): -10XP
├─ 신고 불완전: -20XP
└─ 20분 이상 소요: -10XP

예시 계산
Chapter 3 완료 시나리오:
├─ Base: 150XP
├─ ★★★ 획득: +70XP
├─ 힌트 0회: +20XP
├─ 증거 95% 수집: +40XP
├─ 신고 완벽: +50XP
├─ 8분 완료: +30XP
├─ 패널티: 0XP
└─ 합계: 360XP ⭐ 최고 성과!

반대 시나리오:
├─ Base: 150XP
├─ ★☆☆ 획득: +10XP
├─ 힌트 3회: -15XP
├─ 증거 65% 수집: +25XP
├─ 신고 불완전: -20XP
├─ 28분 완료: -10XP
└─ 합계: 140XP (기본값만)
```

#### 12.1.2 레벨 테이블

```
Lv. 1 - 시민 (0 XP)
  └─ "평범한 시민. 이제 첫 훈련을 시작합니다."
  
Lv. 5 - 예비 수사관 (4,000 XP)
  └─ "기초는 갖춘 상황"
  └─ 보상: 힌트 +5개, 배지
  
Lv. 10 - 수사관 (10,000 XP)
  └─ "중급 능력 습득"
  └─ 보상: 더블 XP 부스트 1일권
  
Lv. 15 - 중급 수사관 (18,000 XP)
  └─ "거의 다 왔습니다"
  
Lv. 20 - 특별 수사관 (28,000 XP)
  └─ "상당한 실력을 갖춤"
  └─ 보상: 특별 배지, 코인 +1000
  
Lv. 25 - 고급 수사관 (40,000 XP)
  
Lv. 30 - 피싱 헌터 (60,000 XP)
  └─ "최고 등급. 당신은 진정한 피싱 헌터입니다!"
  └─ 보상: 최종 배지, 특별 프로필 테마
  └─ 업적: "피싱 헌터 달성" 잠금 해제

Lv. 31~50 - 전설의 헌터 (매 10,000 XP마다)
  └─ 무한 진행, 명예 시스템
```

### 12.2 별(★) 평가 시스템 상세

#### 12.2.1 평가 점수 배분

```
총 100점 만점

1. 대응 정확도 (50점)
   ├─ 피싱 판단 정확성: 30점
   │  ├─ 1-2회 대화 중 의심: 30점 (우수)
   │  ├─ 3-4회: 25점 (양호)
   │  ├─ 5회 이상: 20점 (보통)
   │  ├─ 오답 1회: 15점 (부족)
   │  └─ 오답 2회 이상: 10점 (미흡)
   │
   ├─ 대응 방식의 현명함: 20점
   │  ├─ 정보 과다 제공 안함: 20점
   │  ├─ 약간 의심스러운 대답: 15점
   │  └─ 개인정보 제시 등: 0점

2. 증거 수집률 (20점)
   ├─ 100%: 20점
   ├─ 90-99%: 18점
   ├─ 80-89%: 15점
   ├─ 70-79%: 10점
   └─ 70% 미만: 5점

3. 신고 대처 (20점)
   ├─ 경찰·은행 모두 명확한 설명: 20점
   ├─ 한쪽만 충실: 15점
   ├─ 기본만 함: 10점
   └─ 미흡: 5점

4. 힌트 사용량 (10점)
   ├─ 0회: 10점
   ├─ 1회: 9점
   ├─ 2회: 7점
   ├─ 3회: 4점
   └─ 4회 이상: 0점

5. 시간 효율성 (10점)
   ├─ 5분 이내: 10점
   ├─ 5-10분: 8점
   ├─ 10-15분: 6점
   ├─ 15-20분: 3점
   └─ 20분 이상: 0점

합산
├─ 90점 이상: ★★★ (골드)
├─ 80-89점: ★★☆ (실버)
└─ 60-79점: ★☆☆ (브론즈)
```

### 12.3 챕터(Chapter) 프로그레션

#### 12.3.1 Chapter 구조

```
Chapter 1: 기초 스미싱 사건 ⭐ 난이도 1/5
├─ Scenario 1-1: 은행 사칭 스미싱
├─ Scenario 1-2: 통신사 사칭 스미싱
├─ Scenario 1-3: 무직자대출 스미싱
└─ 클리어 요구사항: 모든 시나리오 최소 ★☆☆

Chapter 2: 택배 사칭 사건 ⭐⭐ 난이도 2/5
├─ Scenario 2-1: 배송 지연 사칭
├─ Scenario 2-2: 반품 처리 사칭
├─ Scenario 2-3: 택배사고 사칭
└─ 클리어 조건: Chapter 1 완료 + 모두 ★☆☆ 이상

Chapter 3: 가족 사칭 사건 ⭐⭐ 난이도 2/5
├─ Scenario 3-1: 딸 사칭 (돈 빌려달라)
├─ Scenario 3-2: 엄마 사칭 (뭔가 있다)
├─ Scenario 3-3: 형 사칭 (사고났다)
└─ 클리어 조건: Chapter 2 완료 + 2개 이상 ★★☆

Chapter 4: 금융기관 사칭 사건 ⭐⭐⭐ 난이도 3/5
├─ Scenario 4-1: 신용카드 한도 증가 알림
├─ Scenario 4-2: 계좌 이체 이상 거래 알림
├─ Scenario 4-3: 보험료 미납 독촉
└─ 클리어 조건: Chapter 3에서 평균 ★★☆

Chapter 5: 검찰 사칭 사건 ⭐⭐⭐ 난이도 3/5
├─ Scenario 5-1: 범죄자 신원조회
├─ Scenario 5-2: 구속 영장 집행
├─ Scenario 5-3: 세금 체납 적발
└─ 클리어 조건: Chapter 4 완료

Chapter 6~: AI 랜덤 사건 ⭐⭐⭐⭐ 난이도 자동조절
├─ 매 플레이마다 새로운 AI 생성 시나리오
├─ 사용자 약점 기반 난이도 조절
├─ 무한 재생성 가능
└─ 무한 성장 가능
```

#### 12.3.2 진행 조건

```
Linear 프로그레션 (유연성 있는 순차)

엄격한 순차 진행:
└─ Chapter 1 완료 → Chapter 2 잠금해제
   └─ Chapter 2 완료 → Chapter 3 잠금해제
   └─ ...

단, 조기 접근 가능:
├─ 친구 초대로 Chapter 미리보기 (5분)
└─ 광고 시청으로 한 번 도전 (1회/일)
```

### 12.4 업적(Achievements) 명세

#### 12.4.1 업적 목록 (약 40개)

```
🏆 일반 (5개)
├─ 첫 걸음: 첫 훈련 완료 (10XP)
├─ 레벨 5: 레벨 5 달성 (자동)
├─ 수사관: 레벨 10 달성 (100XP 보너스)
├─ 특별 수사관: 레벨 20 달성 (200XP 보너스)
└─ 피싱 헌터: 레벨 30 달성 (500XP 보너스 + 특별 배지)

🎯 숙련도 (12개)
├─ 첫 판단: 피싱 판단 1회 완료
├─ 판단의 정수: 10회 연속 정확한 판단
├─ 증거 수집가: 총 100개 증거 수집
├─ 완벽한 증거: 한 시나리오에서 100% 증거 수집 (3회)
├─ 신고왕: 신고 대처 완벽 10회 (100XP)
├─ 금융 전문가: Chapter 4 ★★★ 달성
├─ 검찰 전문가: Chapter 5 ★★★ 달성
├─ 택배 전문가: Chapter 2 ★★★ 달성
├─ 가족 전문가: Chapter 3 ★★★ 달성
├─ 스미싱 전문가: Chapter 1 ★★★ 달성
├─ 마스터: 모든 Chapter ★★★ 달성 (500XP)
└─ 만렙: 레벨 30 + 모든 업적 달성 (특별 타이틀)

⚡ 도전과제 (10개)
├─ 힌트 없이: 힌트 사용 않고 1회 클리어 (+20XP)
├─ 5연속 무사용: 5회 연속 힌트 없이 (100XP)
├─ 빠른 손가락: 5분 이내 완료 (3회) (50XP)
├─ 통찰력: 1회 대화 만에 피싱 판단 (5회) (100XP)
├─ 투지: 같은 시나리오 3회 이상 도전 (10회)
├─ 성실함: 10일 연속 로그인 (50XP)
├─ 열정: 30일 연속 로그인 (200XP)
├─ 미션 완료자: 일일 미션 10회 완료 (100XP)
├─ 미션 마스터: 일일 미션 30회 완료 (300XP)
└─ 10연속 생존: 10일 연속 Chapter 클리어 (200XP)

⚡ 고급 도전과제 (8개)
├─ 스미싱 마스터: Chapter 1 모든 시나리오 ★★★ 달성
├─ 택배 마스터: Chapter 2 모든 시나리오 ★★★ 달성
├─ 금융 마스터: Chapter 4 모든 시나리오 ★★★ 달성
├─ 검찰 마스터: Chapter 5 모든 시나리오 ★★★ 달성
├─ 완벽한 시리즈: 모든 Chapter ★★★ 달성 (500XP + 특별 배지)
├─ 무한 도전: 100회 이상 플레이 (50XP)
├─ 광대한 경험: 총 1,000회 대화 (300XP)
└─ 에이스: 한 달간 매일 플레이 (300XP)

🌟 특별 (5개)
├─ 사회 기여: 친구 5명 초대 (100XP)
├─ 영향력: 친구 10명 초대 (200XP)
├─ 신뢰의 상: 리더보드 상위 10% (특별 배지)
├─ 이벤트 참여: 한정 시간 이벤트 완료 (변동)
└─ 비밀 업적: (미공개, 플레이하며 발견)
```

---

## 13. 데이터베이스 설계

### 13.1 주요 테이블

#### 13.1.1 User (사용자)

```sql
CREATE TABLE users (
  user_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(255) UNIQUE NOT NULL,
  nickname VARCHAR(50) NOT NULL,
  provider VARCHAR(20) -- 'kakao', 'naver', 'email'
  provider_id VARCHAR(255),
  level INT DEFAULT 1,
  current_xp INT DEFAULT 0,
  total_xp INT DEFAULT 0,
  coins INT DEFAULT 0,
  hints INT DEFAULT 3,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login_at TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

#### 13.1.2 Chapter Progress (챕터 진행상황)

```sql
CREATE TABLE chapter_progress (
  progress_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  chapter_id INT NOT NULL,
  is_completed BOOLEAN DEFAULT FALSE,
  best_star INT DEFAULT 0 -- 0-3 (no star, 1, 2, 3)
  total_attempts INT DEFAULT 0,
  first_clear_at TIMESTAMP,
  last_attempt_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  UNIQUE KEY (user_id, chapter_id)
);
```

#### 13.1.3 Scenario Record (시나리오 플레이 기록)

```sql
CREATE TABLE scenario_records (
  record_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  chapter_id INT NOT NULL,
  scenario_id INT NOT NULL,
  
  -- 게임플레이 데이터
  is_correct_judgment BOOLEAN, -- 피싱 판단 맞음/틀림
  judgment_at_turn INT, -- 몇 번째 대화에서 판단
  hints_used INT DEFAULT 0,
  evidence_collected_count INT,
  evidence_collected_percentage INT, -- 0-100
  
  -- 평가
  star_rating INT, -- 0-3
  total_score INT, -- 0-100
  
  -- 기타
  played_at TIMESTAMP,
  duration_seconds INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);
```

#### 13.1.4 Chat History (채팅 기록)

```sql
CREATE TABLE chat_history (
  chat_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  record_id BIGINT NOT NULL,
  turn INT, -- 1st, 2nd, 3rd...
  sender VARCHAR(10), -- 'user' or 'ai'
  message_text LONGTEXT,
  ai_model_version VARCHAR(50), -- GPT-4, Claude, etc
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (record_id) REFERENCES scenario_records(record_id)
);
```

#### 13.1.5 Evidence (증거)

```sql
CREATE TABLE evidence (
  evidence_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  record_id BIGINT NOT NULL,
  evidence_type VARCHAR(50), -- 'phone', 'account', 'url', 'impersonation', 'amount', 'tone'
  evidence_value VARCHAR(255),
  is_correctly_identified BOOLEAN, -- AI 평가
  source VARCHAR(50), -- 'auto_extracted' or 'user_selected'
  importance_level INT DEFAULT 1, -- 1-5 (중요도)
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (record_id) REFERENCES scenario_records(record_id)
);
```

#### 13.1.6 Achievement (업적)

```sql
CREATE TABLE achievements (
  achievement_id INT PRIMARY KEY,
  name VARCHAR(100),
  description VARCHAR(255),
  icon_url VARCHAR(255),
  xp_reward INT DEFAULT 0,
  coin_reward INT DEFAULT 0
);

CREATE TABLE user_achievements (
  user_achievement_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  achievement_id INT NOT NULL,
  unlocked_at TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (achievement_id) REFERENCES achievements(achievement_id),
  UNIQUE KEY (user_id, achievement_id)
);
```

#### 13.1.7 Daily Mission (일일 미션)

```sql
CREATE TABLE daily_missions (
  mission_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  mission_type VARCHAR(50), -- 'fixed', 'dynamic', 'bonus'
  mission_description VARCHAR(255),
  recommendation_reason VARCHAR(255), -- "약한 유형: 금융사기"
  is_completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMP,
  reward_xp INT,
  created_date DATE,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);
```

#### 13.1.8 Attendance (출석)

```sql
CREATE TABLE attendance (
  attendance_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  checked_in_at DATE UNIQUE,
  consecutive_days INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);
```

### 13.2 인덱스 전략

```sql
-- 성능 최적화 인덱스
CREATE INDEX idx_user_level ON users(level);
CREATE INDEX idx_user_created ON users(created_at);
CREATE INDEX idx_chapter_user ON chapter_progress(user_id);
CREATE INDEX idx_scenario_user ON scenario_records(user_id, created_at);
CREATE INDEX idx_chat_record ON chat_history(record_id);
CREATE INDEX idx_evidence_record ON evidence(record_id);
CREATE INDEX idx_mission_user_date ON daily_missions(user_id, created_date);
```

---

## 14. API 설계

### 14.1 인증 API

```
POST /api/v1/auth/login
요청: { email, password }
응답: { token, user_id, nickname, level, xp }

POST /api/v1/auth/login/oauth
요청: { provider, token }  // provider: 'kakao', 'naver'
응답: { token, user_id, nickname, level }

POST /api/v1/auth/logout
응답: { success: true }

POST /api/v1/auth/signup
요청: { email, password, nickname }
응답: { user_id, token }
```

### 14.2 게임 API

#### 14.2.1 Chapter & Progress

```
GET /api/v1/chapters
응답: [ { chapter_id, title, difficulty, is_unlocked, best_star, ... } ]

GET /api/v1/chapters/{chapter_id}/scenarios
응답: [ { scenario_id, title, context, ... } ]

POST /api/v1/scenarios/{scenario_id}/start
요청: {}
응답: { record_id, initial_message, timestamp }

GET /api/v1/scenarios/{record_id}/status
응답: { stage, current_turn, is_completed, ... }
```

#### 14.2.2 Chat

```
POST /api/v1/chat/{record_id}/send
요청: { message }
응답: { 
  ai_response, 
  turn, 
  extracted_evidence: [{ type, value }],
  hint_available: true
}

GET /api/v1/chat/{record_id}/history
응답: [ { turn, sender, message, timestamp } ]

POST /api/v1/chat/{record_id}/hint
응답: { hint_text, remaining_hints }
```

#### 14.2.3 Judgment & Evidence

```
POST /api/v1/scenarios/{record_id}/judgment
요청: { is_phishing: true }
응답: { is_correct, feedback, stage_progression }

GET /api/v1/scenarios/{record_id}/evidence
응답: [ { evidence_id, type, value, importance } ]

POST /api/v1/scenarios/{record_id}/evidence/confirm
요청: { selected_evidence_ids: [1, 2, 3] }
응답: { evidence_collection_percentage, missed_evidence: [...] }
```

#### 14.2.4 Report

```
GET /api/v1/scenarios/{record_id}/report
응답: {
  accuracy_score: 85,
  star_rating: 3,
  xp_earned: 220,
  detailed_feedback: "...",
  evidence_analysis: {...},
  recommendations: [...]
}

POST /api/v1/scenarios/{record_id}/report/claim
요청: {}
응답: { xp_added, level_up: false, new_balance: 2560 }
```

### 14.3 사용자 API

```
GET /api/v1/users/me
응답: { 
  user_id, 
  nickname, 
  level, 
  xp, 
  rank, 
  achievements_count,
  statistics: {...}
}

GET /api/v1/users/me/statistics
응답: {
  total_plays: 45,
  average_star: 2.4,
  accuracy_by_type: { "family": 0.85, "delivery": 0.72, ... },
  most_used_hint_type: "...",
  ...
}

PUT /api/v1/users/me/profile
요청: { nickname }
응답: { success: true }

GET /api/v1/users/me/achievements
응답: [ { achievement_id, name, unlocked: true, unlocked_at } ]

GET /api/v1/users/me/inventory
응답: { coins: 500, hints: 3, boosters: [...] }
```

### 14.4 Leaderboard API

```
GET /api/v1/leaderboard?scope=global&period=weekly
응답: [
  { rank: 1, user_id, nickname, xp, avatar_url },
  { rank: 2, ... },
  ...
  { rank: 234, (현재 사용자), xp, ... }
]

GET /api/v1/leaderboard/friends
응답: [ { rank, nickname, xp } ]

GET /api/v1/leaderboard/category?category=family_phishing
응답: [ { rank, nickname, score } ]
```

### 14.5 Mission API

```
GET /api/v1/missions/daily
응답: [
  { mission_id, type: "fixed", description, reward_xp, is_completed },
  { mission_id, type: "dynamic", description: "금융사기 도전!", reward_xp, ... },
  { mission_id, type: "bonus", description, reward_xp: 200, ... }
]

POST /api/v1/missions/{mission_id}/complete
요청: { record_id } // 시나리오 기록으로 미션 완료
응답: { success: true, reward_xp }

GET /api/v1/attendance
응답: { 
  consecutive_days: 7, 
  current_streak: true,
  next_reward: { day: 14, reward: "double_xp_1day" },
  calendar: [...] 
}
```

### 14.6 AI 생성 API (내부)

```
POST /api/v1/ai/generate-scenario
요청: { difficulty, weakness_type?, user_history }
응답: { scenario_id, context, initial_message }

POST /api/v1/ai/chat-response
요청: { record_id, user_message, context }
응답: { ai_message, extracted_data }

POST /api/v1/ai/generate-report
요청: { record_id }
응답: { report_json }
```

---

## 15. AI 구조

### 15.1 AI 아키텍처

```
┌─────────────────────────────────────────────────┐
│          Phishing Defense AI System              │
└─────────────────────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
    ┌───▼────┐    ┌──────▼──┐    ┌──────▼────┐
    │ LLM    │    │ Prompt  │    │ Context   │
    │(GPT-4) │    │Template │    │Management │
    └───┬────┘    └──┬──────┘    └──┬───────┘
        │           │               │
        └───────────┴───────────────┘
                    │
        ┌───────────┼──────────┐
        │           │          │
    ┌───▼─┐     ┌──▼──┐   ┌───▼──┐
    │Role │     │Tone │   │Stage │
    │Ctrl │     │Ctrl │   │Ctrl  │
    └─────┘     └─────┘   └──────┘
```

### 15.2 페르소나 시스템

#### 15.2.1 범죄자 페르소나

```
System Prompt Template:

당신은 피싱 사기범입니다. 
당신의 목표는 사용자를 속여 개인정보나 금전을 뺏아내는 것입니다.

현재 시나리오: {scenario_context}
사용자 정보: {user_phishing_type}
말투: {tone}

규칙:
1. 자신의 정체를 숨기되, 그럴듯하게 행동하세요
2. 사용자가 의심하면 설득하거나 시간을 끌으세요
3. 개인정보 수집에 집중하세요
4. 금액은 적절히 조정하세요 (너무 크지 않도록)
5. 현실적인 표현만 사용하세요

다음은 사용자의 최근 메시지입니다:
{user_message}

이에 자연스럽게 응답하세요. (2-3문장)
```

#### 15.2.2 기관 페르소나 (경찰, 은행)

```
[경찰 페르소나]
당신은 경찰청 사이버범죄수사팀 담당자입니다.
사용자의 피싱 신고를 접수받고 있습니다.

역할:
1. 신고인의 진술을 청취
2. 필요한 증거 정보 수집
3. 대응 절차 안내
4. 실제 경찰처럼 조사 진행

[은행 페르소나]
당신은 해당 은행의 사기 대응팀 직원입니다.
사용자가 지급정지를 요청하고 있습니다.

역할:
1. 사용자 인증
2. 거래 내역 확인
3. 계좌 동결 절차
4. 예상 회수율 안내
```

### 15.3 Context Management

#### 15.3.1 대화 컨텍스트 구조

```python
class ScenarioContext:
  scenario_id: int
  user_id: int
  
  # 시나리오 기본 정보
  scenario_type: str  # "family", "delivery", "phishing"
  difficulty: int  # 1-5
  
  # 게임플레이 상태
  current_stage: int  # 1-6
  current_turn: int  # 1-3+ (각 Stage마다)
  
  # 대화 히스토리
  message_history: List[{sender, message, timestamp}]
  
  # 추출된 정보
  extracted_evidence: List[Evidence]
  user_actions: List[str]  # "의심함", "개인정보 제공", ...
  
  # 평가 데이터
  judgment_correct: bool? = None
  judgment_turn: int? = None
  
  def get_system_prompt(self) -> str:
    # 현재 Stage와 Turn에 맞는 Prompt 생성
    
  def extract_evidence(self, message: str) -> List[Evidence]:
    # NER, 패턴 매칭으로 증거 추출
    
  def evaluate_judgment(self, is_phishing: bool) -> Dict:
    # 사용자 판단 검증
```

### 15.4 응답 생성 파이프라인

```
사용자 메시지 입력
    │
    ▼
┌─────────────────────┐
│ Context 로드        │
└────────┬────────────┘
         │
         ▼
┌─────────────────────────────┐
│ Prompt 생성                 │
│ (페르소나 + Stage + 컨텍스트)│
└────────┬────────────────────┘
         │
         ▼
┌─────────────────────┐
│ LLM API 호출        │
│ (OpenAI GPT-4)      │
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│ 응답 수신           │
└────────┬────────────┘
         │
         ▼
┌──────────────────────────┐
│ 증거 추출                │
│ (NER + 패턴 매칭)       │
└────────┬─────────────────┘
         │
         ▼
┌──────────────────────────┐
│ Context 업데이트         │
└────────┬─────────────────┘
         │
         ▼
┌──────────────────────────┐
│ 응답 + 메타데이터 반환   │
└──────────────────────────┘
```

### 15.5 LLM 선택 및 프롬프트

#### 15.5.1 모델 선택
- **주모델**: GPT-4 (Turbo) - 복잡한 문맥, 높은 정확도 필요
- **보조모델**: Claude 3 Opus - 롤플레이 능력, 맥락 유지 우수
- **경량모델**: GPT-3.5 Turbo - 비용 최적화 (의견 제시 등)

#### 15.5.2 Prompt Engineering

```
상황별 프롬프트 전략:

[Stage 1-2: 범죄자 역할]
"You are a {phishing_type} scammer. Your goal is to deceive and extract 
information. Current scenario: {scenario}. User message: {message}.
Respond naturally as the criminal would (2-3 sentences)."

[Stage 3: 판단 대기]
(시스템이 AI를 호출하지 않음 - 순수 사용자 선택)

[Stage 5: 기관 담당자]
"You are a {agency} official handling a phishing report.
Collect necessary information and guide the process.
User said: {message}. Respond professionally."

[Report Generation]
"Analyze this phishing training session and generate a detailed report.
User's accuracy: {accuracy}%, Evidence collected: {percentage}%,
Key improvements: {list}. Provide constructive feedback."
```

---

## 16. STT/TTS 구조 (확장 기능)

### 16.1 아키텍처

```
┌──────────────────────────────────────────┐
│        음성 통화 모드 (Future)           │
└──────────────────────────────────────────┘
                    │
        ┌───────────┼───────────┐
        │           │           │
    ┌───▼──┐    ┌──▼──┐    ┌───▼──┐
    │ STT  │    │ LLM │    │ TTS  │
    │(음성)│    │(응답)│    │(음성)│
    └────┬─┘    └──┬──┘    └───┬──┘
         │        │           │
         └────┬───┴───────────┘
              │
         사용자 청취
```

### 16.2 구현 계획 (MVP 이후)

```
Phase 1: 기본 음성 지원
├─ STT: Web Speech API (무료, 온디바이스)
├─ TTS: Web Audio API + Google TTS
├─ 통화 UI: 폰 통화처럼 시뮬레이션
└─ 응답 속도: 3-5초

Phase 2: 고도화
├─ STT: Google Cloud Speech-to-Text
├─ TTS: Amazon Polly (더 자연스러운 음성)
├─ 음성 인식률 개선
└─ 방언/억양 대응

[우선순위: 낮음 (현실성 고려)]
```

---

## 17. 증거 수집 로직

### 17.1 증거 타입 정의

```
증거 카테고리

1. 발신자 정보
   ├─ phone_number: "010-XXXX-XXXX"
   ├─ name: "엄마", "택배사원" 등
   └─ email: "scammer@fake.com" (가능한 경우)

2. 금전 정보
   ├─ amount_mentioned: 500,000원 등
   └─ account_number: "123-456-789"

3. 링크/URL
   ├─ suspicious_url: "https://fake-bank.com"
   └─ shorturl: "bit.ly/..."

4. 기관 사칭 내용
   ├─ impersonation_type: "은행", "경찰" 등
   └─ impersonation_detail: "신용카드 한도 증가"

5. 행동 증거
   ├─ urgency: "지금 바로", "급함"
   ├─ tone_unnatural: "말투가 어색함"
   └─ information_pattern: "먼저 상황 설명"

6. 기타
   ├─ transaction_request: "송금 요청"
   └─ personal_info_request: "신원 정보 요청"
```

### 17.2 자동 추출 로직

```python
class EvidenceExtractor:
  def extract_from_message(self, message: str, context) -> List[Evidence]:
    evidence_list = []
    
    # 1. 패턴 기반 추출
    phone_pattern = r'\d{3}-\d{4}-\d{4}'
    if match := re.search(phone_pattern, message):
      evidence_list.append(Evidence(
        type='phone_number',
        value=match.group(),
        source='pattern_match',
        importance=3
      ))
    
    # 2. 키워드 기반 추출
    urgency_keywords = ["지금", "바로", "서두르다", "급함"]
    if any(kw in message for kw in urgency_keywords):
      evidence_list.append(Evidence(
        type='urgency',
        value="긴급함을 강조",
        source='keyword_match',
        importance=2
      ))
    
    # 3. NER 기반 추출 (NLP)
    entities = nlp.extract_entities(message)
    for entity in entities:
      if entity.type == 'ORG':  # 조직/기관
        evidence_list.append(Evidence(
          type='organization',
          value=entity.text,
          source='ner',
          importance=3
        ))
    
    return evidence_list

  def calculate_collection_percentage(self, collected, all_possible) -> int:
    return (len(collected) / len(all_possible)) * 100
```

### 17.3 증거 평가 점수

```
각 증거의 중요도 (1-5점 척도):

5점 (매우 중요)
├─ 계좌번호 (금융사기)
├─ "송금하세요" 명시
├─ 개인 인증정보 요청
└─ 기관명 + 거짓 정보

4점 (중요)
├─ 전화번호
├─ 급함 표현
├─ 신원 사칭 명시
└─ URL/링크

3점 (보통)
├─ 말투 이상
├─ 상황 설명 요청
└─ 이메일 주소

1-2점 (보조)
├─ 기타 추측 정보
└─ 맥락상 의심 사항

수집률 평가:
├─ 90-100%: +40XP
├─ 80-89%: +30XP
├─ 70-79%: +20XP
└─ 70% 미만: +10XP
```

---

## 18. 리포트 생성 방식

### 18.1 리포트 구조

```
┌──────────────────────────────────────┐
│   AI가 생성하는 종합 평가 리포트      │
└──────────────────────────────────────┘

1️⃣ 대응 능력 평가
   - 판단 정확도: "우수" (정확히 식별)
   - 판단 시점: "2번째 메시지 때 의심"
   - 대응 방식: "정보 과다 제공 피함" ✓
   
2️⃣ 증거 수집 분석
   - 수집률: 85% (5/6개)
   - 수집한 증거: 
     • ✓ 송신자 번호: 010-XXXX-5678
     • ✓ "엄마" 사칭
     • ✓ 급함 표현: "지금 바로"
     • ✓ 말투 어색
     • ✗ 계좌번호 (미수집) ← 놓친 중요 증거!
   
3️⃣ 신고 대처 평가
   - 경찰 신고: "완벽함" (필요 정보 모두 제시)
   - 은행 대응: "완벽함" (지급정지 요청 적절)
   
4️⃣ 별 평가
   ⭐⭐⭐ (3/3) - 88점
   
5️⃣ 교육적 피드백
   "당신은 피싱을 빠르게 식별했습니다. 
    다만 가족 사칭의 계좌번호는 매우 중요한 증거입니다.
    더 오래 대화를 유지하며 계좌 정보를 유도해보세요!"
   
6️⃣ 개인 취약점 분석
   "지금까지 당신의 훈련 데이터:
    - 가족 사칭: 82% 정확도 (강점)
    - 금융사기: 65% 정확도 (약점)
    - 평균: 75% 정확도"
   
7️⃣ 다음 추천
   "금융기관 사칭 훈련을 추천합니다.
    Chapter 4에서 보강하세요!"
   
8️⃣ 보상 계산
   Base XP: 150
   ⭐⭐⭐ Bonus: +70
   힌트 미사용: +20
   증거 85% 수집: +35
   신고 완벽: +50
   ─────────────
   Total: +325 XP 🎉
   
   레벨: Lv.5 → Lv.6 업!
   새 레벨업 보상: 힌트 +5개, 코인 +100
```

### 18.2 리포트 생성 프롬프트

```
당신은 피싱 교육 훈련 평가 전문가입니다.
사용자의 시나리오 플레이 기록을 분석하여 
구체적이고 건설적인 피드백을 제공합니다.

플레이 데이터:
- 시나리오 유형: {scenario_type}
- 대화 내용: {conversation_history}
- 판단 (피싱 여부): {user_judgment} (정답: {correct_answer})
- 판단 시점: {judgment_turn}번째 메시지
- 수집한 증거: {collected_evidence}
- 평가 점수: {score}/100

평가 프레임:
1. 대응 능력 (정확도, 시점, 안전성)
2. 증거 수집 (수집률, 놓친 증거, 중요도)
3. 신고 대처 (경찰, 은행 대응의 완성도)
4. 점수 계산 (위 3개 항목의 합산)
5. 교육적 피드백 (칭찬 + 개선점)
6. 취약점 분석 (전체 훈련 데이터 기반)
7. 다음 추천 (이 사용자가 집중해야 할 Chapter)

응답 형식 (JSON):
{
  "accuracy_evaluation": "...",
  "evidence_analysis": {
    "collection_percentage": 85,
    "collected": [...],
    "missed": [...],
    "tips": "..."
  },
  "report_handling": "...",
  "score_breakdown": {...},
  "educational_feedback": "...",
  "weakness_analysis": "...",
  "next_recommendation": "...",
  "xp_reward_breakdown": {...}
}
```

---

## 19. 차별성

### 19.1 경쟁사와의 비교

| 항목 | 기존 포스터 | 객관식 퀴즈 | 웹 시뮬레이터 | **Phishing Defense** |
|------|-----------|-----------|------------|-------------------|
| **상호작용** | 없음 | 선택지만 | 제한적 | **자유로운 대화** ✓ |
| **현실성** | 낮음 | 낮음 | 보통 | **AI 범죄자 행동** ✓ |
| **게임화** | 없음 | 약함 | 보통 | **레벨, XP, 별, 업적** ✓ |
| **개인화** | 없음 | 없음 | 없음 | **AI 맞춤 훈련** ✓ |
| **신고 학습** | 없음 | 없음 | 없음 | **경찰·은행 AI 포함** ✓ |
| **피드백** | 없음 | 정답 알려줌 | 기본적 | **AI 상세 분석** ✓ |

### 19.2 핵심 차별점

```
1️⃣ AI 범죄자와의 자유 대화
   └─ "당신이 어떻게 대응하느냐"에 따라 AI가 반응
   └─ 객관식이 아니라 자신의 전략 시도 가능
   └─ 실제 범죄자처럼 행동하는 AI

2️⃣ 게임 시스템의 완성도
   └─ 단순 점수가 아닌 레벨, 업적, 리더보드
   └─ "피싱 헌터가 되고 싶다"는 욕구 자극
   └─ 교육이 아닌 게임처럼 느껴짐

3️⃣ 신고까지의 완전한 사이클
   └─ 발견 → 대응 → 신고 → 회수 모든 과정
   └─ 실제 할 수 있는 행동까지 훈련

4️⃣ AI 맞춤형 성장
   └─ 사용자 약점을 자동으로 감지
   └─ "당신은 금융사기에 약하다" 데이터 기반 피드백
   └─ 플레이할수록 더 정교한 훈련

5️⃣ 증거 수집의 재미
   └─ 게임의 "수집" 요소 (포켓몬, 도감)
   └─ 증거 100% 수집에 대한 별도 업적
   └─ 각 증거의 중요도 명시 + 교육
```

---

## 20. 향후 확장성

### 20.1 Phase 2 (3개월 후)

```
✨ 통화 모드 (Voice)
├─ STT/TTS로 음성 대화 지원
├─ "실제 전화받는 것처럼"의 경험
└─ 난이도 +50% (음성 이해 필요)

🤝 멀티플레이 모드
├─ 친구와 함께 훈련 (협력/경쟁)
├─ 조직 내 팀 대전
└─ 클랜 시스템 (회사별 리더보드)

📊 Advanced Analytics
├─ 개인별 정밀 취약점 분석
├─ 인지 패턴 감지 (이 유형을 항상 실수)
└─ 추천 맞춤형 시나리오 확대

🎬 영상 통화 모드
├─ 범죄자의 얼굴 (AI 생성 영상)
├─ 더욱 높은 현실성
└─ 심리적 압박감 재현
```

### 20.2 Phase 3 (6개월 후)

```
🌍 국제화
├─ 다국어 지원 (영어, 중국어 등)
├─ 국가별 피싱 유형 맞춤화
└─ 글로벌 리더보드

🤖 ML 기반 개인화
├─ 사용자 행동 패턴 학습
├─ 피싱 취약 심리 분석
├─ 완전 자동 맞춤 시나리오 생성
└─ 시간별 최적화 훈련

🏢 Enterprise 버전
├─ 조직 관리 대시보드
├─ 직원 교육 진행 추적
├─ 커스텀 시나리오 (조직 특성)
├─ 정책 기반 강제 교육
└─ 보안 리포트 자동 생성

💰 스토어 & 아이템
├─ 힌트 팩 구매
├─ 프리미엄 배지
├─ VIP 멤버십 (광고 제거 등)
└─ 기업 라이선스 판매
```

### 20.3 API 개방 & 파트너십

```
B2B 모델
├─ 은행 & 금융기관: 자체 플랫폼 임베드
├─ 보험사: 보험료 할인 연동
├─ 공공기관: 국민 교육 프로그램
└─ 기업: 직원 보안 교육 서비스

API 공개 (Phase 3)
├─ Scenario Generation API
├─ Chat Response API
├─ Report Generation API
└─ Analytics API (데이터 제공)
```

---

## 21. 발표 시 강조 포인트

### 21.1 Problem-Solution 명확성

```
❌ 문제
"포스터나 영상으로 배운 피싱 수법, 실제 상황에선 못 대응합니다."

✅ 해결책
"AI와 실제처럼 대화하며 대응 능력을 게임처럼 기르세요."

💡 핵심 통찰
"교육은 지루한데, 게임은 중독적입니다. 
 게임처럼 재미있는 교육이 답입니다."
```

### 21.2 게이미피케이션 강조

```
🎮 "이것은 교육이 아닌 게임입니다."

- 레벨, XP, 별 → 성장의 재미
- 업적, 리더보드 → 경쟁의 재미
- 피싱 도감 → 수집의 재미
- 일일 미션 → 매일 하고 싶은 동기

결과: 사용자가 "교육받는 느낌"을 안 느낌
     → 자연스럽게 능력 향상
```

### 21.3 기술적 혁신

```
🤖 핵심 기술

1. AI 기반 자유 대화
   └─ 객관식 X, 범죄자처럼 반응하는 LLM

2. 증거 자동 추출
   └─ NER + 패턴 매칭으로 게임플레이 중 학습

3. 동적 리포트 생성
   └─ AI가 사용자 성과를 분석하여 피드백

4. 맞춤형 훈련 추천
   └─ 데이터 기반 약점 자동 감지
```

### 21.4 시장 기회

```
📈 TAM (Total Addressable Market)

국내:
├─ 기업 직원 교육: 약 2,000만명
├─ 정부 기관: 중앙부처 + 지방청
├─ 일반인: 피싱 예방 필요 인구 약 3,000만명
└─ 추정 시장규모: 수십억원~수백억원

글로벌:
├─ 사이버보안 교육 시장: 연 10% 성장
├─ 게임화 기반 교육: 새로운 카테고리
└─ 확장 가능성: 무한대
```

### 21.5 비즈니스 모델

```
B2C (개인)
├─ 무료 기본 플레이 + 프리미엄 결제
├─ 광고 제거, 추가 힌트 등
└─ 월 3~5달러 (게임 기준)

B2B (기업/기관)
├─ 직원 교육용 라이선스
├─ 조직별 커스텀 시나리오
├─ 리포트/분석 기능
└─ 월 1만~10만원 (직원수 기반)

수익화 예상:
Year 1: 0 (MVP 검증)
Year 2: $50K~100K (초기 사용자)
Year 3: $1M+ (기관 채택)
```

### 21.6 한 문장 피치

```
"AI 범죄자와 대화하며 피싱을 경험하고,
 게임을 플레이하듯 레벨 업하며
 실제 대응 능력을 갖추는
 최초의 게임형 피싱 교육 플랫폼"
```

---

## 22. 개발 우선순위 (MVP / 확장 기능)

### 22.1 MVP (최소 기능 제품) - 4주

#### 우선순위: 필수 (P0)

```
✅ 인증
└─ 이메일 기반 회원가입 & 로그인

✅ 기본 게임플레이
├─ Chapter 1 (기초 스미싱): 1개 시나리오
├─ Stage 1-6 전체 흐름
│  ├─ SMS 수신
│  ├─ AI 채팅 (2-3회 턴)
│  ├─ 피싱 판단 (정답/오답 분기)
│  ├─ 증거 수집 화면
│  ├─ 신고 (경찰 채팅만)
│  └─ 기본 리포트
│
├─ AI 채팅 엔진
│  ├─ GPT-4 기반 LLM 통합
│  └─ 범죄자 페르소나 프롬프트
│
└─ 증거 자동 추출
  ├─ 정규식 기반 패턴 (전화번호, 금액)
  └─ 키워드 매칭

✅ 게임 시스템 (기본)
├─ XP & 레벨 (1-30)
├─ 별 평가 (0-3)
├─ 기본 리포트 (자동 계산)
└─ 간단한 UI

✅ 데이터베이스
├─ User, Chapter_Progress, Scenario_Records
├─ Chat_History, Evidence
└─ MySQL 기본 구성

✅ Frontend (React)
├─ 홈 대시보드 (간단)
├─ 게임플레이 화면
├─ 결과 화면
└─ 반응형 디자인 (웹 + 모바일)

✅ Backend (Spring Boot)
├─ REST API (게임플레이)
├─ 인증 (JWT)
├─ AI 통합 (LLM 호출)
└─ 데이터 저장/조회

⏱️ 예상 기간: 4주
👥 필요 인력: Frontend 1 + Backend 1 + PM 1

배포: Web (사파리/크롬 모두 지원)
```

#### 테스트 체크리스트 (MVP)

```
✓ Chapter 1 완주 가능
✓ AI 응답 자연스러움 (3회 이상 테스트)
✓ 별 평가 계산 정확성
✓ XP 획득 정상 작동
✓ 증거 추출 >80% 정확도
✓ 모바일 UI 정상 작동
✓ 데이터 저장 확인
```

---

### 22.2 Phase 1-1 (2주, MVP 개선)

#### 우선순위: 높음 (P1)

```
✅ Chapter 확장
├─ Chapter 2-3 추가 (각 1개 시나리오)
└─ Chapter 진행 시 잠금/해제 로직

✅ 게임 시스템 확장
├─ 업적 10개 기본 구현
├─ 연속 출석 (7일, 14일)
└─ 일일 미션 (고정 미션만)

✅ UI 개선
├─ 홈 대시보드 풀 구현
├─ 프로필 & 통계 화면
└─ 시각적 피드백 개선 (애니메이션)

✅ 알림 & 푸시
├─ 레벨 업 알림
├─ 업적 달성 알림
└─ 웹 push (선택)

✅ 소셜 기능
├─ 친구 추가 (수동 ID 검색)
├─ 간단한 리더보드 (전체 Top 100)
└─ 점수 공유 (URL)

⏱️ 예상 기간: 2주
```

---

### 22.3 Phase 1-2 (3주, 핵심 확장)

#### 우선순위: 높음 (P1)

```
✅ 더 많은 Chapter
├─ Chapter 4-5 추가
├─ 각 Chapter 3-5개 시나리오
└─ 총 15+ 시나리오

✅ AI 고도화
├─ 다양한 범죄자 페르소나
├─ 상황별 AI 난이도 조절
├─ 응답 다양성 증가

✅ 증거 시스템 고도화
├─ NER 모델 추가 (엔터티 인식)
├─ 10+ 증거 타입 지원
└─ 자동 분류 정확도 개선

✅ 리포트 AI 생성
├─ LLM으로 동적 리포트 생성
├─ 맞춤형 피드백 포함
└─ 취약점 분석 추가

✅ 신고 두 번째 AI
├─ 은행 AI 추가 (경찰 이외)
└─ 2단계 신고 시뮬레이션 완성

✅ 맞춤형 훈련
├─ 사용자 약점 분석
├─ 동적 미션 생성
└─ 추천 Chapter 로직

⏱️ 예상 기간: 3주
👥 추가 필요: ML 엔지니어 (선택) 또는 NLP 라이브러리 활용
```

---

### 22.4 Phase 2 (이후 1-2개월)

#### 우선순위: 중간 (P2)

```
🎤 STT/TTS 음성 기능
├─ Web Speech API 기반 STT
├─ Google TTS 통합
├─ 음성 통화 UI
└─ 난이도 +50%

🌍 국제화
├─ 다국어 지원 (영어 우선)
├─ 국가별 시나리오 커스터마이징
└─ 로컬라이제이션

🤝 멀티플레이
├─ 협력 모드 (친구와 함께)
├─ 경쟁 모드 (실시간 대전)
└─ 팀 리더보드

📊 고급 분석
├─ 심화 통계 (인지 패턴)
├─ 비교 분석 (친구 vs 나)
└─ 진행 추적 대시보드

💰 스토어 & 아이템
├─ 힌트 팩 (코인 구매)
├─ 프리미엄 배지
└─ 광고 제거 (간단한 결제 시스템)

⏱️ 예상 기간: 4-8주
```

---

### 22.5 개발 로드맵 요약

```
Week 1-4: MVP 완성 (Chapter 1, 기본 게임 시스템)
├─ Go Live: 내부 테스트 & 친구 초대

Week 5-6: Phase 1-1 (Chapter 확장, 게임 재미)
├─ 공식 출시 (작은 규모)

Week 7-9: Phase 1-2 (AI 고도화, 증거/신고 완성)
├─ 기관 파일럿 시작

Week 10-13: Phase 2 (확장 기능)
├─ 전국 서비스 확대

Month 4+: Phase 3 (국제화, B2B 모델)
├─ 글로벌 확장
```

---

### 22.6 비용 추정

#### MVP (4주)

```
개발비용:
├─ Frontend 개발: 1인 × 4주 × $100/시간 = $16,000
├─ Backend 개발: 1인 × 4주 × $100/시간 = $16,000
├─ PM & 기획: 1인 × 4주 × $80/시간 = $12,800
└─ 소계: $44,800

API 비용:
├─ LLM (GPT-4): 초기 10만 쿼리 = $500~1,000
├─ DB 호스팅: AWS/GCP = $300/월 × 1 = $300
└─ 소계: $1,000

총 MVP 비용: ~$46,000

Full Product (12주):
└─ $150,000~200,000 (개발 확대)
```

---

## 요약

**Phishing Defense**는 단순한 교육 플랫폼이 아니라 **게임형 피싱 대응 시뮬레이션**입니다.

### 핵심 성공 요소

1. **AI 범죄자와의 자유로운 대화**
   - 객관식 아님 → 자신의 전략 시도 가능
   - 실제 범죄자처럼 행동하는 LLM

2. **완전한 게임 시스템**
   - 레벨, XP, 별, 업적 → 게임처럼 느껴짐
   - 교육이 아니라 중독적인 게임플레이

3. **신고까지의 완전한 사이클**
   - 발견 → 대응 → 신고 → 회수
   - 실제 할 수 있는 모든 행동 훈련

4. **AI 맞춤형 성장**
   - 데이터 기반 약점 감지
   - 플레이할수록 더 정교한 훈련

5. **높은 확장성**
   - MVP에서 Phase 3까지 명확한 로드맵
   - B2C, B2B 모두 가능한 비즈니스 모델

이 시스템이 성공한다면, 피싱 교육의 패러다임을 완전히 바꾸게 될 것입니다.

---

**문서 생성 완료**

이제 이 기획서를 바탕으로 실제 개발을 시작할 수 있습니다. 
필요한 추가 상세 설계 (예: 디자인 시스템, API 엔드포인트 전체 목록)는 개발 과정에서 작성하시기 바랍니다.
