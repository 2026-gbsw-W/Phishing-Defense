# Phishing Defense — Design System

**기준 파일**: `/index.html` (랜딩 페이지)
**목적**: 이 문서는 `index.html`에서 확정된 비주얼 언어를 다른 모든 페이지(웹 프론트엔드 컴포넌트, 추가 랜딩/마케팅 페이지 등)에 동일하게 적용하기 위한 레퍼런스입니다. 새 페이지를 만들 때는 이 문서의 토큰과 패턴을 그대로 재사용하세요 — 색상 값, 폰트, border-radius, 애니메이션 타이밍을 임의로 다시 정하지 마세요.

이 문서만 보고도 `index.html`을 다시 안 봐도 동일한 톤의 페이지를 만들 수 있도록, 모든 수치를 실제 코드값 그대로 적었습니다.

---

## 0. 디자인 원칙 (반드시 지킬 것)

1. **다크 테마 고정.** 밝은 배경 버전은 없음. `--bg: #08060a`가 항상 베이스.
2. **레드(`--alarm`)가 유일한 액센트 컬러.** 그린(`--safe`)은 브랜드 컬러가 아니라 "실제 UI 관례를 따라야 하는 경우"에만 예외적으로 씀 (예: iOS 전화 수락 버튼의 초록색). 새로운 액센트 컬러를 추가하지 말 것.
3. **이모지 절대 금지.** 아이콘이 필요하면 (a) 이니셜 문자를 원/사각 배지에 넣거나, (b) 인라인 SVG를 직접 그리거나, (c) 숫자/라벨(`CHAPTER 01`, `01` 등 실제 순서가 있는 경우에만) 을 쓴다.
4. **모서리는 날카롭게.** 콘텐츠 카드의 `border-radius`는 **4px** 로 통일한다 (`border-radius: 16px` 같은 큰 값은 "AI가 만든 듯한 rounded-lg 템플릿" 느낌을 주므로 금지). 대신 카드 상단에 얇은 레드 액센트 보더(`border-top: 2px solid rgba(255,69,63,0.4~0.6)`)를 넣어 카드를 구분한다. 예외: 알약형 버튼/태그(`border-radius:100px`)와 폰 목업 베젤(46~56px, 실물 기기라서 큰 라운드가 맞음)은 그대로 둔다.
5. **센터 정렬을 기본값으로 쓰지 않는다.** 히어로(도입부)만 중앙 정렬이고, 그 아래 모든 섹션 헤드/본문/카드는 **좌측 정렬**이 기본이다. 좌우 대칭 2단만 반복되는 레이아웃(옛 "text-left/image-right 히어로" 같은 패턴)도 피하고, 벤토 그리드처럼 비중이 다른 배치를 우선한다.
6. **폰트는 IBM Plex Mono + Noto Sans KR만 사용.** `Space Grotesk`, `Inter` 등 "AI가 기본으로 고르는 안전한 폰트"는 쓰지 않는다 (이유는 §2 참고).
7. **확인되지 않은 데이터/후기를 만들지 않는다.** 모든 통계는 `docs/PROJECT_PROPOSAL.md` 등 실제 기획 문서에서 가져오고 출처를 명시한다. 가짜 사용자 후기, 가짜 고객 로고, 가짜 위험도(%) 숫자 등은 절대 넣지 않는다. 목표치처럼 아직 검증되지 않은 수치는 반드시 "*목표 수치이며 검증 예정" 같은 단서를 함께 표기한다.
8. **자기완결형(self-contained) 파일.** 외부 이미지 URL, 아이콘 폰트 CDN, JS 프레임워크에 의존하지 않는다. 유일하게 허용된 외부 의존성은 Google Fonts 링크(§2)뿐이다. 아이콘은 인라인 SVG 또는 CSS로 직접 그린다.
9. **모션은 항상 `prefers-reduced-motion: reduce`를 존중한다.** 모든 애니메이션/스크롤 이펙트에는 reduced-motion 분기 처리가 있어야 한다 (구현 패턴은 §7 참고).

---

## 1. 컬러 토큰

`:root`에 정의하고 항상 `var(--token)`으로 참조한다. 이 값들을 그대로 복사해서 쓸 것.

```css
:root {
  --bg: #08060a;              /* 페이지 배경 */
  --surface: #14101a;         /* 카드 배경 (1단계) */
  --surface-2: #1c1622;       /* 카드 배경 (강조/내부 배지 등, 2단계) */
  --line: rgba(255, 255, 255, 0.08);   /* 기본 테두리 */
  --text: #f5f3f6;            /* 기본 텍스트 (거의 흰색) */
  --text-dim: #9a92a3;        /* 보조/설명 텍스트 */
  --alarm: #ff453f;           /* 유일한 브랜드 액센트 (레드) */
  --alarm-dim: rgba(255, 69, 63, 0.12);  /* 레드 배경 틴트 */
  --safe: #29c784;            /* 예외적으로만 사용 (§0-2 참고) */
  --safe-dim: rgba(41, 199, 132, 0.12);
  --amber: #f5a623;           /* 문자 스팸 발신자 라벨 등 경고성 보조색 */
  --hexline: rgba(255, 69, 63, 0.16);  /* 헥사곤 배경 패턴 선 색 */
  --hexfill: rgba(255, 69, 63, 0.04);  /* 헥사곤 배경 패턴 채움 색 */
}
```

**색상 사용 규칙**
- 버튼 텍스트가 `--alarm` 배경 위에 올 때는 `#2a0806` (진한 브라운블랙)을 쓴다. 흰색 텍스트를 쓰지 않는다 — 레드 위에 거의-검정을 쓰는 것이 브랜드 룩이다.
- `--text-dim`은 모든 본문/설명 텍스트의 기본값. `--text`(거의 흰색)는 제목, 강조, 버튼에만 쓴다.
- 새 의미색이 필요해도(경고/성공 등) 먼저 `--alarm`/`--amber`/`--safe`로 표현 가능한지 검토한다. 새 CSS 변수를 함부로 추가하지 않는다.

---

## 2. 타이포그래피

### 폰트 로드 (모든 페이지 `<head>`에 동일하게 삽입)

```html
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link
  href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@500;600;700&family=Noto+Sans+KR:wght@400;500;700;900&display=swap"
  rel="stylesheet"
/>
```

### 역할 분리
| 용도 | 폰트 | 적용 방법 |
|---|---|---|
| 본문/제목 전체 기본값 | Noto Sans KR | `body { font-family: "Noto Sans KR", sans-serif; }` — 별도 클래스 불필요 |
| 숫자, 라벨, 뱃지, 통계, 스테이터스바, 이지브로우 텍스트 | IBM Plex Mono | `.mono` 클래스 또는 해당 컴포넌트 CSS에 `font-family: "IBM Plex Mono", monospace;` 직접 지정 |

**왜 IBM Plex Mono인가**: `Space Grotesk`나 `Inter`는 AI가 별다른 지시 없을 때 가장 먼저 고르는 "안전한" 폰트로 알려져 있어, 그대로 쓰면 "AI가 만든 페이지" 느낌이 강해진다. 대신 모노스페이스 폰트는 보안/기술 제품(터미널, 대시보드, 위협 인텔리전스 로그)의 톤과도 잘 맞아서 오히려 이 프로젝트의 주제(피싱/보안)에 더 어울린다. **다른 모노 폰트로 임의 교체 금지.**

### 스케일

```css
h1 { font-size: 50px; font-weight: 900; line-height: 1.2; letter-spacing: -0.02em; }
h1 .accent { color: var(--alarm); }  /* 헤드라인 안 강조 단어 */
@media (max-width: 720px) { h1 { font-size: 32px; } }

h2 { font-size: 32px; font-weight: 900; letter-spacing: -0.02em; line-height: 1.3; }
@media (max-width: 720px) { h2 { font-size: 25px; } }
```

- 본문(`p`)은 섹션마다 다르지만 대체로 `13.5px~17px`, 색은 `var(--text-dim)`.
- 큰 통계 숫자는 `.mono` + `font-weight:700` + `letter-spacing:-0.02em`, 크기는 맥락에 따라 38~84px.
- 굵기는 900(제목/통계)과 700(부제/버튼/카드 제목) 두 단계만 쓴다. 500은 거의 안 씀.

---

## 3. 레이아웃 시스템

### 컨테이너

```css
.wrap {
  max-width: 1120px;
  margin: 0 auto;
  padding: 0 32px;
}
@media (max-width: 720px) {
  .wrap { padding: 0 20px; }
}
```

모든 섹션의 콘텐츠는 `.wrap` 안에 넣는다. 전체 화면 폭으로 뻗어야 하는 배경 장식(헥사곤 패턴, 발광선)만 `.wrap` 바깥에 두고, **실제 색이 있는 콘텐츠 블록(배너 등)은 반드시 `.wrap`으로 감싸서 좌우 여백을 준다** — 화면 전체 폭을 꽉 채우는 블록은 다른 콘텐츠와 비교했을 때 "혼자 튀어" 보인다 (실제로 CTA 배너를 풀블리드로 뒀다가 이 문제로 다시 `.wrap`에 넣은 적 있음).

### 브레이크포인트

프로젝트 전역에서 이 4개만 쓴다. 임의의 다른 값(예: 900px, 1024px)을 새로 만들지 않는다.

| 값 | 용도 |
|---|---|
| `720px` | 기본 모바일 전환점. 대부분의 2단 레이아웃이 1단으로 바뀌고, 헤드라인 폰트가 축소되고, 배경 발광선/커브 라인이 숨겨짐 |
| `960px` | 5열 그리드(사기 유형 카드)가 3열로 줄어드는 지점 |
| `600px` | 3열 그리드가 1열로 완전히 쌓이는 지점 |
| `480px` | 폰 목업 자체 크기가 축소되는 지점 |

### 섹션 기본 패딩

```css
.section { padding: 96px 0; }
.section-head { max-width: 560px; margin-bottom: 52px; }  /* 좌측 정렬, 중앙 정렬 아님 */
.section-eyebrow {
  font-family: "IBM Plex Mono", monospace;
  font-size: 12px;
  letter-spacing: 0.12em;
  color: var(--alarm);
  margin-bottom: 14px;
}
```

`section-head` 안에는 항상 `.section-eyebrow`(영문 대문자 라벨, 예: `HOW IT HAPPENS`, `WHY 피싱 디펜스`) + `<h2>` 순서로 넣는다. 이 라벨은 실제 섹션 성격을 요약하는 짧은 영문(또는 영문+한글 혼합) 문구여야 하며 장식이 아니다.

---

## 4. 배경 텍스처 — 헥사곤 패턴 (`.hex-bg`)

순수 CSS만으로 만든 육각형 그리드 텍스처. 이미지 파일 없이 배경 장식이 필요할 때 항상 이걸 재사용한다 (새로운 패턴을 만들지 말 것).

```css
.hex-bg {
  background-image: linear-gradient(30deg, var(--hexline) 12%, transparent 12.5%, transparent 87%, var(--hexline) 87.5%, var(--hexline)),
    linear-gradient(150deg, var(--hexline) 12%, transparent 12.5%, transparent 87%, var(--hexline) 87.5%, var(--hexline)),
    linear-gradient(30deg, var(--hexline) 12%, transparent 12.5%, transparent 87%, var(--hexline) 87.5%, var(--hexline)),
    linear-gradient(150deg, var(--hexline) 12%, transparent 12.5%, transparent 87%, var(--hexline) 87.5%, var(--hexline)),
    linear-gradient(60deg, var(--hexfill) 25%, transparent 25.5%, transparent 75%, var(--hexfill) 75%, var(--hexfill)),
    linear-gradient(60deg, var(--hexfill) 25%, transparent 25.5%, transparent 75%, var(--hexfill) 75%, var(--hexfill));
  background-size: 44px 76px;
  background-position: 0 0, 0 0, 22px 38px, 22px 38px, 0 0, 22px 38px;
}
```

**사용 규칙**
- 절대 원본 그대로(불투명하게) 큰 면적에 쓰지 않는다 — 반드시 `opacity`를 낮추고(카드 안 장식은 `0.12`, 섹션 배경은 `0.3` 정도) `mask-image: radial-gradient(...)`로 가장자리를 흐리게 페이드아웃시켜야 한다. 마스크 없이 opacity만 낮추면 사각형 경계가 딱 잘려 보여 어색하다.
- 카드 안에 쓸 때: `position:absolute; inset:0; opacity:0.12;` + 좌상단이나 우상단 쪽에 치우친 `radial-gradient(ellipse at 30% 30%, black, transparent 75%)` 마스크.
- 히어로의 폰 뒤 후광처럼 "은은하게 퍼지는" 느낌이 필요하면 **레이어드 블러 기법**을 쓴다 (아래).

### 레이어드 라디얼 블러 (방사형 블러 후광)

한 겹짜리 blur는 "중심은 흐릿, 가장자리는 뚝 끊김"이 되어 부자연스럽다. 대신 같은 `.hex-bg`를 3겹 쌓고 각각 블러/마스크 반경을 다르게 줘서 중심은 선명 → 바깥으로 갈수록 점점 흐려지게 만든다.

```html
<div class="hex-halo">
  <div class="hex-layer layer-3 hex-bg"></div>  <!-- 가장 바깥, 가장 흐림 -->
  <div class="hex-layer layer-2 hex-bg"></div>
  <div class="hex-layer layer-1 hex-bg"></div>  <!-- 가장 안쪽, 선명 -->
</div>
```

```css
.hex-halo { position: absolute; width: 900px; height: 900px; }
.hex-layer { position: absolute; inset: 0; }
.hex-layer.layer-1 {
  filter: blur(0px);
  mask-image: radial-gradient(circle, black 18%, transparent 42%);
}
.hex-layer.layer-2 {
  filter: blur(7px);
  mask-image: radial-gradient(circle, black 30%, transparent 64%);
}
.hex-layer.layer-3 {
  filter: blur(18px);
  mask-image: radial-gradient(circle, black 22%, transparent 88%);
}
```
(각 `mask-image`에 `-webkit-mask-image` 동일하게 병기할 것 — Safari 호환)

---

## 5. 컴포넌트

### 5.1 네비게이션

```css
nav {
  position: sticky;
  top: 0;
  z-index: 50;
  background: rgba(8, 6, 10, 0.85);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid var(--line);
}
nav .wrap { display: flex; align-items: center; justify-content: space-between; height: 72px; }
```
- 로고 마크: 28×28 라운드 사각형(`border-radius:8px`), 배경 `--alarm-dim`, 안에 `::after`로 체크마크 모양(회전된 border) — 이모지/이미지 없이 CSS로만.
- 데스크톱: 로고(좌) / 네비 링크 3~4개(중앙~우) / CTA 버튼(우). 모바일(≤720px)에서는 `.nav-links` 숨김.

### 5.2 버튼

```css
.btn-primary { background: var(--alarm); color: #2a0806; border: none; padding: 15px 26px; border-radius: 10px; font-size: 15px; font-weight: 700; }
.btn-ghost   { background: transparent; color: var(--text); border: 1px solid var(--line); padding: 15px 22px; border-radius: 10px; font-size: 15px; }
.cta-btn     { background: var(--text); color: var(--bg); border: none; padding: 11px 20px; border-radius: 8px; font-size: 14px; font-weight: 700; }
```
버튼은 카드가 아니므로 4px 규칙(§0-4) 적용 대상이 아니다 — `8~10px` 라운드를 유지한다. 주요 CTA는 항상 `btn-primary` + `btn-ghost` 두 개를 짝으로 배치한다 (강한 CTA 하나만 단독으로 두지 않는다).

### 5.3 이지브로우 태그 (`.eyebrow`)

```css
.eyebrow {
  display: inline-flex; align-items: center; gap: 8px;
  font-family: "IBM Plex Mono", monospace; font-size: 12px; letter-spacing: 0.12em;
  color: var(--alarm); background: var(--alarm-dim);
  border: 1px solid rgba(255, 69, 63, 0.25);
  padding: 6px 12px; border-radius: 100px;
}
.eyebrow .dot { width: 6px; height: 6px; border-radius: 50%; background: var(--alarm); animation: pulse 1.6s infinite; }
@keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.25; } }
```
긴급성/실시간성을 강조하고 싶을 때만 쓴다 (예: "지금 이 순간에도 걸려오고 있습니다"). 남발하지 않는다 — 실제로 히어로에서 폰 목업과 겹쳐 가독성을 해쳐서 제거한 적이 있으니, 다른 콘텐츠와 겹치는 위치에는 배치하지 않는다.

### 5.4 카드 (콘텐츠 카드 공통 패턴)

**모든** 콘텐츠 카드(통계 타일, 유형 카드, 플로우 카드, 문자 목업 카드, CTA 요약 박스)는 이 패턴을 따른다:

```css
.some-card {
  position: relative;
  background: var(--surface);
  border: 1px solid var(--line);
  border-top: 2px solid rgba(255, 69, 63, 0.4);  /* 0.4~0.6 사이, 강조도에 따라 */
  border-radius: 4px;
  padding: <컨텍스트에 맞게>;
}
```
- `border-radius`는 항상 **4px**. 16px, 20px 같은 큰 값 금지(§0-4).
- 상단 레드 액센트 보더 두께는 항상 `2px`, 투명도만 조절(약한 카드 0.4, 강조 카드 0.6).
- 카드 안에 헥사곤 텍스처를 깔 때는 §4의 opacity 0.12 + 마스크 규칙을 따른다.

### 5.5 벤토형 통계 그리드 (`.why-grid` 패턴)

통계 3개를 똑같은 크기 카드 3개로 늘어놓지 않는다 (전형적인 "AI가 만든 3열 카드" 패턴). 가장 중요한 숫자 하나를 크게 강조하는 벤토 그리드를 쓴다:

```css
.why-grid { display: grid; grid-template-columns: 1.3fr 1fr; grid-auto-rows: 1fr; gap: 20px; }
.why-tile.featured { grid-row: 1 / 3; padding: 40px 34px; }  /* 2행 차지, 왼쪽에 크게 */
.why-num { font-family: "IBM Plex Mono", monospace; font-size: 38px; font-weight: 700; color: var(--alarm); }
.why-tile.featured .why-num { font-size: 62px; }
```
`@media (max-width:720px)`에서는 `grid-template-columns: 1fr; .why-tile.featured{grid-row:auto;}`로 단순 스택.

### 5.6 육각형 배지 (`.flow-badge`)

순서가 있는 프로세스/단계를 나타낼 때 쓰는 CSS `clip-path` 육각형. 숫자를 넣는다 (실제 순번이 있을 때만 — 장식용 숫자 금지, §0-3 참고).

```css
.flow-badge {
  width: 52px; height: 52px;
  display: flex; align-items: center; justify-content: center;
  clip-path: polygon(25% 4%, 75% 4%, 100% 50%, 75% 96%, 25% 96%, 0% 50%);
  background: var(--surface-2);
  border: 1px solid rgba(255, 69, 63, 0.45);
  color: var(--alarm);
  font-family: "IBM Plex Mono", monospace; font-weight: 700; font-size: 14px;
  box-shadow: 0 0 18px rgba(255, 69, 63, 0.22);
}
```
카드 상단에 `flow-card-head`(배지 + h4를 가로로 나란히)로 배치하고, 본문은 그 아래.

### 5.7 지그재그 프로세스 + 발광 커브 라인

3단계 이상의 "과정/흐름"을 보여줄 때 쓰는 시그니처 패턴. 카드를 좌/우로 번갈아 배치하고 (`.align-left`/`.align-right`, `margin-left:auto`로 우측 정렬), 카드들의 배지 중심을 잇는 **곡선 SVG 라인**을 JS로 실시간 계산해서 그린다.

```html
<div class="flow-diagram">
  <svg class="flow-svg" aria-hidden="true">
    <path class="flow-path-bg"></path>
    <path class="flow-path-glow"></path>
  </svg>
  <div class="flow-list">
    <div class="flow-row align-left"> ... <div class="flow-badge">01</div> ... </div>
    <div class="flow-row align-right"> ... <div class="flow-badge">02</div> ... </div>
    <div class="flow-row align-left"> ... <div class="flow-badge">03</div> ... </div>
  </div>
</div>
```

```css
.flow-row { max-width: 46%; }
.flow-row.align-right { margin-left: auto; }
.flow-path-bg { fill: none; stroke: rgba(255, 69, 63, 0.15); stroke-width: 1.5; }
.flow-path-glow {
  fill: none; stroke: rgba(255, 69, 63, 0.75); stroke-width: 3.5; stroke-linecap: round;
  filter: blur(2px) drop-shadow(0 0 10px rgba(255, 69, 63, 0.7)) drop-shadow(0 0 22px rgba(255, 69, 63, 0.4));
}
@media (max-width: 720px) {
  .flow-svg { display: none; }
  .flow-row, .flow-row.align-right { max-width: 100%; margin-left: 0; }
}
```

JS는 `.flow-badge` 요소들의 실제 화면 좌표를 읽어서 부드러운 3차 베지어 곡선(`d` 속성)을 만들고, 스크롤 위치에 따라 `stroke-dasharray`/`stroke-dashoffset`으로 선이 "그려지는" 애니메이션을 만든다. 전체 구현은 `index.html`의 두 번째 `<script>` 블록(`flow-svg` 관련) 참고 — 새 페이지에서 같은 패턴이 필요하면 그 스크립트를 그대로 복사해서 셀렉터만 바꾼다.

**중요한 버그 교훈**: 이런 JS로 생성한 장식 요소를 `document.body.appendChild()`로 추가하면 `<body>`의 맨 마지막 자식이 되어 나중에 그려지는 다른 모든 카드보다 **위에** 그려진다 (선이 카드를 가림). 반드시 `document.body.insertBefore(el, document.body.firstChild)`로 **맨 앞에** 삽입해서 모든 실제 콘텐츠보다 뒤에 깔리게 해야 한다.

### 5.8 카드 위 스포트라이트 (스크롤 연동 "빛이 지나가는" 효과)

발광선이 카드를 스쳐 지나갈 때 카드 위쪽이 살짝 밝아지는 효과. 카드 안에 다음 오버레이를 추가:

```html
<div class="some-card">
  <div class="card-light" aria-hidden="true"></div>
  ... 실제 콘텐츠 (position:relative; z-index:1;) ...
</div>
```

```css
.some-card { position: relative; overflow: hidden; }
.card-light {
  position: absolute; inset: 0; z-index: 0; pointer-events: none; opacity: 0;
  background: radial-gradient(ellipse 130% 70% at 50% -10%, rgba(255, 69, 63, 0.4), transparent 65%);
  transition: opacity 0.12s linear;
}
```
JS는 매 스크롤 프레임마다 "현재 발광선 위치"(문서 Y좌표)와 카드 중심 사이 거리를 계산해서 `opacity`를 0~1로 설정한다 (거리가 가까울수록 1). 구현은 `index.html`의 세 번째 `<script>`(card-light 관련) 참고.

### 5.9 페이지 전체를 관통하는 중앙 발광선 ("spine")

히어로부터 푸터까지 이어지는 얇은 세로선. 스크롤에 따라 위에서 아래로 "차오르며" 빛난다.

```css
.spine-base, .spine-glow {
  position: absolute; left: 50%; width: 1px; transform: translateX(-50%);
  pointer-events: none; z-index: 0;
}
.spine-base { background: rgba(255, 69, 63, 0.1); filter: blur(2px); }
.spine-glow {
  width: 5px; background: rgba(255, 69, 63, 0.65); filter: blur(5px);
  box-shadow: 0 0 22px rgba(255, 69, 63, 0.5), 0 0 44px rgba(255, 69, 63, 0.25);
  clip-path: inset(0 0 100% 0);  /* JS가 스크롤에 따라 이 값을 줄여서 "채운다" */
}
@media (max-width: 720px) { .spine-base, .spine-glow { display: none; } }
```

**규칙**
- 선이 통과하는 구간에 **꽉 찬 색 배경 블록**(예: CTA 배너처럼 배경 전체가 `--alarm`인 블록)이 있으면, 그 블록의 위/아래에서 선을 끊어야 한다 (32px 여백). 그렇지 않으면 선이 배경과 부딪혀 "긁힌 자국"처럼 보인다. `index.html`의 네 번째 `<script>`가 이 갭 처리를 포함한 3-세그먼트 버전이니 그대로 재사용한다.
- 이 선도 §5.7과 같은 이유로 `insertBefore(el, body.firstChild)`로 삽입해야 카드에 가려진다.
- 모바일(≤720px)에서는 항상 숨긴다 — 좁은 화면에서는 방해만 된다.

### 5.10 CTA 배너

```css
.cta-banner-section { padding: 48px 0; }  /* .wrap으로 감싸서 좌우 여백 확보 — 풀블리드 금지 */
.cta-banner {
  background: var(--alarm); color: #2a0806; padding: 32px; border-radius: 4px;
  display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 16px;
}
```
```html
<div class="cta-banner-section">
  <div class="wrap">
    <div class="cta-banner">
      <div class="headline mono">지금 바로 무료로 훈련 시작하기</div>
      <a href="#">시작하기 →</a>
    </div>
  </div>
</div>
```

### 5.11 폰 목업 (실제 아이폰 수신 전화 화면)

히어로의 시그니처 비주얼. 실제 아이폰 잠금화면 수신 전화 UI를 최대한 사실적으로 재현한다. 핵심 구조:

- **프레임**: `width:300px; height:624px; border-radius:56px;` 티타늄 톤 다단 그라디언트(`linear-gradient(160deg, #55555c 0%, #2c2c32 14%, #1b1b20 45%, #0c0c0e 85%)`), `padding:3px`(베젤 두께), 근접+원거리 2겹 그림자 + 인셋 하이라이트/셰도우.
- **버튼**: 좌측에 무음 스위치 + 볼륨업 + 볼륨다운(각각 별도 요소, `::before`/`::after` + 실제 div 하나), 우측에 전원 버튼. 전부 `linear-gradient(90deg, #050506, #333338 40~60%, #050506)` + `box-shadow: inset 0 1px 0 rgba(255,255,255,0.15)`.
- **다이나믹 아일랜드**: `width:96px; height:26px; border-radius:100px; background:#000;` 안에 작은 카메라 렌즈 점(`::after`, radial-gradient).
- **화면 반사광**: 두 방향 대각선 `linear-gradient` 겹침 (115deg + 300deg), 낮은 opacity(0.05~0.1).
- **수신 전화 화면 레이아웃** (`.call-screen`, `position:absolute; justify-content:space-between;`로 상/하 분리):
  - 상단(`.call-top`): 작은 시나리오 라벨(mono, `.incoming-tag`) → 원형 아바타(112px, 이니셜 문자) → 발신자 이름(23px, 700) → 부제(발신번호 상태 등, `--text-dim`)
  - 하단(`.call-actions`): 좌측 **빨간 원형 거절 버튼**(`--alarm` 배경, 수화기 SVG 아이콘 135도 회전) + 우측 **초록 원형 수락 버튼**(`--safe` 배경, 같은 아이콘 정방향) — 실제 iOS 관례를 그대로 따른다. 버튼 아래 작은 라벨(`거절` / 서비스 맥락에 맞는 문구, 예: `훈련 시작`).
  - 아이콘은 이 SVG path를 그대로 재사용: `M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z` (범용 전화기 아이콘, viewBox `0 0 24 24`).
- 480px 이하에서는 프레임을 `236×488px`, 화면 라운드 `41px`로 축소.
- **떠 있는 애니메이션**: 폰을 감싸는 `.phone-float`에 `animation: floatY 6.5s ease-in-out infinite;` (0 → -16px → 0 translateY). 회전/기울임은 기본값으로 넣지 않는다 — 이전에 3D 틸트(rotateX/Y/Z)를 시도했다가 결국 다시 정자세로 되돌렸다. 새 페이지에서도 기본은 **똑바로 세운 정자세**.

### 5.12 예시/후기 문구 (thesis block)

가짜 사용자 후기 대신, 실제 기획서 문구를 인용구로 쓴다:

```html
<div class="thesis-block">
  <div class="thesis-eyebrow">우리가 만드는 것</div>
  <blockquote>"교육이 아닌, 게임처럼 느껴지는 실전 훈련."</blockquote>
  <p class="thesis-sub">부가 설명...</p>
</div>
```
만약 정말 사용자 후기가 필요한 상황이 오면, 반드시 "예시 시나리오 · 실제 후기 아님" 같은 라벨을 붙여서 허구임을 명시한다. 라벨 없이 그럴듯한 가짜 인물/따옴표를 만들지 않는다.

---

## 6. 모션 / 애니메이션 시스템

### 6.1 히어로 진입 애니메이션 (`.reveal-in`)

페이지 로드 시 순차적으로 나타나는 요소들 (히어로 안에서만 사용 — 스크롤 트리거 아님):

```css
.reveal-in {
  opacity: 0; transform: translateY(16px);
  animation: heroFadeUp 0.8s cubic-bezier(0.16, 0.8, 0.24, 1) forwards;
}
@keyframes heroFadeUp { to { opacity: 1; transform: none; } }
.delay-1 { animation-delay: 0.05s; }
.delay-2 { animation-delay: 0.17s; }
.delay-3 { animation-delay: 0.29s; }
.delay-4 { animation-delay: 0.41s; }
.delay-5 { animation-delay: 0.53s; }
```
헤드라인, 서브텍스트, CTA 등 히어로 요소에 `reveal-in delay-N`을 순서대로 붙인다. 폰 목업처럼 별도 타이밍이 필요한 요소는 자체 `opacity:0; animation: heroFadeIn ... forwards;` (`@keyframes heroFadeIn { to { opacity: 1; } }`, 즉 이동 없이 페이드만)를 쓴다.

### 6.2 스크롤 리빌 (아래로 스크롤하며 카드가 나타나는 효과)

히어로 아래 모든 카드형 콘텐츠에 적용:

```css
.card-selector-list {
  opacity: 0; transform: translateY(22px);
  transition: opacity 0.7s cubic-bezier(0.16, 0.8, 0.24, 1), transform 0.7s cubic-bezier(0.16, 0.8, 0.24, 1);
}
.card-selector-list.is-visible { opacity: 1; transform: translateY(0); }
```
같은 그리드 안의 카드는 `nth-child`로 0.08s씩 스태거(stagger) 딜레이를 준다. JS는 `IntersectionObserver`로 `.is-visible` 클래스를 한 번만 추가한다 (`index.html` 첫 번째 `<script>` 참고 — 셀렉터 목록만 새 컴포넌트 클래스로 바꿔서 재사용).

### 6.3 reduced-motion 처리 (필수)

모든 애니메이션 블록마다 짝을 이루는 reduced-motion 규칙을 반드시 추가한다:

```css
@media (prefers-reduced-motion: reduce) {
  .reveal-in, .hero-stage { animation: none !important; opacity: 1 !important; transform: none !important; }
  .phone-float { animation: none !important; }
}
```
JS 쪽에서도 스크롤 연동 애니메이션(발광선, 카드 스포트라이트)은 시작할 때 `window.matchMedia('(prefers-reduced-motion: reduce)').matches`를 확인해서, true면 최종 상태를 즉시 적용하고 스크롤 리스너 자체를 등록하지 않는다.

### 6.4 성능 규칙

스크롤에 반응하는 모든 JS는 `requestAnimationFrame`으로 쓰로틀링한다 (아래 패턴을 그대로 복사):

```js
var ticking = false;
function onScrollOrResize() {
  if (ticking) return;
  ticking = true;
  requestAnimationFrame(function () {
    update();
    ticking = false;
  });
}
window.addEventListener("scroll", onScrollOrResize, { passive: true });
```

---

## 7. 콘텐츠/카피 원칙

- **문구 톤**: 위협을 과장하지 않되 긴급성은 유지한다 ("전화를 받기 전에, 먼저 연습하세요"). 공포 마케팅이 아니라 "대비"에 초점.
- **숫자는 항상 출처를 명시**한다. 예: `연간 보이스피싱 피해액 (경찰청, 2024)`. 출처 없는 숫자는 절대 쓰지 않는다.
- **목표/기대 수치는 반드시 단서를 붙인다.** 예: `훈련 후 피싱 인지도 (목표)` + 본문에 `* 기획 단계의 목표 수치이며, 파일럿 운영을 통해 검증할 예정입니다.`
- **실제 제품 구조(Chapter 1~5 등)를 그대로 반영**한다 — 마케팅 카피용으로 숫자를 지어내지 않는다 (`docs/PROJECT_PROPOSAL.md`, `docs/PRD.md` 기준).
- **CTA 문구는 항상 행동 동사로 끝난다**: "무료로 훈련 시작하기", "시뮬레이션 미리보기", "시작하기 →".

---

## 8. 새 페이지를 만들 때 체크리스트

1. [ ] `<head>`에 §2의 Google Fonts 링크를 그대로 복사했는가?
2. [ ] `:root`에 §1의 컬러 토큰을 그대로 복사했는가? (새 색상을 추가하지 않았는가?)
3. [ ] 모든 콘텐츠는 `.wrap` 안에 있는가? (풀블리드 색상 블록이 없는가?)
4. [ ] 카드 `border-radius`가 전부 4px인가? (16px, 20px 등 큰 값이 섞이지 않았는가?)
5. [ ] 카드에 상단 레드 액센트 보더(`border-top: 2px solid rgba(255,69,63,0.4~0.6)`)가 있는가?
6. [ ] 이모지가 하나도 없는가?
7. [ ] `Space Grotesk`, `Inter` 등 다른 sans/mono 폰트가 섞여 들어가지 않았는가? (IBM Plex Mono + Noto Sans KR만)
8. [ ] 히어로를 제외한 모든 섹션이 좌측 정렬 기본인가? (센터 정렬을 남발하지 않았는가?)
9. [ ] 3개 이상 동일한 카드를 나열할 때, 벤토/비대칭 배치를 검토했는가? (§5.5)
10. [ ] 모든 통계/후기 문구에 실제 출처가 있거나 "예시"로 명시되어 있는가?
11. [ ] 스크롤/등장 애니메이션에 `prefers-reduced-motion` 분기가 있는가?
12. [ ] 외부 이미지 URL이나 아이콘 폰트 CDN을 쓰지 않았는가? (Google Fonts 텍스트 폰트만 허용)
13. [ ] 장식용 JS 요소(발광선 등)를 `body.insertBefore(el, body.firstChild)`로 넣어서 콘텐츠 카드 뒤에 깔리게 했는가?

---

## 9. 참고

- 이 문서에 없는 세부 구현(정확한 JS 로직, 픽셀 단위 미세 조정)은 항상 `/index.html`의 실제 코드를 1차 소스로 삼는다. 이 문서는 "왜 이렇게 만들었는지"와 "재사용 가능한 값"을 정리한 요약본이다.
- 색/폰트/모서리 규칙을 바꾸고 싶으면 이 문서를 먼저 갱신하고, 그다음에 각 페이지에 반영한다. 페이지마다 다르게 바꾸지 않는다.
