# Phishing Defense Frontend MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the React/TypeScript frontend for the Phishing Defense MVP (P0 scope from `docs/PRD.md` §22.1): email auth, Chapter 1 / Scenario 1-1 played end-to-end through all six stages, and the XP/level/star reward loop — fully working against an in-memory Mock Service Worker (MSW) API so frontend work is unblocked by the (currently empty) `backend/` and `ai/` services.

**Architecture:** Vite + React 18 + TypeScript SPA. Zustand for client state (auth session, current game-run state), TanStack Query + Axios for server data, React Router for navigation. MSW intercepts every `/api/v1/*` call in both the browser (dev) and Vitest (tests) against a single in-memory mock "DB" module, seeded with one scripted scenario (Chapter 1 / Scenario 1-1: 은행 사칭 스미싱) so the AI criminal/police responses are deterministic and testable without a real LLM. When the real Spring Boot backend exists, only `src/mocks/**` and the dev bootstrap in `main.tsx` need to be removed — `src/services/**` already speak the real documented contract (`docs/IMPLEMENTATION_GUIDE.md` §5).

**Tech Stack:** React 18.2, TypeScript 5.1, Vite 4.4, Zustand 4.3, @tanstack/react-query 4.32, axios 1.4, react-router-dom 6.14, Tailwind CSS 3.3, framer-motion 10.16, react-hot-toast 2.4, lucide-react 0.263 (all per `docs/PACKAGE_CONFIG.md` §1) — plus MSW 2.x, Vitest, @testing-library/react, @testing-library/jest-dom, @testing-library/user-event, jsdom (not in the original doc; required for the mock-API + TDD approach agreed with the user).

## Global Constraints

- Node package manager: npm (per `docs/PACKAGE_CONFIG.md` §1 install commands).
- Path aliases: `@/*`, `@components/*`, `@pages/*`, `@services/*`, `@stores/*`, `@hooks/*`, `@types/*`, `@utils/*` mapped to `src/*` subfolders (`docs/PACKAGE_CONFIG.md` tsconfig/vite config).
- Dev server port `3000`, API base URL via `VITE_API_BASE_URL` env var (`docs/PACKAGE_CONFIG.md` §2).
- API paths and payload shapes follow `docs/IMPLEMENTATION_GUIDE.md` §5 exactly (fields shown there are `snake_case` on the wire; frontend types are `camelCase` and services translate at the boundary).
- MVP scope only (`docs/PRD.md` §22.1): email signup/login only (no OAuth), Chapter 1 with exactly 1 scenario, Stage 5 report step is police-only (no bank AI — that's §22.3 Phase 1-2), Stage 6 report is formula-computed (not LLM-generated — that's also Phase 1-2).
- **Known spec inconsistency, resolved here:** `docs/PRD.md` §12.2 labels the star-rating breakdown "총 100점 만점" but its own listed category maxima (30+20+20+20+10+10) sum to 110, and the worked XP examples in §12.1.1 (the 360XP / 140XP scenarios) don't reconcile with the tiered tables in §12.2/§17.3 (e.g. "증거 65% 수집: +25XP" vs. the explicit §17.3 tier that would give +10 at 65%). This plan implements the explicit tiered tables in §12.2 and §17.3 as source of truth (they are internally consistent and precisely specified), normalizes the raw 110-point category sum to a /100 scale before applying the 90/80/60 star thresholds, and does not attempt to reproduce the narrative examples' exact totals. See Task 3.

---

### Task 1: Project Scaffolding & Tooling

**Files:**
- Create: `frontend/package.json`, `frontend/tsconfig.json`, `frontend/tsconfig.node.json`, `frontend/vite.config.ts`, `frontend/tailwind.config.js`, `frontend/postcss.config.js`, `frontend/index.html`, `frontend/.env.example`, `frontend/.env.development`, `frontend/vitest.config.ts`, `frontend/src/main.tsx`, `frontend/src/App.tsx`, `frontend/src/index.css`, `frontend/src/vite-env.d.ts`
- Modify: `frontend/README.md` (remove the "아직 프로젝트가 생성되지 않았습니다" notice once scaffolding exists)

**Interfaces:**
- Produces: a running Vite dev server at `localhost:3000`, `npm run build` producing `dist/`, `npm test` running Vitest with jsdom. All later tasks add files under `frontend/src/`.

- [ ] **Step 1: Scaffold the Vite project**

```bash
cd frontend
npm create vite@latest . -- --template react-ts
```

- [ ] **Step 2: Install dependencies**

```bash
npm install zustand@^4.3.9 @tanstack/react-query@^4.32.0 axios@^1.4.0 \
  react-router-dom@^6.14.0 framer-motion@^10.16.4 recharts@^2.7.3 \
  react-hot-toast@^2.4.1 lucide-react@^0.263.1 clsx@^1.2.1

npm install -D tailwindcss@^3.3.2 postcss@^8.4.24 autoprefixer@^10.4.14 \
  vitest@^0.34.6 @vitest/ui@^0.34.6 jsdom@^22.1.0 \
  @testing-library/react@^14.0.0 @testing-library/jest-dom@^6.1.4 \
  @testing-library/user-event@^14.5.1 msw@^2.0.11

npx tailwindcss init -p
npx msw init public/ --save
```

- [ ] **Step 3: Replace `package.json` scripts**

```json
{
  "name": "phishing-defense-frontend",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc --noEmit && vite build",
    "preview": "vite preview",
    "lint": "eslint src --ext ts,tsx --report-unused-disable-directives --max-warnings 0",
    "type-check": "tsc --noEmit",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage"
  }
}
```

(Keep the `dependencies`/`devDependencies` blocks npm generated in Step 2 — just replace the `scripts` key.)

- [ ] **Step 4: Configure path aliases in `tsconfig.json`**

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "types": ["vitest/globals", "@testing-library/jest-dom"],
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@components/*": ["src/components/*"],
      "@pages/*": ["src/pages/*"],
      "@services/*": ["src/services/*"],
      "@stores/*": ["src/stores/*"],
      "@hooks/*": ["src/hooks/*"],
      "@types/*": ["src/types/*"],
      "@utils/*": ["src/utils/*"],
      "@mocks/*": ["src/mocks/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

- [ ] **Step 5: Configure `vite.config.ts`**

```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@pages': path.resolve(__dirname, './src/pages'),
      '@services': path.resolve(__dirname, './src/services'),
      '@stores': path.resolve(__dirname, './src/stores'),
      '@hooks': path.resolve(__dirname, './src/hooks'),
      '@types': path.resolve(__dirname, './src/types'),
      '@utils': path.resolve(__dirname, './src/utils'),
      '@mocks': path.resolve(__dirname, './src/mocks'),
    },
  },
  server: { port: 3000 },
})
```

- [ ] **Step 6: Configure `vitest.config.ts`**

```typescript
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@pages': path.resolve(__dirname, './src/pages'),
      '@services': path.resolve(__dirname, './src/services'),
      '@stores': path.resolve(__dirname, './src/stores'),
      '@hooks': path.resolve(__dirname, './src/hooks'),
      '@types': path.resolve(__dirname, './src/types'),
      '@utils': path.resolve(__dirname, './src/utils'),
      '@mocks': path.resolve(__dirname, './src/mocks'),
    },
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
  },
})
```

- [ ] **Step 7: Configure Tailwind**

`tailwind.config.js`:
```javascript
/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        primary: '#3B82F6',
        secondary: '#8B5CF6',
        success: '#10B981',
        danger: '#EF4444',
        warning: '#F59E0B',
      },
      fontFamily: { sans: ['Pretendard', 'system-ui', 'sans-serif'] },
    },
  },
  plugins: [],
}
```

`src/index.css`:
```css
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  @apply bg-gray-50 text-gray-900;
}
```

- [ ] **Step 8: Env files**

`.env.example` and `.env.development`:
```
VITE_API_BASE_URL=http://localhost:8080
VITE_APP_NAME=Phishing Defense
VITE_VERSION=1.0.0-dev
VITE_ENABLE_MOCKS=true
```

`src/vite-env.d.ts`:
```typescript
/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_API_BASE_URL: string
  readonly VITE_APP_NAME: string
  readonly VITE_VERSION: string
  readonly VITE_ENABLE_MOCKS: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
```

- [ ] **Step 9: Minimal `App.tsx` / `main.tsx` placeholders (routing added in Task 9)**

`src/App.tsx`:
```tsx
export default function App() {
  return <div className="p-4">Phishing Defense</div>
}
```

`src/main.tsx`:
```tsx
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
```

- [ ] **Step 10: Verify build and test runner both work**

```bash
npm run build
npm test
```

Expected: build succeeds with no TypeScript errors; `npm test` reports "No test files found" (expected — no tests exist yet) without crashing.

- [ ] **Step 11: Update `frontend/README.md`**

Replace the "아직 프로젝트가 생성되지 않았습니다" setup section with:
```markdown
## 개발 서버 실행

\`\`\`bash
npm install
npm run dev
\`\`\`

http://localhost:3000 에서 확인 (Mock API 자동 활성화, 실제 백엔드 불필요)
```

- [ ] **Step 12: Commit**

```bash
git add frontend/
git commit -m "chore(web): scaffold vite react-ts project with tooling"
```

---

### Task 2: Global Types

**Files:**
- Create: `frontend/src/types/auth.ts`, `frontend/src/types/game.ts`, `frontend/src/types/api.ts`

**Interfaces:**
- Consumes: nothing (leaf module).
- Produces: every type referenced by name in Tasks 3–23. These are the canonical definitions — no later task redeclares them.

- [ ] **Step 1: `src/types/api.ts`**

```typescript
export interface ApiErrorBody {
  message: string
  code?: string
}

export class ApiError extends Error {
  status: number
  code?: string

  constructor(status: number, body: ApiErrorBody) {
    super(body.message)
    this.status = status
    this.code = body.code
  }
}
```

- [ ] **Step 2: `src/types/auth.ts`**

```typescript
export interface User {
  userId: number
  email: string
  nickname: string
  level: number
  currentXp: number
  totalXp: number
  coins: number
  hints: number
}

export interface AuthSession {
  token: string
  userId: number
  nickname: string
  level: number
  currentXp: number
}

export interface SignupPayload {
  email: string
  password: string
  nickname: string
}

export interface LoginPayload {
  email: string
  password: string
}
```

- [ ] **Step 3: `src/types/game.ts`**

```typescript
export type Stage = 1 | 2 | 3 | 4 | 5 | 6

export interface Chapter {
  chapterId: number
  title: string
  difficulty: number
  isUnlocked: boolean
  bestStar: number
  isCompleted: boolean
}

export interface Scenario {
  scenarioId: number
  title: string
  phishingType: string
}

export interface ScenarioStartResponse {
  recordId: number
  initialMessage: string
  timestamp: string
}

export interface ScenarioStatus {
  recordId: number
  scenarioId: number
  stage: Stage
  currentTurn: number
  isCompleted: boolean
  hintsRemaining: number
}

export type ChatSender = 'user' | 'ai_criminal' | 'ai_police'

export interface ChatMessage {
  turn: number
  sender: ChatSender
  message: string
  timestamp: string
}

export interface ExtractedEvidence {
  type: string
  value: string
}

export interface ChatSendResponse {
  aiResponse: string
  turn: number
  extractedEvidence: ExtractedEvidence[]
  hintsRemaining: number
  stageComplete: boolean
}

export interface HintResponse {
  hintText: string
  hintsRemaining: number
}

export interface JudgmentResponse {
  isCorrect: boolean
  feedback: string
  nextStage: Stage
  wrongAttempts: number
}

export interface Evidence {
  evidenceId: number
  type: string
  value: string
  importanceLevel: number
  isAutoExtracted: boolean
  isUserSelected: boolean
}

export interface MissedEvidence {
  type: string
  importance: number
}

export interface EvidenceConfirmResponse {
  evidenceCollectionPercentage: number
  missedEvidence: MissedEvidence[]
  tips: string
}

export interface ScenarioReport {
  scenarioId: number
  accuracyEvaluation: {
    isCorrect: boolean
    feedback: string
    judgmentTurn: number
  }
  evidenceAnalysis: {
    collectionPercentage: number
    collectedCount: number
    totalPossible: number
    missed: MissedEvidence[]
  }
  reportHandling: { policeResponse: string }
  scores: {
    accuracy: number
    evidence: number
    report: number
    hints: number
    time: number
    total: number
  }
  starRating: number
  educationalFeedback: string
  xpBreakdown: {
    base: number
    starBonus: number
    hintsBonus: number
    evidenceBonus: number
    reportBonus: number
    accuracyPenalty: number
    timeBonus: number
    total: number
  }
}

export interface ReportClaimResponse {
  xpAdded: number
  newTotalXp: number
  levelUp: boolean
  newLevel: number
}
```

- [ ] **Step 4: Verify it compiles**

```bash
npm run type-check
```

Expected: no errors (types have no runtime behavior to test).

- [ ] **Step 5: Commit**

```bash
git add frontend/src/types
git commit -m "feat(web): add core auth/game/api type definitions"
```

---

### Task 3: Game Scoring Utilities

**Files:**
- Create: `frontend/src/utils/levels.ts`, `frontend/src/utils/levels.test.ts`, `frontend/src/utils/scoring.ts`, `frontend/src/utils/scoring.test.ts`

**Interfaces:**
- Consumes: nothing.
- Produces: `getLevelInfo(totalXp: number): LevelInfo`, `computeScenarioScore(input: ScoreInput): ScoreResult`, `computeXpBreakdown(input: XpInput): XpBreakdown` — consumed by Task 13 (mock chapter handlers, for chapter list XP display is not needed but level info is used by Task 8's authStore) and Task 21 (report mock handler).

- [ ] **Step 1: Write failing tests for `levels.ts`**

```typescript
// src/utils/levels.test.ts
import { describe, it, expect } from 'vitest'
import { getLevelInfo } from './levels'

describe('getLevelInfo', () => {
  it('returns level 1 at 0 xp', () => {
    const info = getLevelInfo(0)
    expect(info.level).toBe(1)
    expect(info.progressRatio).toBe(0)
  })

  it('returns level 5 exactly at its threshold', () => {
    expect(getLevelInfo(4000).level).toBe(5)
  })

  it('interpolates progress between anchors', () => {
    const info = getLevelInfo(2000) // halfway between Lv1(0) and Lv5(4000)
    expect(info.level).toBe(1)
    expect(info.xpForNextLevel).toBe(4000)
    expect(info.progressRatio).toBeCloseTo(0.5, 2)
  })

  it('returns level 30 at 60000 xp and beyond', () => {
    expect(getLevelInfo(60000).level).toBe(30)
    expect(getLevelInfo(90000).level).toBe(30)
  })
})
```

- [ ] **Step 2: Run to verify it fails**

```bash
npx vitest run src/utils/levels.test.ts
```

Expected: FAIL — `levels.ts` does not exist.

- [ ] **Step 3: Implement `levels.ts`**

Anchor points are the named levels from `docs/PRD.md` §12.1.2. Between anchors, XP requirement is linearly interpolated (the PRD gives exact totals only for levels 1/5/10/15/20/25/30; intermediate levels are described only as "~5,000XP마다" — interpolation is the simplest scheme consistent with the anchors).

```typescript
export interface LevelInfo {
  level: number
  totalXp: number
  currentLevelXp: number
  xpForNextLevel: number
  progressRatio: number
}

const ANCHORS: { level: number; totalXp: number }[] = [
  { level: 1, totalXp: 0 },
  { level: 5, totalXp: 4000 },
  { level: 10, totalXp: 10000 },
  { level: 15, totalXp: 18000 },
  { level: 20, totalXp: 28000 },
  { level: 25, totalXp: 40000 },
  { level: 30, totalXp: 60000 },
]

function xpRequiredForLevel(level: number): number {
  if (level <= 1) return 0
  if (level >= 30) return 60000

  let lower = ANCHORS[0]
  let upper = ANCHORS[ANCHORS.length - 1]
  for (let i = 0; i < ANCHORS.length - 1; i++) {
    if (level >= ANCHORS[i].level && level <= ANCHORS[i + 1].level) {
      lower = ANCHORS[i]
      upper = ANCHORS[i + 1]
      break
    }
  }
  const span = upper.level - lower.level
  const ratio = span === 0 ? 0 : (level - lower.level) / span
  return Math.round(lower.totalXp + ratio * (upper.totalXp - lower.totalXp))
}

export function getLevelInfo(totalXp: number): LevelInfo {
  let level = 1
  while (level < 30 && xpRequiredForLevel(level + 1) <= totalXp) {
    level++
  }

  const currentThreshold = xpRequiredForLevel(level)
  const nextThreshold = level >= 30 ? currentThreshold : xpRequiredForLevel(level + 1)
  const currentLevelXp = totalXp - currentThreshold
  const xpForNextLevel = nextThreshold - currentThreshold
  const progressRatio = level >= 30 ? 1 : currentLevelXp / xpForNextLevel

  return { level, totalXp, currentLevelXp, xpForNextLevel: nextThreshold, progressRatio }
}
```

- [ ] **Step 4: Run to verify it passes**

```bash
npx vitest run src/utils/levels.test.ts
```

Expected: PASS.

- [ ] **Step 5: Write failing tests for `scoring.ts`**

```typescript
// src/utils/scoring.test.ts
import { describe, it, expect } from 'vitest'
import { computeScenarioScore, computeXpBreakdown } from './scoring'

describe('computeScenarioScore', () => {
  it('awards top marks for a fast, correct, fully-evidenced, no-hint run', () => {
    const result = computeScenarioScore({
      judgmentTurn: 2,
      wrongAttempts: 0,
      evidenceCollectionPercentage: 95,
      hintsUsed: 0,
      policeTurnsCompleted: 2,
      durationSeconds: 240,
    })
    expect(result.accuracy).toBe(30)
    expect(result.evidence).toBe(18)
    expect(result.report).toBe(20)
    expect(result.hints).toBe(10)
    expect(result.time).toBe(10)
    expect(result.total).toBe(100) // normalized to /100
    expect(result.starRating).toBe(3)
  })

  it('awards bronze for a slow run with mistakes', () => {
    const result = computeScenarioScore({
      judgmentTurn: 6,
      wrongAttempts: 1,
      evidenceCollectionPercentage: 65,
      hintsUsed: 3,
      policeTurnsCompleted: 1,
      durationSeconds: 1000,
    })
    expect(result.starRating).toBeLessThanOrEqual(1)
  })
})

describe('computeXpBreakdown', () => {
  it('sums base, star, hint, evidence, report and time bonuses', () => {
    const xp = computeXpBreakdown({
      starRating: 3,
      hintsUsed: 0,
      evidenceCollectionPercentage: 95,
      reportScore: 20,
      wrongAttempts: 0,
      durationSeconds: 240,
    })
    expect(xp.base).toBe(150)
    expect(xp.starBonus).toBe(70)
    expect(xp.hintsBonus).toBe(20)
    expect(xp.evidenceBonus).toBe(40)
    expect(xp.reportBonus).toBe(50)
    expect(xp.accuracyPenalty).toBe(0)
    expect(xp.timeBonus).toBe(30)
    expect(xp.total).toBe(150 + 70 + 20 + 40 + 50 + 30)
  })

  it('applies penalties for hints, wrong judgment, and slow completion', () => {
    const xp = computeXpBreakdown({
      starRating: 1,
      hintsUsed: 3,
      evidenceCollectionPercentage: 65,
      reportScore: 10,
      wrongAttempts: 2,
      durationSeconds: 1300,
    })
    expect(xp.hintsBonus).toBe(-15)
    expect(xp.evidenceBonus).toBe(10)
    expect(xp.reportBonus).toBe(0)
    expect(xp.accuracyPenalty).toBe(-10)
    expect(xp.timeBonus).toBe(-10)
  })
})
```

- [ ] **Step 6: Run to verify it fails**

```bash
npx vitest run src/utils/scoring.test.ts
```

Expected: FAIL — `scoring.ts` does not exist.

- [ ] **Step 7: Implement `scoring.ts`**

Tiers below follow `docs/PRD.md` §12.2 (100-point breakdown) and §17.3 (evidence bonus table). The five §12.2 category maxima (30+20+20+20+10+10=110) are normalized to /100 before the 90/80/60 star thresholds are applied — see the Global Constraints note on the spec's own arithmetic inconsistency.

```typescript
export interface ScoreInput {
  judgmentTurn: number
  wrongAttempts: number
  evidenceCollectionPercentage: number
  hintsUsed: number
  policeTurnsCompleted: number
  durationSeconds: number
}

export interface ScoreResult {
  accuracy: number
  evidence: number
  report: number
  hints: number
  time: number
  rawTotal: number
  total: number
  starRating: number
}

const MVP_RESPONSE_WISDOM_SCORE = 20 // NLP-based over-disclosure detection is Phase 1-2 scope; MVP awards full marks

function accuracyScore(judgmentTurn: number, wrongAttempts: number): number {
  if (wrongAttempts >= 2) return 10
  if (wrongAttempts === 1) return 15
  if (judgmentTurn <= 2) return 30
  if (judgmentTurn <= 4) return 25
  return 20
}

function evidenceScore(pct: number): number {
  if (pct >= 100) return 20
  if (pct >= 90) return 18
  if (pct >= 80) return 15
  if (pct >= 70) return 10
  return 5
}

function reportScoreFromTurns(policeTurnsCompleted: number): number {
  if (policeTurnsCompleted >= 2) return 20
  if (policeTurnsCompleted === 1) return 10
  return 5
}

function hintsScore(hintsUsed: number): number {
  if (hintsUsed <= 0) return 10
  if (hintsUsed === 1) return 9
  if (hintsUsed === 2) return 7
  if (hintsUsed === 3) return 4
  return 0
}

function timeScore(durationSeconds: number): number {
  const minutes = durationSeconds / 60
  if (minutes <= 5) return 10
  if (minutes <= 10) return 8
  if (minutes <= 15) return 6
  if (minutes <= 20) return 3
  return 0
}

const RAW_MAX = 30 + MVP_RESPONSE_WISDOM_SCORE + 20 + 20 + 10 + 10 // 110

export function computeScenarioScore(input: ScoreInput): ScoreResult {
  const accuracy = accuracyScore(input.judgmentTurn, input.wrongAttempts) + MVP_RESPONSE_WISDOM_SCORE
  const evidence = evidenceScore(input.evidenceCollectionPercentage)
  const report = reportScoreFromTurns(input.policeTurnsCompleted)
  const hints = hintsScore(input.hintsUsed)
  const time = timeScore(input.durationSeconds)

  const rawTotal = accuracy + evidence + report + hints + time
  const total = Math.round((rawTotal / RAW_MAX) * 100)

  const starRating = total >= 90 ? 3 : total >= 80 ? 2 : total >= 60 ? 1 : 0

  return { accuracy, evidence, report, hints, time, rawTotal, total, starRating }
}

export interface XpInput {
  starRating: number
  hintsUsed: number
  evidenceCollectionPercentage: number
  reportScore: number // 0-20, from ScoreResult.report
  wrongAttempts: number
  durationSeconds: number
}

export interface XpBreakdown {
  base: number
  starBonus: number
  hintsBonus: number
  evidenceBonus: number
  reportBonus: number
  accuracyPenalty: number
  timeBonus: number
  total: number
}

const STAR_BONUS = [0, 10, 30, 70] // index = starRating

export function computeXpBreakdown(input: XpInput): XpBreakdown {
  const base = 150
  const starBonus = STAR_BONUS[input.starRating] ?? 0
  const hintsBonus = input.hintsUsed <= 0 ? 20 : -5 * input.hintsUsed

  const pct = input.evidenceCollectionPercentage
  const evidenceBonus = pct >= 90 ? 40 : pct >= 80 ? 30 : pct >= 70 ? 20 : 10

  const reportBonus = input.reportScore === 20 ? 50 : input.reportScore >= 10 ? 0 : -20
  const accuracyPenalty = input.wrongAttempts >= 2 ? -10 : 0

  const minutes = input.durationSeconds / 60
  const timeBonus = minutes <= 5 ? 30 : minutes >= 20 ? -10 : 0

  const total = base + starBonus + hintsBonus + evidenceBonus + reportBonus + accuracyPenalty + timeBonus

  return { base, starBonus, hintsBonus, evidenceBonus, reportBonus, accuracyPenalty, timeBonus, total }
}
```

- [ ] **Step 8: Run to verify it passes**

```bash
npx vitest run src/utils/scoring.test.ts src/utils/levels.test.ts
```

Expected: PASS (all tests).

- [ ] **Step 9: Commit**

```bash
git add frontend/src/utils
git commit -m "feat(web): add level progression and scenario scoring utilities"
```

---

### Task 4: Chapter 1 Scenario Mock Script

**Files:**
- Create: `frontend/src/mocks/scenarioData.ts`

**Interfaces:**
- Consumes: nothing (pure data module).
- Produces: `CHAPTER_1`, `SCENARIO_1_1`, `criminalReplyForTurn(turn: number): string`, `policeReplyForTurn(turn: number): string`, `AUTO_EVIDENCE_BY_TURN: Record<number, ExtractedEvidence[]>`, `ALL_POSSIBLE_EVIDENCE: Evidence[]` — consumed by Task 5's in-memory DB and Tasks 6/10/13/18/19 mock handlers.

- [ ] **Step 1: Write the scenario script**

```typescript
// src/mocks/scenarioData.ts
import type { Chapter, Scenario, Evidence, ExtractedEvidence } from '@types/game'

export const CHAPTER_1: Chapter = {
  chapterId: 1,
  title: '기초 스미싱 사건',
  difficulty: 1,
  isUnlocked: true,
  bestStar: 0,
  isCompleted: false,
}

export const CHAPTER_2_PLACEHOLDER: Chapter = {
  chapterId: 2,
  title: '택배 사칭 사건',
  difficulty: 2,
  isUnlocked: false,
  bestStar: 0,
  isCompleted: false,
}

export const SCENARIO_1_1: Scenario = {
  scenarioId: 101,
  title: '은행 사칭 스미싱',
  phishingType: 'smishing',
}

export const INITIAL_SMS =
  '[국민은행] 고객님의 계좌에서 500,000원이 결제되었습니다. 본인이 아니시면 아래 링크에서 즉시 확인하세요. bit.ly/2xK9fZ'

const CRIMINAL_REPLIES: Record<number, string> = {
  1: '네 고객님, 확인을 도와드리겠습니다. 본인 확인을 위해 성함과 주민등록번호 뒷자리를 말씀해 주시겠어요?',
  2: '빠르게 처리하지 않으면 계좌가 정지될 수 있습니다. 지금 바로 계좌번호와 비밀번호를 알려주시면 취소 처리해 드리겠습니다.',
}
const CRIMINAL_FALLBACK = '고객님, 시간이 얼마 없습니다. 빨리 답변해 주세요.'

export function criminalReplyForTurn(turn: number): string {
  return CRIMINAL_REPLIES[turn] ?? CRIMINAL_FALLBACK
}

const POLICE_REPLIES: Record<number, string> = {
  1: '안녕하세요, 사이버범죄수사팀입니다. 신고 내용을 말씀해 주시겠어요?',
  2: '접수되었습니다. 문자로 받으신 링크와 발신번호를 다시 한 번 말씀해 주시겠어요?',
}
const POLICE_CLOSING =
  '확인되었습니다. 신고가 정식 접수되었으며, 해당 번호는 조사 후 차단 조치될 예정입니다. 협조 감사합니다.'

export function policeReplyForTurn(turn: number): string {
  return POLICE_REPLIES[turn] ?? POLICE_CLOSING
}

export const AUTO_EVIDENCE_ON_START: ExtractedEvidence[] = [
  { type: 'impersonation', value: '국민은행 사칭' },
  { type: 'url', value: 'bit.ly/2xK9fZ' },
  { type: 'phone_number', value: '발신 번호 050-1234-5678' },
]

export const AUTO_EVIDENCE_BY_TURN: Record<number, ExtractedEvidence[]> = {
  1: [{ type: 'personal_info_request', value: '주민등록번호 요구' }],
  2: [
    { type: 'urgency', value: '"지금 바로" 강조' },
    { type: 'account_number', value: '계좌번호·비밀번호 요구' },
  ],
}

export const ALL_POSSIBLE_EVIDENCE: Omit<Evidence, 'isUserSelected'>[] = [
  { evidenceId: 1, type: 'impersonation', value: '국민은행 사칭', importanceLevel: 5, isAutoExtracted: true },
  { evidenceId: 2, type: 'url', value: 'bit.ly/2xK9fZ', importanceLevel: 4, isAutoExtracted: true },
  { evidenceId: 3, type: 'phone_number', value: '발신 번호 050-1234-5678', importanceLevel: 4, isAutoExtracted: true },
  { evidenceId: 4, type: 'personal_info_request', value: '주민등록번호 요구', importanceLevel: 5, isAutoExtracted: false },
  { evidenceId: 5, type: 'urgency', value: '"지금 바로" 강조', importanceLevel: 2, isAutoExtracted: false },
  { evidenceId: 6, type: 'account_number', value: '계좌번호·비밀번호 요구', importanceLevel: 5, isAutoExtracted: false },
]

export const HINT_TEXTS: Record<Stage, string> = {
  1: '문자 발신 번호가 은행 공식 번호와 다른지 확인해 보세요.',
  2: '은행은 절대 문자나 채팅으로 비밀번호·주민등록번호를 묻지 않습니다.',
  3: '금액 결제 문자 + 링크 클릭 유도는 스미싱의 전형적 패턴입니다.',
  4: '계좌번호와 주민등록번호 요구는 가장 중요도가 높은 증거입니다.',
  5: '경찰에는 발신번호, 링크 주소, 요구받은 정보를 구체적으로 전달하세요.',
  6: '',
}

type Stage = 1 | 2 | 3 | 4 | 5 | 6
```

(Move the `type Stage = ...` line to the top of the file, importing `Stage` from `@types/game` instead, since it's already defined there — see Step 2.)

- [ ] **Step 2: Fix the import and remove the duplicate `Stage` type**

Replace the last two lines with:
```typescript
import type { Chapter, Scenario, Evidence, ExtractedEvidence, Stage } from '@types/game'
```
and delete the trailing `type Stage = 1 | 2 | 3 | 4 | 5 | 6` declaration (already imported above).

- [ ] **Step 3: Verify it compiles**

```bash
npm run type-check
```

Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add frontend/src/mocks/scenarioData.ts
git commit -m "feat(web): script Chapter 1 / Scenario 1-1 mock content"
```

---

### Task 5: Mock Server Infrastructure

**Files:**
- Create: `frontend/src/mocks/db.ts`, `frontend/src/mocks/browser.ts`, `frontend/src/test/server.ts`, `frontend/src/test/setup.ts`

**Interfaces:**
- Consumes: `SCENARIO_1_1`, `CHAPTER_1`, `CHAPTER_2_PLACEHOLDER` from Task 4.
- Produces: `mockDb` (in-memory store with `users`, `records`, session helpers), `worker` (browser MSW instance started from `main.tsx` in Task 9), `server` (node MSW instance started in `src/test/setup.ts`, used transitively by every component test from Task 8 onward). Handler arrays are added incrementally in Tasks 6/10/13/18/19/21 into `frontend/src/mocks/handlers.ts`, created here as an empty array.

- [ ] **Step 1: In-memory mock database**

```typescript
// src/mocks/db.ts
import type { User } from '@types/auth'
import type { ChatMessage, Chapter, Stage } from '@types/game'
import { CHAPTER_1, CHAPTER_2_PLACEHOLDER } from './scenarioData'

export interface MockRecord {
  recordId: number
  scenarioId: number
  userId: number
  stage: Stage
  currentTurn: number
  chatHistory: ChatMessage[]
  hintsUsed: number
  hintsRemaining: number
  judgmentWrongAttempts: number
  judgmentCorrect: boolean | null
  judgmentTurn: number | null
  selectedEvidenceIds: number[]
  policeTurnsCompleted: number
  startedAt: number
  claimed: boolean
}

interface MockUserRecord extends User {
  password: string
}

let userSeq = 1
let recordSeq = 1

export const mockDb = {
  users: new Map<number, MockUserRecord>(),
  usersByEmail: new Map<string, MockUserRecord>(),
  chapters: [CHAPTER_1, CHAPTER_2_PLACEHOLDER] as Chapter[],
  records: new Map<number, MockRecord>(),

  reset() {
    this.users.clear()
    this.usersByEmail.clear()
    this.records.clear()
    this.chapters = [{ ...CHAPTER_1 }, { ...CHAPTER_2_PLACEHOLDER }]
    userSeq = 1
    recordSeq = 1
  },

  createUser(email: string, password: string, nickname: string): MockUserRecord {
    const user: MockUserRecord = {
      userId: userSeq++,
      email,
      password,
      nickname,
      level: 1,
      currentXp: 0,
      totalXp: 0,
      coins: 0,
      hints: 3,
    }
    this.users.set(user.userId, user)
    this.usersByEmail.set(email, user)
    return user
  },

  createRecord(userId: number, scenarioId: number): MockRecord {
    const record: MockRecord = {
      recordId: recordSeq++,
      scenarioId,
      userId,
      stage: 1,
      currentTurn: 0,
      chatHistory: [],
      hintsUsed: 0,
      hintsRemaining: 3,
      judgmentWrongAttempts: 0,
      judgmentCorrect: null,
      judgmentTurn: null,
      selectedEvidenceIds: [],
      policeTurnsCompleted: 0,
      startedAt: Date.now(),
      claimed: false,
    }
    this.records.set(record.recordId, record)
    return record
  },
}

export function tokenForUser(userId: number): string {
  return `mock-jwt.${userId}`
}

export function userIdFromToken(token: string | null): number | null {
  if (!token) return null
  const match = /^mock-jwt\.(\d+)$/.exec(token.replace('Bearer ', ''))
  return match ? Number(match[1]) : null
}
```

- [ ] **Step 2: Empty handlers module (filled in by later tasks)**

```typescript
// src/mocks/handlers.ts
import type { HttpHandler } from 'msw'

export const handlers: HttpHandler[] = []
```

- [ ] **Step 3: Browser worker**

```typescript
// src/mocks/browser.ts
import { setupWorker } from 'msw/browser'
import { handlers } from './handlers'

export const worker = setupWorker(...handlers)
```

- [ ] **Step 4: Node server for tests**

```typescript
// src/test/server.ts
import { setupServer } from 'msw/node'
import { handlers } from '@mocks/handlers'

export const server = setupServer(...handlers)
```

- [ ] **Step 5: Global test setup**

```typescript
// src/test/setup.ts
import '@testing-library/jest-dom/vitest'
import { beforeAll, afterEach, afterAll } from 'vitest'
import { server } from './server'
import { mockDb } from '@mocks/db'

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }))
afterEach(() => {
  server.resetHandlers()
  mockDb.reset()
})
afterAll(() => server.close())
```

- [ ] **Step 6: Verify test infra boots with zero handlers**

```bash
npm test
```

Expected: still "no test files found" but no import/resolution errors — confirms `@mocks/*` alias and MSW node setup wire up cleanly.

- [ ] **Step 7: Commit**

```bash
git add frontend/src/mocks frontend/src/test
git commit -m "feat(web): add in-memory mock DB and MSW server bootstrap"
```

---

### Task 6: Auth Mock Handlers

**Files:**
- Create: `frontend/src/mocks/handlers/auth.ts`, `frontend/src/mocks/handlers/auth.test.ts`
- Modify: `frontend/src/mocks/handlers.ts`

**Interfaces:**
- Consumes: `mockDb`, `tokenForUser`, `userIdFromToken` (Task 5).
- Produces: handlers for `POST /api/v1/auth/signup`, `POST /api/v1/auth/login`, `GET /api/v1/auth/verify` — consumed by Task 7's `authService`.

- [ ] **Step 1: Write failing tests (direct `fetch` against the MSW node server)**

```typescript
// src/mocks/handlers/auth.test.ts
import { describe, it, expect } from 'vitest'

const BASE = 'http://localhost:8080/api/v1'

describe('auth mock handlers', () => {
  it('signs up a new user', async () => {
    const res = await fetch(`${BASE}/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'a@test.com', password: 'pw123456', nickname: '피싱헌터' }),
    })
    expect(res.status).toBe(201)
    const body = await res.json()
    expect(body.token).toMatch(/^mock-jwt\./)
    expect(body.nickname).toBe('피싱헌터')
  })

  it('rejects duplicate signup email', async () => {
    await fetch(`${BASE}/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'dup@test.com', password: 'pw123456', nickname: 'A' }),
    })
    const res = await fetch(`${BASE}/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'dup@test.com', password: 'pw123456', nickname: 'B' }),
    })
    expect(res.status).toBe(409)
  })

  it('logs in with correct credentials and rejects wrong password', async () => {
    await fetch(`${BASE}/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'login@test.com', password: 'correct1', nickname: 'A' }),
    })

    const ok = await fetch(`${BASE}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'login@test.com', password: 'correct1' }),
    })
    expect(ok.status).toBe(200)

    const bad = await fetch(`${BASE}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'login@test.com', password: 'wrong' }),
    })
    expect(bad.status).toBe(401)
  })

  it('verifies a valid token', async () => {
    const signup = await fetch(`${BASE}/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'verify@test.com', password: 'pw123456', nickname: 'A' }),
    })
    const { token } = await signup.json()

    const res = await fetch(`${BASE}/auth/verify`, {
      headers: { Authorization: `Bearer ${token}` },
    })
    expect(res.status).toBe(200)
    expect((await res.json()).valid).toBe(true)
  })
})
```

- [ ] **Step 2: Run to verify it fails**

```bash
npx vitest run src/mocks/handlers/auth.test.ts
```

Expected: FAIL — no handlers registered yet (MSW `onUnhandledRequest: 'error'` will throw).

- [ ] **Step 3: Implement the handlers**

```typescript
// src/mocks/handlers/auth.ts
import { http, HttpResponse } from 'msw'
import { mockDb, tokenForUser, userIdFromToken } from '../db'

const BASE = '*/api/v1'

export const authHandlers = [
  http.post(`${BASE}/auth/signup`, async ({ request }) => {
    const { email, password, nickname } = (await request.json()) as {
      email: string
      password: string
      nickname: string
    }
    if (mockDb.usersByEmail.has(email)) {
      return HttpResponse.json({ message: '이미 가입된 이메일입니다.' }, { status: 409 })
    }
    const user = mockDb.createUser(email, password, nickname)
    return HttpResponse.json(
      { token: tokenForUser(user.userId), userId: user.userId, nickname: user.nickname, level: user.level, currentXp: user.currentXp },
      { status: 201 },
    )
  }),

  http.post(`${BASE}/auth/login`, async ({ request }) => {
    const { email, password } = (await request.json()) as { email: string; password: string }
    const user = mockDb.usersByEmail.get(email)
    if (!user || user.password !== password) {
      return HttpResponse.json({ message: '이메일 또는 비밀번호가 올바르지 않습니다.' }, { status: 401 })
    }
    return HttpResponse.json({
      token: tokenForUser(user.userId),
      userId: user.userId,
      nickname: user.nickname,
      level: user.level,
      currentXp: user.currentXp,
    })
  }),

  http.get(`${BASE}/auth/verify`, ({ request }) => {
    const userId = userIdFromToken(request.headers.get('Authorization'))
    if (!userId || !mockDb.users.has(userId)) {
      return HttpResponse.json({ valid: false }, { status: 401 })
    }
    return HttpResponse.json({ valid: true, userId })
  }),
]
```

- [ ] **Step 4: Register in the handlers barrel**

```typescript
// src/mocks/handlers.ts
import type { HttpHandler } from 'msw'
import { authHandlers } from './handlers/auth'

export const handlers: HttpHandler[] = [...authHandlers]
```

- [ ] **Step 5: Run to verify it passes**

```bash
npx vitest run src/mocks/handlers/auth.test.ts
```

Expected: PASS (all 4 tests).

- [ ] **Step 6: Commit**

```bash
git add frontend/src/mocks
git commit -m "feat(web): add auth mock handlers (signup/login/verify)"
```

---

### Task 7: Axios Instance & Auth Service

**Files:**
- Create: `frontend/src/services/api.ts`, `frontend/src/services/authService.ts`, `frontend/src/services/authService.test.ts`

**Interfaces:**
- Consumes: `AuthSession`, `SignupPayload`, `LoginPayload` (Task 2), auth mock handlers (Task 6).
- Produces: `apiClient` (axios instance, imported by every service in later tasks), `authService.signup/login/verify`, `setAuthToken(token: string | null)` — consumed by Task 8's `authStore`.

- [ ] **Step 1: Axios instance with token injection**

```typescript
// src/services/api.ts
import axios from 'axios'
import { ApiError } from '@types/api'

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  headers: { 'Content-Type': 'application/json' },
})

let authToken: string | null = null

export function setAuthToken(token: string | null) {
  authToken = token
}

apiClient.interceptors.request.use((config) => {
  if (authToken) {
    config.headers.Authorization = `Bearer ${authToken}`
  }
  return config
})

apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response) {
      return Promise.reject(new ApiError(error.response.status, error.response.data))
    }
    return Promise.reject(error)
  },
)
```

- [ ] **Step 2: Write failing test for `authService`**

```typescript
// src/services/authService.test.ts
import { describe, it, expect } from 'vitest'
import { authService } from './authService'

describe('authService', () => {
  it('signs up and returns a session', async () => {
    const session = await authService.signup({ email: 'svc@test.com', password: 'pw123456', nickname: '헌터' })
    expect(session.userId).toBeGreaterThan(0)
    expect(session.token).toMatch(/^mock-jwt\./)
  })

  it('logs in an existing user', async () => {
    await authService.signup({ email: 'svc2@test.com', password: 'pw123456', nickname: '헌터2' })
    const session = await authService.login({ email: 'svc2@test.com', password: 'pw123456' })
    expect(session.nickname).toBe('헌터2')
  })

  it('throws ApiError on invalid login', async () => {
    await expect(authService.login({ email: 'nobody@test.com', password: 'x' })).rejects.toMatchObject({
      status: 401,
    })
  })
})
```

- [ ] **Step 3: Run to verify it fails**

```bash
npx vitest run src/services/authService.test.ts
```

Expected: FAIL — `authService.ts` does not exist.

- [ ] **Step 4: Implement `authService.ts`**

```typescript
// src/services/authService.ts
import { apiClient } from './api'
import type { AuthSession, LoginPayload, SignupPayload } from '@types/auth'

interface AuthWireResponse {
  token: string
  user_id: number
  nickname: string
  level: number
  current_xp: number
}

function toSession(body: AuthWireResponse): AuthSession {
  return { token: body.token, userId: body.user_id, nickname: body.nickname, level: body.level, currentXp: body.current_xp }
}

export const authService = {
  async signup(payload: SignupPayload): Promise<AuthSession> {
    const { data } = await apiClient.post<AuthWireResponse>('/api/v1/auth/signup', payload)
    return toSession(data)
  },

  async login(payload: LoginPayload): Promise<AuthSession> {
    const { data } = await apiClient.post<AuthWireResponse>('/api/v1/auth/login', payload)
    return toSession(data)
  },

  async verify(): Promise<boolean> {
    const { data } = await apiClient.get<{ valid: boolean }>('/api/v1/auth/verify')
    return data.valid
  },
}
```

Note: the mock handler (Task 6) currently returns camelCase-ish keys (`userId`, `nickname`, ...) directly via `HttpResponse.json({...})` with the JS object's own key names. To keep the wire contract honest to `docs/IMPLEMENTATION_GUIDE.md` §5 (snake_case), update the Task 6 handler bodies to emit `user_id`, `current_xp` instead of `userId`, `currentXp` before running this task's tests.

- [ ] **Step 5: Update Task 6's handlers to snake_case wire format**

In `src/mocks/handlers/auth.ts`, change both `HttpResponse.json({ token: ..., userId: user.userId, ... })` calls to:
```typescript
{ token: tokenForUser(user.userId), user_id: user.userId, nickname: user.nickname, level: user.level, current_xp: user.currentXp }
```

- [ ] **Step 6: Run to verify it passes**

```bash
npx vitest run src/services/authService.test.ts src/mocks/handlers/auth.test.ts
```

Expected: PASS (update the auth.test.ts assertions in Step 1 of Task 6 if they read `body.userId` — they should read `body.user_id`; fix now if needed).

- [ ] **Step 7: Commit**

```bash
git add frontend/src/services frontend/src/mocks
git commit -m "feat(web): add axios client and auth service"
```

---

### Task 8: Auth Store & useAuth Hook

**Files:**
- Create: `frontend/src/stores/authStore.ts`, `frontend/src/stores/authStore.test.ts`, `frontend/src/hooks/useAuth.ts`

**Interfaces:**
- Consumes: `authService` (Task 7), `setAuthToken` (Task 7), `AuthSession`/`User` (Task 2).
- Produces: `useAuthStore` (Zustand store with `session`, `login`, `signup`, `logout`, `addXp`), `useAuth()` hook — consumed by Task 9 (ProtectedRoute, LoginPage), Task 12 (Dashboard header), Task 22 (level-up on report claim).

- [ ] **Step 1: Write failing store test**

```typescript
// src/stores/authStore.test.ts
import { describe, it, expect, beforeEach } from 'vitest'
import { useAuthStore } from './authStore'

describe('authStore', () => {
  beforeEach(() => {
    useAuthStore.setState({ session: null })
  })

  it('starts logged out', () => {
    expect(useAuthStore.getState().session).toBeNull()
  })

  it('logs in and persists the session in state', async () => {
    await useAuthStore.getState().signup({ email: 'store@test.com', password: 'pw123456', nickname: '헌터' })
    expect(useAuthStore.getState().session?.nickname).toBe('헌터')
  })

  it('logs out by clearing the session', async () => {
    await useAuthStore.getState().signup({ email: 'store2@test.com', password: 'pw123456', nickname: '헌터' })
    useAuthStore.getState().logout()
    expect(useAuthStore.getState().session).toBeNull()
  })

  it('addXp updates currentXp and level via getLevelInfo', async () => {
    await useAuthStore.getState().signup({ email: 'store3@test.com', password: 'pw123456', nickname: '헌터' })
    useAuthStore.getState().addXp(200)
    expect(useAuthStore.getState().session?.currentXp).toBe(200)
  })
})
```

- [ ] **Step 2: Run to verify it fails**

```bash
npx vitest run src/stores/authStore.test.ts
```

Expected: FAIL — `authStore.ts` does not exist.

- [ ] **Step 3: Implement the store**

```typescript
// src/stores/authStore.ts
import { create } from 'zustand'
import { authService } from '@services/authService'
import { setAuthToken } from '@services/api'
import { getLevelInfo } from '@utils/levels'
import type { AuthSession, LoginPayload, SignupPayload } from '@types/auth'

interface AuthState {
  session: AuthSession | null
  isLoading: boolean
  signup: (payload: SignupPayload) => Promise<void>
  login: (payload: LoginPayload) => Promise<void>
  logout: () => void
  addXp: (amount: number) => { levelUp: boolean; newLevel: number }
}

export const useAuthStore = create<AuthState>((set, get) => ({
  session: null,
  isLoading: false,

  signup: async (payload) => {
    set({ isLoading: true })
    try {
      const session = await authService.signup(payload)
      setAuthToken(session.token)
      set({ session, isLoading: false })
    } catch (err) {
      set({ isLoading: false })
      throw err
    }
  },

  login: async (payload) => {
    set({ isLoading: true })
    try {
      const session = await authService.login(payload)
      setAuthToken(session.token)
      set({ session, isLoading: false })
    } catch (err) {
      set({ isLoading: false })
      throw err
    }
  },

  logout: () => {
    setAuthToken(null)
    set({ session: null })
  },

  addXp: (amount) => {
    const current = get().session
    if (!current) return { levelUp: false, newLevel: 1 }

    const previousLevel = getLevelInfo(current.currentXp).level
    const newTotalXp = current.currentXp + amount
    const info = getLevelInfo(newTotalXp)

    set({ session: { ...current, currentXp: newTotalXp, level: info.level } })
    return { levelUp: info.level > previousLevel, newLevel: info.level }
  },
}))
```

- [ ] **Step 4: Run to verify it passes**

```bash
npx vitest run src/stores/authStore.test.ts
```

Expected: PASS.

- [ ] **Step 5: Thin `useAuth` hook**

```typescript
// src/hooks/useAuth.ts
import { useAuthStore } from '@stores/authStore'

export function useAuth() {
  const session = useAuthStore((s) => s.session)
  const isLoading = useAuthStore((s) => s.isLoading)
  const login = useAuthStore((s) => s.login)
  const signup = useAuthStore((s) => s.signup)
  const logout = useAuthStore((s) => s.logout)

  return { session, isAuthenticated: session !== null, isLoading, login, signup, logout }
}
```

- [ ] **Step 6: Commit**

```bash
git add frontend/src/stores frontend/src/hooks
git commit -m "feat(web): add auth store and useAuth hook"
```

---

### Task 9: Routing Shell, Protected Route & Login/Signup Pages

**Files:**
- Create: `frontend/src/components/auth/LoginForm.tsx`, `frontend/src/components/auth/LoginForm.test.tsx`, `frontend/src/components/auth/SignupForm.tsx`, `frontend/src/components/common/ProtectedRoute.tsx`, `frontend/src/pages/LoginPage.tsx`, `frontend/src/pages/SignupPage.tsx`, `frontend/src/pages/NotFoundPage.tsx`
- Modify: `frontend/src/App.tsx`, `frontend/src/main.tsx`

**Interfaces:**
- Consumes: `useAuth` (Task 8), `worker` (Task 5, started conditionally in `main.tsx`).
- Produces: the app's route tree (`/login`, `/signup`, `/` protected, `*` 404) — `HomePage`/`GamePage` routes are added by Tasks 12 and 22 by editing `App.tsx`'s route list.

- [ ] **Step 1: Write failing test for `LoginForm`**

```tsx
// src/components/auth/LoginForm.test.tsx
import { describe, it, expect, vi } from 'vitest'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { LoginForm } from './LoginForm'

describe('LoginForm', () => {
  it('calls onSubmit with entered credentials', async () => {
    const onSubmit = vi.fn().mockResolvedValue(undefined)
    render(<LoginForm onSubmit={onSubmit} isLoading={false} />)

    await userEvent.type(screen.getByLabelText('이메일'), 'a@test.com')
    await userEvent.type(screen.getByLabelText('비밀번호'), 'pw123456')
    await userEvent.click(screen.getByRole('button', { name: '로그인' }))

    expect(onSubmit).toHaveBeenCalledWith({ email: 'a@test.com', password: 'pw123456' })
  })
})
```

- [ ] **Step 2: Run to verify it fails**

```bash
npx vitest run src/components/auth/LoginForm.test.tsx
```

Expected: FAIL — `LoginForm.tsx` does not exist.

- [ ] **Step 3: Implement `LoginForm.tsx`**

```tsx
// src/components/auth/LoginForm.tsx
import { useState, FormEvent } from 'react'
import type { LoginPayload } from '@types/auth'

interface LoginFormProps {
  onSubmit: (payload: LoginPayload) => Promise<void>
  isLoading: boolean
}

export function LoginForm({ onSubmit, isLoading }: LoginFormProps) {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault()
    onSubmit({ email, password })
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-4 max-w-sm mx-auto">
      <label className="flex flex-col gap-1">
        이메일
        <input
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          className="border rounded px-3 py-2"
          required
        />
      </label>
      <label className="flex flex-col gap-1">
        비밀번호
        <input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          className="border rounded px-3 py-2"
          required
        />
      </label>
      <button
        type="submit"
        disabled={isLoading}
        className="bg-primary text-white rounded px-4 py-2 disabled:opacity-50"
      >
        로그인
      </button>
    </form>
  )
}
```

- [ ] **Step 4: Run to verify it passes**

```bash
npx vitest run src/components/auth/LoginForm.test.tsx
```

Expected: PASS.

- [ ] **Step 5: `SignupForm.tsx` (same shape, one extra field — no separate test, mirrors verified LoginForm pattern)**

```tsx
// src/components/auth/SignupForm.tsx
import { useState, FormEvent } from 'react'
import type { SignupPayload } from '@types/auth'

interface SignupFormProps {
  onSubmit: (payload: SignupPayload) => Promise<void>
  isLoading: boolean
}

export function SignupForm({ onSubmit, isLoading }: SignupFormProps) {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [nickname, setNickname] = useState('')

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault()
    onSubmit({ email, password, nickname })
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-4 max-w-sm mx-auto">
      <label className="flex flex-col gap-1">
        닉네임
        <input value={nickname} onChange={(e) => setNickname(e.target.value)} className="border rounded px-3 py-2" required />
      </label>
      <label className="flex flex-col gap-1">
        이메일
        <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} className="border rounded px-3 py-2" required />
      </label>
      <label className="flex flex-col gap-1">
        비밀번호
        <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} className="border rounded px-3 py-2" required minLength={8} />
      </label>
      <button type="submit" disabled={isLoading} className="bg-primary text-white rounded px-4 py-2 disabled:opacity-50">
        회원가입
      </button>
    </form>
  )
}
```

- [ ] **Step 6: `ProtectedRoute.tsx`**

```tsx
// src/components/common/ProtectedRoute.tsx
import { Navigate, Outlet } from 'react-router-dom'
import { useAuth } from '@hooks/useAuth'

export function ProtectedRoute() {
  const { isAuthenticated } = useAuth()
  return isAuthenticated ? <Outlet /> : <Navigate to="/login" replace />
}
```

- [ ] **Step 7: `LoginPage.tsx` / `SignupPage.tsx` / `NotFoundPage.tsx`**

```tsx
// src/pages/LoginPage.tsx
import { useNavigate, Link } from 'react-router-dom'
import toast from 'react-hot-toast'
import { LoginForm } from '@components/auth/LoginForm'
import { useAuth } from '@hooks/useAuth'

export function LoginPage() {
  const { login, isLoading } = useAuth()
  const navigate = useNavigate()

  const handleSubmit = async (payload: { email: string; password: string }) => {
    try {
      await login(payload)
      navigate('/')
    } catch {
      toast.error('로그인에 실패했습니다.')
    }
  }

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold text-center mb-6">Phishing Defense</h1>
      <LoginForm onSubmit={handleSubmit} isLoading={isLoading} />
      <p className="text-center mt-4">
        계정이 없나요? <Link to="/signup" className="text-primary">회원가입</Link>
      </p>
    </div>
  )
}
```

```tsx
// src/pages/SignupPage.tsx
import { useNavigate, Link } from 'react-router-dom'
import toast from 'react-hot-toast'
import { SignupForm } from '@components/auth/SignupForm'
import { useAuth } from '@hooks/useAuth'

export function SignupPage() {
  const { signup, isLoading } = useAuth()
  const navigate = useNavigate()

  const handleSubmit = async (payload: { email: string; password: string; nickname: string }) => {
    try {
      await signup(payload)
      navigate('/')
    } catch {
      toast.error('회원가입에 실패했습니다.')
    }
  }

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold text-center mb-6">피싱 헌터 되기</h1>
      <SignupForm onSubmit={handleSubmit} isLoading={isLoading} />
      <p className="text-center mt-4">
        이미 계정이 있나요? <Link to="/login" className="text-primary">로그인</Link>
      </p>
    </div>
  )
}
```

```tsx
// src/pages/NotFoundPage.tsx
import { Link } from 'react-router-dom'

export function NotFoundPage() {
  return (
    <div className="p-8 text-center">
      <p className="text-xl mb-4">페이지를 찾을 수 없습니다.</p>
      <Link to="/" className="text-primary">홈으로 돌아가기</Link>
    </div>
  )
}
```

- [ ] **Step 8: Wire routing and MSW bootstrap**

```tsx
// src/App.tsx
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { Toaster } from 'react-hot-toast'
import { ProtectedRoute } from '@components/common/ProtectedRoute'
import { LoginPage } from '@pages/LoginPage'
import { SignupPage } from '@pages/SignupPage'
import { NotFoundPage } from '@pages/NotFoundPage'

const queryClient = new QueryClient()

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <Toaster position="top-center" />
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route path="/signup" element={<SignupPage />} />
          <Route element={<ProtectedRoute />}>
            <Route path="/" element={<Navigate to="/login" replace />} />
          </Route>
          <Route path="*" element={<NotFoundPage />} />
        </Routes>
      </BrowserRouter>
    </QueryClientProvider>
  )
}
```

(The `/` route is a placeholder `Navigate` until Task 12 replaces it with `HomePage`.)

```tsx
// src/main.tsx
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

async function bootstrap() {
  if (import.meta.env.VITE_ENABLE_MOCKS === 'true') {
    const { worker } = await import('@mocks/browser')
    await worker.start({ onUnhandledRequest: 'bypass' })
  }

  ReactDOM.createRoot(document.getElementById('root')!).render(
    <React.StrictMode>
      <App />
    </React.StrictMode>,
  )
}

bootstrap()
```

- [ ] **Step 9: Manual verification**

```bash
npm run dev
```

Visit `http://localhost:3000/signup`, create an account, confirm redirect to `/` (shows blank/placeholder — expected until Task 12).

- [ ] **Step 10: Commit**

```bash
git add frontend/src
git commit -m "feat(web): add routing shell, protected route, and auth pages"
```

---

### Task 10: Chapter Mock Handlers

**Files:**
- Create: `frontend/src/mocks/handlers/game.ts`, `frontend/src/mocks/handlers/game.test.ts`
- Modify: `frontend/src/mocks/handlers.ts`, `frontend/src/mocks/db.ts` (add a helper)

**Interfaces:**
- Consumes: `mockDb`, `userIdFromToken` (Task 5), `SCENARIO_1_1`, `AUTO_EVIDENCE_ON_START`, `INITIAL_SMS` (Task 4).
- Produces: handlers for `GET /api/v1/chapters`, `GET /api/v1/chapters/:chapterId/scenarios`, `POST /api/v1/scenarios/:scenarioId/start`, `GET /api/v1/scenarios/:recordId/status` — consumed by Task 11's `gameService`.

- [ ] **Step 1: Write failing tests**

```typescript
// src/mocks/handlers/game.test.ts
import { describe, it, expect } from 'vitest'

const BASE = 'http://localhost:8080/api/v1'

async function signupAndGetToken(email: string) {
  const res = await fetch(`${BASE}/auth/signup`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password: 'pw123456', nickname: '헌터' }),
  })
  return (await res.json()).token as string
}

describe('game mock handlers', () => {
  it('lists chapters with chapter 1 unlocked', async () => {
    const token = await signupAndGetToken('game1@test.com')
    const res = await fetch(`${BASE}/chapters`, { headers: { Authorization: `Bearer ${token}` } })
    const body = await res.json()
    expect(body[0].chapter_id).toBe(1)
    expect(body[0].is_unlocked).toBe(true)
    expect(body[1].is_unlocked).toBe(false)
  })

  it('lists scenarios for a chapter', async () => {
    const token = await signupAndGetToken('game2@test.com')
    const res = await fetch(`${BASE}/chapters/1/scenarios`, { headers: { Authorization: `Bearer ${token}` } })
    const body = await res.json()
    expect(body[0].scenario_id).toBe(101)
  })

  it('starts a scenario and returns the initial SMS', async () => {
    const token = await signupAndGetToken('game3@test.com')
    const res = await fetch(`${BASE}/scenarios/101/start`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}` },
    })
    expect(res.status).toBe(201)
    const body = await res.json()
    expect(body.record_id).toBeGreaterThan(0)
    expect(body.initial_message).toContain('국민은행')
  })

  it('returns scenario status at stage 1', async () => {
    const token = await signupAndGetToken('game4@test.com')
    const start = await fetch(`${BASE}/scenarios/101/start`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}` },
    })
    const { record_id } = await start.json()

    const res = await fetch(`${BASE}/scenarios/${record_id}/status`, {
      headers: { Authorization: `Bearer ${token}` },
    })
    const body = await res.json()
    expect(body.stage).toBe(1)
    expect(body.hints_remaining).toBe(3)
  })
})
```

- [ ] **Step 2: Run to verify it fails**

```bash
npx vitest run src/mocks/handlers/game.test.ts
```

Expected: FAIL — handlers don't exist.

- [ ] **Step 3: Implement handlers**

```typescript
// src/mocks/handlers/game.ts
import { http, HttpResponse } from 'msw'
import { mockDb, userIdFromToken } from '../db'
import { SCENARIO_1_1, INITIAL_SMS, AUTO_EVIDENCE_ON_START } from '../scenarioData'

const BASE = '*/api/v1'

function requireUser(request: Request) {
  return userIdFromToken(request.headers.get('Authorization'))
}

export const gameHandlers = [
  http.get(`${BASE}/chapters`, ({ request }) => {
    if (!requireUser(request)) return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })
    return HttpResponse.json(
      mockDb.chapters.map((c) => ({
        chapter_id: c.chapterId,
        title: c.title,
        difficulty: c.difficulty,
        is_unlocked: c.isUnlocked,
        best_star: c.bestStar,
        is_completed: c.isCompleted,
      })),
    )
  }),

  http.get(`${BASE}/chapters/:chapterId/scenarios`, ({ request }) => {
    if (!requireUser(request)) return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })
    return HttpResponse.json([
      { scenario_id: SCENARIO_1_1.scenarioId, title: SCENARIO_1_1.title, phishing_type: SCENARIO_1_1.phishingType },
    ])
  }),

  http.post(`${BASE}/scenarios/:scenarioId/start`, ({ request }) => {
    const userId = requireUser(request)
    if (!userId) return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })

    const record = mockDb.createRecord(userId, SCENARIO_1_1.scenarioId)
    record.chatHistory.push({ turn: 0, sender: 'ai_criminal', message: INITIAL_SMS, timestamp: new Date().toISOString() })

    return HttpResponse.json(
      { record_id: record.recordId, initial_message: INITIAL_SMS, timestamp: new Date().toISOString() },
      { status: 201 },
    )
  }),

  http.get(`${BASE}/scenarios/:recordId/status`, ({ request, params }) => {
    if (!requireUser(request)) return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })
    const record = mockDb.records.get(Number(params.recordId))
    if (!record) return HttpResponse.json({ message: 'not found' }, { status: 404 })

    return HttpResponse.json({
      record_id: record.recordId,
      scenario_id: record.scenarioId,
      stage: record.stage,
      current_turn: record.currentTurn,
      is_completed: record.stage === 6 && record.claimed,
      hints_remaining: record.hintsRemaining,
    })
  }),
]
```

Note: `AUTO_EVIDENCE_ON_START` is imported for use by Task 19's evidence handler, which reads `mockDb.records` populated here — no direct call needed in this file, so remove the unused import if `type-check`/lint flags it, or leave the evidence attachment to Task 19 as planned. Remove the unused `AUTO_EVIDENCE_ON_START` import now to keep the build clean:

```typescript
import { SCENARIO_1_1, INITIAL_SMS } from '../scenarioData'
```

- [ ] **Step 4: Register handlers**

```typescript
// src/mocks/handlers.ts
import type { HttpHandler } from 'msw'
import { authHandlers } from './handlers/auth'
import { gameHandlers } from './handlers/game'

export const handlers: HttpHandler[] = [...authHandlers, ...gameHandlers]
```

- [ ] **Step 5: Run to verify it passes**

```bash
npx vitest run src/mocks/handlers/game.test.ts
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add frontend/src/mocks
git commit -m "feat(web): add chapter/scenario mock handlers"
```

---

### Task 11: Game Service & Chapter/Scenario Hooks

**Files:**
- Create: `frontend/src/services/gameService.ts`, `frontend/src/hooks/useChapters.ts`, `frontend/src/hooks/useScenario.ts`

**Interfaces:**
- Consumes: `apiClient` (Task 7), `Chapter`/`Scenario`/`ScenarioStartResponse`/`ScenarioStatus` (Task 2), handlers from Task 10.
- Produces: `gameService.getChapters/getScenarios/startScenario/getStatus`, `useChapters()` (React Query), `useScenario(recordId)` (React Query, polling) — consumed by Task 12 (Dashboard) and Task 16 (GameLayout).

- [ ] **Step 1: `gameService.ts`**

```typescript
// src/services/gameService.ts
import { apiClient } from './api'
import type { Chapter, Scenario, ScenarioStartResponse, ScenarioStatus } from '@types/game'

interface ChapterWire {
  chapter_id: number
  title: string
  difficulty: number
  is_unlocked: boolean
  best_star: number
  is_completed: boolean
}

interface ScenarioWire {
  scenario_id: number
  title: string
  phishing_type: string
}

interface StartWire {
  record_id: number
  initial_message: string
  timestamp: string
}

interface StatusWire {
  record_id: number
  scenario_id: number
  stage: 1 | 2 | 3 | 4 | 5 | 6
  current_turn: number
  is_completed: boolean
  hints_remaining: number
}

export const gameService = {
  async getChapters(): Promise<Chapter[]> {
    const { data } = await apiClient.get<ChapterWire[]>('/api/v1/chapters')
    return data.map((c) => ({
      chapterId: c.chapter_id,
      title: c.title,
      difficulty: c.difficulty,
      isUnlocked: c.is_unlocked,
      bestStar: c.best_star,
      isCompleted: c.is_completed,
    }))
  },

  async getScenarios(chapterId: number): Promise<Scenario[]> {
    const { data } = await apiClient.get<ScenarioWire[]>(`/api/v1/chapters/${chapterId}/scenarios`)
    return data.map((s) => ({ scenarioId: s.scenario_id, title: s.title, phishingType: s.phishing_type }))
  },

  async startScenario(scenarioId: number): Promise<ScenarioStartResponse> {
    const { data } = await apiClient.post<StartWire>(`/api/v1/scenarios/${scenarioId}/start`)
    return { recordId: data.record_id, initialMessage: data.initial_message, timestamp: data.timestamp }
  },

  async getStatus(recordId: number): Promise<ScenarioStatus> {
    const { data } = await apiClient.get<StatusWire>(`/api/v1/scenarios/${recordId}/status`)
    return {
      recordId: data.record_id,
      scenarioId: data.scenario_id,
      stage: data.stage,
      currentTurn: data.current_turn,
      isCompleted: data.is_completed,
      hintsRemaining: data.hints_remaining,
    }
  },
}
```

- [ ] **Step 2: `useChapters.ts`**

```typescript
// src/hooks/useChapters.ts
import { useQuery } from '@tanstack/react-query'
import { gameService } from '@services/gameService'

export function useChapters() {
  return useQuery({ queryKey: ['chapters'], queryFn: gameService.getChapters })
}
```

- [ ] **Step 3: `useScenario.ts`**

```typescript
// src/hooks/useScenario.ts
import { useQuery } from '@tanstack/react-query'
import { gameService } from '@services/gameService'

export function useScenarioStatus(recordId: number | null) {
  return useQuery({
    queryKey: ['scenario-status', recordId],
    queryFn: () => gameService.getStatus(recordId as number),
    enabled: recordId !== null,
  })
}
```

- [ ] **Step 4: Verify compile**

```bash
npm run type-check
```

Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add frontend/src/services frontend/src/hooks
git commit -m "feat(web): add game service and chapter/scenario query hooks"
```

---

### Task 12: Dashboard Page

**Files:**
- Create: `frontend/src/components/dashboard/ChapterCard.tsx`, `frontend/src/components/dashboard/Dashboard.tsx`, `frontend/src/pages/HomePage.tsx`
- Modify: `frontend/src/App.tsx` (replace the `/` placeholder route)

**Interfaces:**
- Consumes: `useChapters` (Task 11), `useAuth` (Task 8), `getLevelInfo` (Task 3), `gameService.startScenario` (Task 11).
- Produces: `HomePage` at route `/` — navigates to `/game/:recordId` on "계속 진행하기" (route registered here, consumed by Task 22's `GamePage`).

- [ ] **Step 1: `ChapterCard.tsx`**

```tsx
// src/components/dashboard/ChapterCard.tsx
import type { Chapter } from '@types/game'
import { Lock } from 'lucide-react'

interface ChapterCardProps {
  chapter: Chapter
  onPlay: () => void
}

export function ChapterCard({ chapter, onPlay }: ChapterCardProps) {
  return (
    <div className="border rounded-lg p-4 flex items-center justify-between">
      <div>
        <p className="font-semibold">
          Chapter {chapter.chapterId}: {chapter.title}
        </p>
        <p className="text-sm text-gray-500">
          {chapter.isCompleted ? '★'.repeat(chapter.bestStar).padEnd(3, '☆') : '미완료'}
        </p>
      </div>
      {chapter.isUnlocked ? (
        <button onClick={onPlay} className="bg-primary text-white rounded px-3 py-1.5 text-sm">
          플레이
        </button>
      ) : (
        <Lock className="text-gray-400" size={20} />
      )}
    </div>
  )
}
```

- [ ] **Step 2: `Dashboard.tsx`**

```tsx
// src/components/dashboard/Dashboard.tsx
import { useNavigate } from 'react-router-dom'
import toast from 'react-hot-toast'
import { useChapters } from '@hooks/useChapters'
import { useAuth } from '@hooks/useAuth'
import { gameService } from '@services/gameService'
import { getLevelInfo } from '@utils/levels'
import { ChapterCard } from './ChapterCard'

export function Dashboard() {
  const { session } = useAuth()
  const { data: chapters, isLoading } = useChapters()
  const navigate = useNavigate()

  const handlePlay = async (scenarioId: number) => {
    try {
      const { recordId } = await gameService.startScenario(scenarioId)
      navigate(`/game/${recordId}`)
    } catch {
      toast.error('시나리오를 시작할 수 없습니다.')
    }
  }

  if (!session) return null
  const levelInfo = getLevelInfo(session.currentXp)

  return (
    <div className="max-w-md mx-auto p-4 flex flex-col gap-6">
      <header>
        <p className="text-lg font-bold">{session.nickname}</p>
        <p className="text-sm text-gray-500">
          Lv.{levelInfo.level} · {levelInfo.currentLevelXp}/{levelInfo.xpForNextLevel - (levelInfo.xpForNextLevel - levelInfo.currentLevelXp - (session.currentXp - levelInfo.currentLevelXp))} XP
        </p>
      </header>

      <section className="flex flex-col gap-3">
        <h2 className="font-semibold">📚 Story Progress</h2>
        {isLoading && <p>불러오는 중...</p>}
        {chapters?.map((chapter) => (
          <ChapterCard
            key={chapter.chapterId}
            chapter={chapter}
            onPlay={() => handlePlay(101 /* Scenario 1-1, hardcoded for the single-scenario MVP */)}
          />
        ))}
      </section>
    </div>
  )
}
```

- [ ] **Step 3: Fix the XP display math**

The inline calculation in Step 2's header is unnecessarily convoluted. Simplify to just the two numbers `getLevelInfo` already gives:

```tsx
<p className="text-sm text-gray-500">
  Lv.{levelInfo.level} · {levelInfo.currentLevelXp} XP
</p>
```

- [ ] **Step 4: `HomePage.tsx`**

```tsx
// src/pages/HomePage.tsx
import { Dashboard } from '@components/dashboard/Dashboard'

export function HomePage() {
  return <Dashboard />
}
```

- [ ] **Step 5: Wire the route**

In `src/App.tsx`, replace:
```tsx
<Route path="/" element={<Navigate to="/login" replace />} />
```
with:
```tsx
<Route path="/" element={<HomePage />} />
```
and add `import { HomePage } from '@pages/HomePage'` at the top.

- [ ] **Step 6: Manual verification**

```bash
npm run dev
```
Sign up, land on `/`, confirm Chapter 1 card shows "플레이" and Chapter 2 shows a lock icon; click "플레이" and confirm navigation to `/game/<id>` (blank page — expected until Task 22 adds `GamePage`).

- [ ] **Step 7: Commit**

```bash
git add frontend/src
git commit -m "feat(web): add dashboard with chapter list and level display"
```

---

### Task 13: Chat Mock Handlers

**Files:**
- Create: `frontend/src/mocks/handlers/chat.ts`, `frontend/src/mocks/handlers/chat.test.ts`
- Modify: `frontend/src/mocks/handlers.ts`

**Interfaces:**
- Consumes: `mockDb`, `userIdFromToken` (Task 5), `criminalReplyForTurn`, `policeReplyForTurn`, `AUTO_EVIDENCE_BY_TURN`, `HINT_TEXTS` (Task 4).
- Produces: handlers for `POST /api/v1/chat/:recordId/send`, `GET /api/v1/chat/:recordId/history`, `POST /api/v1/chat/:recordId/hint` — consumed by Task 14's `chatService`.

- [ ] **Step 1: Write failing tests**

```typescript
// src/mocks/handlers/chat.test.ts
import { describe, it, expect } from 'vitest'

const BASE = 'http://localhost:8080/api/v1'

async function setup() {
  const signup = await fetch(`${BASE}/auth/signup`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: `chat${Math.random()}@test.com`, password: 'pw123456', nickname: '헌터' }),
  })
  const { token } = await signup.json()
  const start = await fetch(`${BASE}/scenarios/101/start`, { method: 'POST', headers: { Authorization: `Bearer ${token}` } })
  const { record_id } = await start.json()
  return { token, recordId: record_id as number }
}

describe('chat mock handlers', () => {
  it('sends a message and gets a scripted criminal reply with extracted evidence', async () => {
    const { token, recordId } = await setup()
    const res = await fetch(`${BASE}/chat/${recordId}/send`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: '누구세요?', stage: 2 }),
    })
    const body = await res.json()
    expect(body.turn).toBe(1)
    expect(body.ai_response).toContain('본인 확인')
    expect(body.extracted_evidence.length).toBeGreaterThan(0)
  })

  it('returns full chat history including the initial SMS', async () => {
    const { token, recordId } = await setup()
    await fetch(`${BASE}/chat/${recordId}/send`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: '누구세요?', stage: 2 }),
    })
    const res = await fetch(`${BASE}/chat/${recordId}/history`, { headers: { Authorization: `Bearer ${token}` } })
    const body = await res.json()
    expect(body.length).toBe(2) // initial SMS + 1 exchange counted as 1 pair server-side... see handler
  })

  it('gives a hint and decrements remaining hints', async () => {
    const { token, recordId } = await setup()
    const res = await fetch(`${BASE}/chat/${recordId}/hint`, { method: 'POST', headers: { Authorization: `Bearer ${token}` } })
    const body = await res.json()
    expect(body.hints_remaining).toBe(2)
    expect(body.hint_text.length).toBeGreaterThan(0)
  })
})
```

- [ ] **Step 2: Run to verify it fails**

```bash
npx vitest run src/mocks/handlers/chat.test.ts
```

Expected: FAIL — handlers don't exist.

- [ ] **Step 3: Implement handlers**

The history endpoint returns one entry per stored `ChatMessage` (both `ai_criminal`/`ai_police` and `user` turns are pushed individually), so Step 1's history test assertion of `length: 2` is wrong — one `send` call pushes 2 messages (user + AI) onto a history that already had 1 (the initial SMS) = 3. Fix the test to `expect(body.length).toBe(3)` before running.

```typescript
// src/mocks/handlers/chat.ts
import { http, HttpResponse } from 'msw'
import { mockDb, userIdFromToken } from '../db'
import { criminalReplyForTurn, policeReplyForTurn, AUTO_EVIDENCE_BY_TURN, HINT_TEXTS } from '../scenarioData'
import type { Stage } from '@types/game'

const BASE = '*/api/v1'

export const chatHandlers = [
  http.post(`${BASE}/chat/:recordId/send`, async ({ request, params }) => {
    if (!userIdFromToken(request.headers.get('Authorization'))) {
      return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })
    }
    const record = mockDb.records.get(Number(params.recordId))
    if (!record) return HttpResponse.json({ message: 'not found' }, { status: 404 })

    const { message, stage } = (await request.json()) as { message: string; stage: Stage }
    const turn = record.currentTurn + 1
    const now = new Date().toISOString()

    record.chatHistory.push({ turn, sender: 'user', message, timestamp: now })

    const isPolice = stage === 5
    const aiReply = isPolice ? policeReplyForTurn(turn) : criminalReplyForTurn(turn)
    record.chatHistory.push({ turn, sender: isPolice ? 'ai_police' : 'ai_criminal', message: aiReply, timestamp: now })

    record.currentTurn = turn
    if (isPolice) record.policeTurnsCompleted = turn

    const extractedEvidence = AUTO_EVIDENCE_BY_TURN[turn] ?? []
    const stageComplete = isPolice ? turn >= 2 : turn >= 2

    return HttpResponse.json(
      {
        ai_response: aiReply,
        turn,
        extracted_evidence: extractedEvidence,
        hints_remaining: record.hintsRemaining,
        stage_complete: stageComplete,
      },
      { status: 201 },
    )
  }),

  http.get(`${BASE}/chat/:recordId/history`, ({ request, params }) => {
    if (!userIdFromToken(request.headers.get('Authorization'))) {
      return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })
    }
    const record = mockDb.records.get(Number(params.recordId))
    if (!record) return HttpResponse.json({ message: 'not found' }, { status: 404 })

    return HttpResponse.json(
      record.chatHistory.map((m) => ({ turn: m.turn, sender: m.sender, message: m.message, timestamp: m.timestamp })),
    )
  }),

  http.post(`${BASE}/chat/:recordId/hint`, ({ request, params }) => {
    if (!userIdFromToken(request.headers.get('Authorization'))) {
      return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })
    }
    const record = mockDb.records.get(Number(params.recordId))
    if (!record) return HttpResponse.json({ message: 'not found' }, { status: 404 })
    if (record.hintsRemaining <= 0) {
      return HttpResponse.json({ message: '남은 힌트가 없습니다.' }, { status: 400 })
    }

    record.hintsUsed += 1
    record.hintsRemaining -= 1

    return HttpResponse.json({ hint_text: HINT_TEXTS[record.stage], hints_remaining: record.hintsRemaining })
  }),
]
```

- [ ] **Step 4: Register handlers**

```typescript
// src/mocks/handlers.ts
import type { HttpHandler } from 'msw'
import { authHandlers } from './handlers/auth'
import { gameHandlers } from './handlers/game'
import { chatHandlers } from './handlers/chat'

export const handlers: HttpHandler[] = [...authHandlers, ...gameHandlers, ...chatHandlers]
```

- [ ] **Step 5: Run to verify it passes**

```bash
npx vitest run src/mocks/handlers/chat.test.ts
```

Expected: PASS (after the Step 3 test-assertion fix).

- [ ] **Step 6: Commit**

```bash
git add frontend/src/mocks
git commit -m "feat(web): add chat mock handlers (send/history/hint)"
```

---

### Task 14: Chat Service & useChat Hook

**Files:**
- Create: `frontend/src/services/chatService.ts`, `frontend/src/hooks/useChat.ts`

**Interfaces:**
- Consumes: `apiClient` (Task 7), `ChatMessage`/`ChatSendResponse`/`HintResponse` (Task 2), handlers from Task 13.
- Produces: `chatService.sendMessage/getHistory/requestHint`, `useChat(recordId, stage)` (returns `messages`, `send`, `requestHint`, `isSending`) — consumed by Task 17 (`Stage2_Chat`) and Task 20 (`Stage5_Report`).

- [ ] **Step 1: `chatService.ts`**

```typescript
// src/services/chatService.ts
import { apiClient } from './api'
import type { ChatMessage, ChatSendResponse, HintResponse, Stage } from '@types/game'

interface HistoryWire {
  turn: number
  sender: ChatMessage['sender']
  message: string
  timestamp: string
}

interface SendWire {
  ai_response: string
  turn: number
  extracted_evidence: { type: string; value: string }[]
  hints_remaining: number
  stage_complete: boolean
}

interface HintWire {
  hint_text: string
  hints_remaining: number
}

export const chatService = {
  async getHistory(recordId: number): Promise<ChatMessage[]> {
    const { data } = await apiClient.get<HistoryWire[]>(`/api/v1/chat/${recordId}/history`)
    return data
  },

  async sendMessage(recordId: number, message: string, stage: Stage): Promise<ChatSendResponse> {
    const { data } = await apiClient.post<SendWire>(`/api/v1/chat/${recordId}/send`, { message, stage })
    return {
      aiResponse: data.ai_response,
      turn: data.turn,
      extractedEvidence: data.extracted_evidence,
      hintsRemaining: data.hints_remaining,
      stageComplete: data.stage_complete,
    }
  },

  async requestHint(recordId: number): Promise<HintResponse> {
    const { data } = await apiClient.post<HintWire>(`/api/v1/chat/${recordId}/hint`)
    return { hintText: data.hint_text, hintsRemaining: data.hints_remaining }
  },
}
```

- [ ] **Step 2: `useChat.ts`**

```typescript
// src/hooks/useChat.ts
import { useState, useEffect, useCallback } from 'react'
import { chatService } from '@services/chatService'
import type { ChatMessage, Stage } from '@types/game'

export function useChat(recordId: number, stage: Stage) {
  const [messages, setMessages] = useState<ChatMessage[]>([])
  const [isSending, setIsSending] = useState(false)
  const [stageComplete, setStageComplete] = useState(false)

  useEffect(() => {
    chatService.getHistory(recordId).then(setMessages)
  }, [recordId])

  const send = useCallback(
    async (text: string) => {
      setIsSending(true)
      try {
        const result = await chatService.sendMessage(recordId, text, stage)
        const history = await chatService.getHistory(recordId)
        setMessages(history)
        if (result.stageComplete) setStageComplete(true)
        return result
      } finally {
        setIsSending(false)
      }
    },
    [recordId, stage],
  )

  const requestHint = useCallback(() => chatService.requestHint(recordId), [recordId])

  return { messages, send, requestHint, isSending, stageComplete }
}
```

- [ ] **Step 3: Verify compile**

```bash
npm run type-check
```

Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add frontend/src/services frontend/src/hooks
git commit -m "feat(web): add chat service and useChat hook"
```

---

### Task 15: Game Store & GameLayout Shell

**Files:**
- Create: `frontend/src/stores/gameStore.ts`, `frontend/src/components/game/GameLayout.tsx`, `frontend/src/components/common/ProgressBar.tsx`, `frontend/src/components/common/ProgressBar.test.tsx`

**Interfaces:**
- Consumes: `ScenarioStatus` (Task 2), `useScenarioStatus` (Task 11).
- Produces: `useGameStore` (holds `recordId`, `startedAt` for client-side duration tracking), `<GameLayout>` (renders header + progress + `children`, used by Task 22's `GamePage` to wrap every stage), `<ProgressBar>` (reused by Task 12's Dashboard XP bar too — retrofit Dashboard to use it in this task).

- [ ] **Step 1: Write failing test for `ProgressBar`**

```tsx
// src/components/common/ProgressBar.test.tsx
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import { ProgressBar } from './ProgressBar'

describe('ProgressBar', () => {
  it('renders a fill width proportional to the ratio', () => {
    render(<ProgressBar ratio={0.75} label="80%" />)
    const fill = screen.getByTestId('progress-fill')
    expect(fill).toHaveStyle({ width: '75%' })
    expect(screen.getByText('80%')).toBeInTheDocument()
  })

  it('clamps ratio to [0, 1]', () => {
    render(<ProgressBar ratio={1.5} label="over" />)
    expect(screen.getByTestId('progress-fill')).toHaveStyle({ width: '100%' })
  })
})
```

- [ ] **Step 2: Run to verify it fails**

```bash
npx vitest run src/components/common/ProgressBar.test.tsx
```

Expected: FAIL — component does not exist.

- [ ] **Step 3: Implement `ProgressBar.tsx`**

```tsx
// src/components/common/ProgressBar.tsx
interface ProgressBarProps {
  ratio: number
  label?: string
}

export function ProgressBar({ ratio, label }: ProgressBarProps) {
  const clamped = Math.min(1, Math.max(0, ratio))
  return (
    <div className="flex items-center gap-2">
      <div className="flex-1 h-2 bg-gray-200 rounded-full overflow-hidden">
        <div
          data-testid="progress-fill"
          className="h-full bg-primary transition-all"
          style={{ width: `${clamped * 100}%` }}
        />
      </div>
      {label && <span className="text-xs text-gray-500 whitespace-nowrap">{label}</span>}
    </div>
  )
}
```

- [ ] **Step 4: Run to verify it passes**

```bash
npx vitest run src/components/common/ProgressBar.test.tsx
```

Expected: PASS.

- [ ] **Step 5: Retrofit Dashboard to use `ProgressBar`**

In `src/components/dashboard/Dashboard.tsx`, replace the plain XP text line with:
```tsx
<ProgressBar ratio={levelInfo.progressRatio} label={`${levelInfo.currentLevelXp} XP`} />
```
adding `import { ProgressBar } from '@components/common/ProgressBar'`.

- [ ] **Step 6: `gameStore.ts`**

```typescript
// src/stores/gameStore.ts
import { create } from 'zustand'

interface GameState {
  recordId: number | null
  startedAt: number | null
  hintsUsedThisRun: number
  start: (recordId: number) => void
  incrementHint: () => void
  elapsedSeconds: () => number
  reset: () => void
}

export const useGameStore = create<GameState>((set, get) => ({
  recordId: null,
  startedAt: null,
  hintsUsedThisRun: 0,

  start: (recordId) => set({ recordId, startedAt: Date.now(), hintsUsedThisRun: 0 }),
  incrementHint: () => set((s) => ({ hintsUsedThisRun: s.hintsUsedThisRun + 1 })),
  elapsedSeconds: () => {
    const startedAt = get().startedAt
    return startedAt ? Math.floor((Date.now() - startedAt) / 1000) : 0
  },
  reset: () => set({ recordId: null, startedAt: null, hintsUsedThisRun: 0 }),
}))
```

- [ ] **Step 7: `GameLayout.tsx`**

```tsx
// src/components/game/GameLayout.tsx
import { ReactNode } from 'react'
import { useNavigate } from 'react-router-dom'
import { ArrowLeft } from 'lucide-react'
import type { Stage } from '@types/game'
import { ProgressBar } from '@components/common/ProgressBar'

const STAGE_LABELS: Record<Stage, string> = {
  1: 'SMS 수신',
  2: 'AI 채팅',
  3: '피싱 판단',
  4: '증거 수집',
  5: '신고',
  6: '결과',
}

interface GameLayoutProps {
  stage: Stage
  children: ReactNode
}

export function GameLayout({ stage, children }: GameLayoutProps) {
  const navigate = useNavigate()
  return (
    <div className="max-w-md mx-auto min-h-screen flex flex-col">
      <header className="flex items-center gap-3 p-4 border-b">
        <button onClick={() => navigate('/')} aria-label="뒤로가기">
          <ArrowLeft size={20} />
        </button>
        <div className="flex-1">
          <p className="font-semibold">Chapter 1 - {STAGE_LABELS[stage]}</p>
          <ProgressBar ratio={stage / 6} />
        </div>
      </header>
      <main className="flex-1 p-4">{children}</main>
    </div>
  )
}
```

- [ ] **Step 8: Commit**

```bash
git add frontend/src/stores frontend/src/components
git commit -m "feat(web): add game store, progress bar, and game layout shell"
```

---

### Task 16: Stage1_SMS Component

**Files:**
- Create: `frontend/src/components/game/Stage1_SMS.tsx`

**Interfaces:**
- Consumes: `initialMessage: string` (from `ScenarioStartResponse`, threaded through by Task 22's `GamePage`).
- Produces: `<Stage1_SMS message={...} onContinue={...} />` — `onContinue` is called by the parent to advance the local stage view (the actual stage transition to 2 happens server-side on the first `send`, per Task 13's handler design where stage 2 begins once the user starts chatting; Task 22 wires this).

- [ ] **Step 1: Implement**

```tsx
// src/components/game/Stage1_SMS.tsx
interface Stage1SMSProps {
  message: string
  onContinue: () => void
}

export function Stage1_SMS({ message, onContinue }: Stage1SMSProps) {
  return (
    <div className="flex flex-col gap-6 items-center pt-8">
      <p className="text-sm text-gray-500">문자 메시지가 도착했습니다</p>
      <div className="bg-white border rounded-2xl rounded-tl-none p-4 max-w-xs shadow-sm">
        <p className="whitespace-pre-wrap text-sm">{message}</p>
      </div>
      <button onClick={onContinue} className="bg-primary text-white rounded px-6 py-2">
        확인
      </button>
    </div>
  )
}
```

- [ ] **Step 2: Manual verification (deferred)**

This component has no logic to unit test in isolation (pure presentational); it's exercised by the Task 23 capstone integration test once wired into `GamePage`. No standalone test file needed per the Task Right-Sizing guidance (a reviewer can't meaningfully reject a static SMS bubble independent of the flow that uses it).

- [ ] **Step 3: Commit**

```bash
git add frontend/src/components/game/Stage1_SMS.tsx
git commit -m "feat(web): add Stage1 SMS reveal component"
```

---

### Task 17: Stage2_Chat Component

**Files:**
- Create: `frontend/src/components/game/Stage2_Chat.tsx`, `frontend/src/components/game/Stage2_Chat.test.tsx`

**Interfaces:**
- Consumes: `useChat(recordId, 2)` (Task 14).
- Produces: `<Stage2_Chat recordId={...} onStageComplete={...} />` — `onStageComplete` fires when `useChat`'s `stageComplete` flips true (after 2 exchanges, per Task 13's handler), consumed by Task 22.

- [ ] **Step 1: Write failing test**

```tsx
// src/components/game/Stage2_Chat.test.tsx
import { describe, it, expect, vi } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Stage2_Chat } from './Stage2_Chat'
import { mockDb } from '@mocks/db'
import { setAuthToken } from '@services/api'
import { tokenForUser } from '@mocks/db'

describe('Stage2_Chat', () => {
  it('sends a message, shows the criminal reply, and calls onStageComplete after 2 turns', async () => {
    const user = mockDb.createUser('stage2@test.com', 'pw', '헌터')
    setAuthToken(tokenForUser(user.userId))
    const record = mockDb.createRecord(user.userId, 101)

    const onStageComplete = vi.fn()
    render(<Stage2_Chat recordId={record.recordId} onStageComplete={onStageComplete} />)

    const input = await screen.findByLabelText('메시지 입력')

    await userEvent.type(input, '누구세요?')
    await userEvent.click(screen.getByRole('button', { name: '전송' }))
    await waitFor(() => expect(screen.getByText(/본인 확인/)).toBeInTheDocument())

    await userEvent.type(input, '계좌번호는 안 줄게요')
    await userEvent.click(screen.getByRole('button', { name: '전송' }))
    await waitFor(() => expect(onStageComplete).toHaveBeenCalled())
  })
})
```

- [ ] **Step 2: Run to verify it fails**

```bash
npx vitest run src/components/game/Stage2_Chat.test.tsx
```

Expected: FAIL — component does not exist.

- [ ] **Step 3: Implement**

```tsx
// src/components/game/Stage2_Chat.tsx
import { useState, useEffect, FormEvent } from 'react'
import { useChat } from '@hooks/useChat'

interface Stage2ChatProps {
  recordId: number
  onStageComplete: () => void
}

export function Stage2_Chat({ recordId, onStageComplete }: Stage2ChatProps) {
  const { messages, send, requestHint, isSending, stageComplete } = useChat(recordId, 2)
  const [text, setText] = useState('')
  const [hint, setHint] = useState<string | null>(null)

  useEffect(() => {
    if (stageComplete) onStageComplete()
  }, [stageComplete, onStageComplete])

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault()
    if (!text.trim()) return
    setText('')
    await send(text)
  }

  const handleHint = async () => {
    const result = await requestHint()
    setHint(result.hintText)
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-col gap-2">
        {messages.map((m, i) => (
          <div
            key={i}
            className={`p-3 rounded-2xl max-w-[80%] text-sm ${
              m.sender === 'user' ? 'bg-primary text-white self-end rounded-br-none' : 'bg-white border self-start rounded-bl-none'
            }`}
          >
            {m.message}
          </div>
        ))}
      </div>

      {hint && <p className="text-xs text-warning bg-warning/10 rounded p-2">💡 {hint}</p>}

      <form onSubmit={handleSubmit} className="flex gap-2">
        <input
          aria-label="메시지 입력"
          value={text}
          onChange={(e) => setText(e.target.value)}
          className="flex-1 border rounded px-3 py-2 text-sm"
          disabled={isSending}
        />
        <button type="submit" disabled={isSending} className="bg-primary text-white rounded px-4 py-2 text-sm disabled:opacity-50">
          전송
        </button>
      </form>
      <button onClick={handleHint} className="text-xs text-gray-500 self-start">
        💡 힌트 요청
      </button>
    </div>
  )
}
```

- [ ] **Step 4: Run to verify it passes**

```bash
npx vitest run src/components/game/Stage2_Chat.test.tsx
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add frontend/src/components/game
git commit -m "feat(web): add Stage2 AI chat component"
```

---

### Task 18: Judgment Mock Handler & Stage3_Judgment Component

**Files:**
- Create: `frontend/src/mocks/handlers/judgment.ts`, `frontend/src/mocks/handlers/judgment.test.ts`, `frontend/src/services/judgmentService.ts`, `frontend/src/components/game/Stage3_Judgment.tsx`
- Modify: `frontend/src/mocks/handlers.ts`

**Interfaces:**
- Consumes: `mockDb`, `userIdFromToken` (Task 5). Scenario 1-1's correct answer is `is_phishing: true` (it's a bank-impersonation smishing scenario — this is a scenario property, not user input, hardcoded in the handler since MVP has exactly one scenario).
- Produces: `POST /api/v1/scenarios/:recordId/judgment` handler, `judgmentService.submit`, `<Stage3_Judgment recordId={...} onCorrect={...} />` — consumed by Task 22.

- [ ] **Step 1: Write failing handler test**

```typescript
// src/mocks/handlers/judgment.test.ts
import { describe, it, expect } from 'vitest'

const BASE = 'http://localhost:8080/api/v1'

async function setup() {
  const signup = await fetch(`${BASE}/auth/signup`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: `j${Math.random()}@test.com`, password: 'pw123456', nickname: '헌터' }),
  })
  const { token } = await signup.json()
  const start = await fetch(`${BASE}/scenarios/101/start`, { method: 'POST', headers: { Authorization: `Bearer ${token}` } })
  const { record_id } = await start.json()
  return { token, recordId: record_id as number }
}

describe('judgment mock handler', () => {
  it('accepts the correct judgment (is_phishing: true) and advances to stage 4', async () => {
    const { token, recordId } = await setup()
    const res = await fetch(`${BASE}/scenarios/${recordId}/judgment`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ is_phishing: true }),
    })
    const body = await res.json()
    expect(body.is_correct).toBe(true)
    expect(body.next_stage).toBe(4)
  })

  it('rejects a wrong judgment and tracks the wrong attempt count', async () => {
    const { token, recordId } = await setup()
    const res = await fetch(`${BASE}/scenarios/${recordId}/judgment`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ is_phishing: false }),
    })
    const body = await res.json()
    expect(body.is_correct).toBe(false)
    expect(body.wrong_attempts).toBe(1)
    expect(body.next_stage).toBe(3)
  })
})
```

- [ ] **Step 2: Run to verify it fails**

```bash
npx vitest run src/mocks/handlers/judgment.test.ts
```

Expected: FAIL.

- [ ] **Step 3: Implement the handler**

```typescript
// src/mocks/handlers/judgment.ts
import { http, HttpResponse } from 'msw'
import { mockDb, userIdFromToken } from '../db'

const BASE = '*/api/v1'
const CORRECT_ANSWER = true // Scenario 1-1 is phishing; single-scenario MVP hardcodes this

export const judgmentHandlers = [
  http.post(`${BASE}/scenarios/:recordId/judgment`, async ({ request, params }) => {
    if (!userIdFromToken(request.headers.get('Authorization'))) {
      return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })
    }
    const record = mockDb.records.get(Number(params.recordId))
    if (!record) return HttpResponse.json({ message: 'not found' }, { status: 404 })

    const { is_phishing } = (await request.json()) as { is_phishing: boolean }
    const isCorrect = is_phishing === CORRECT_ANSWER

    if (isCorrect) {
      record.judgmentCorrect = true
      record.judgmentTurn = record.currentTurn
      record.stage = 4
      return HttpResponse.json({ is_correct: true, feedback: '정확한 판단입니다!', next_stage: 4, wrong_attempts: record.judgmentWrongAttempts })
    }

    record.judgmentWrongAttempts += 1
    if (record.judgmentWrongAttempts >= 2) {
      record.judgmentCorrect = false
      record.judgmentTurn = record.currentTurn
      record.stage = 4
      return HttpResponse.json({
        is_correct: false,
        feedback: '정답은 "피싱입니다"였습니다. 은행은 문자로 링크 클릭을 요구하지 않습니다.',
        next_stage: 4,
        wrong_attempts: record.judgmentWrongAttempts,
      })
    }

    return HttpResponse.json({
      is_correct: false,
      feedback: '다시 생각해보세요. 이 문자에 이상한 점은 없었나요?',
      next_stage: 3,
      wrong_attempts: record.judgmentWrongAttempts,
    })
  }),
]
```

- [ ] **Step 4: Register handlers**

```typescript
// src/mocks/handlers.ts
import type { HttpHandler } from 'msw'
import { authHandlers } from './handlers/auth'
import { gameHandlers } from './handlers/game'
import { chatHandlers } from './handlers/chat'
import { judgmentHandlers } from './handlers/judgment'

export const handlers: HttpHandler[] = [...authHandlers, ...gameHandlers, ...chatHandlers, ...judgmentHandlers]
```

- [ ] **Step 5: Run to verify it passes**

```bash
npx vitest run src/mocks/handlers/judgment.test.ts
```

Expected: PASS.

- [ ] **Step 6: `judgmentService.ts`**

```typescript
// src/services/judgmentService.ts
import { apiClient } from './api'
import type { JudgmentResponse, Stage } from '@types/game'

interface JudgmentWire {
  is_correct: boolean
  feedback: string
  next_stage: Stage
  wrong_attempts: number
}

export const judgmentService = {
  async submit(recordId: number, isPhishing: boolean): Promise<JudgmentResponse> {
    const { data } = await apiClient.post<JudgmentWire>(`/api/v1/scenarios/${recordId}/judgment`, { is_phishing: isPhishing })
    return { isCorrect: data.is_correct, feedback: data.feedback, nextStage: data.next_stage, wrongAttempts: data.wrong_attempts }
  },
}
```

- [ ] **Step 7: `Stage3_Judgment.tsx`**

```tsx
// src/components/game/Stage3_Judgment.tsx
import { useState } from 'react'
import { judgmentService } from '@services/judgmentService'

interface Stage3JudgmentProps {
  recordId: number
  onResolved: (correct: boolean) => void
}

export function Stage3_Judgment({ recordId, onResolved }: Stage3JudgmentProps) {
  const [feedback, setFeedback] = useState<string | null>(null)
  const [isSubmitting, setIsSubmitting] = useState(false)

  const handleAnswer = async (isPhishing: boolean) => {
    setIsSubmitting(true)
    try {
      const result = await judgmentService.submit(recordId, isPhishing)
      setFeedback(result.feedback)
      if (result.nextStage === 4) {
        onResolved(result.isCorrect)
      }
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <div className="flex flex-col gap-4">
      <p className="font-semibold">🎯 이 메시지의 의도를 판단하세요.</p>
      {feedback && <p className="text-sm bg-gray-100 rounded p-3">{feedback}</p>}
      <button
        onClick={() => handleAnswer(true)}
        disabled={isSubmitting}
        className="border-2 border-danger text-danger rounded px-4 py-3 disabled:opacity-50"
      >
        이것은 피싱입니다
      </button>
      <button
        onClick={() => handleAnswer(false)}
        disabled={isSubmitting}
        className="border-2 border-gray-300 rounded px-4 py-3 disabled:opacity-50"
      >
        정상적인 메시지입니다
      </button>
    </div>
  )
}
```

- [ ] **Step 8: Commit**

```bash
git add frontend/src/mocks frontend/src/services frontend/src/components
git commit -m "feat(web): add judgment mock handler, service, and Stage3 component"
```

---

### Task 19: Evidence Mock Handlers & Stage4_Evidence Component

**Files:**
- Create: `frontend/src/mocks/handlers/evidence.ts`, `frontend/src/mocks/handlers/evidence.test.ts`, `frontend/src/services/evidenceService.ts`, `frontend/src/components/game/Stage4_Evidence.tsx`
- Modify: `frontend/src/mocks/handlers.ts`

**Interfaces:**
- Consumes: `ALL_POSSIBLE_EVIDENCE` (Task 4), `mockDb` (Task 5).
- Produces: `GET /api/v1/scenarios/:recordId/evidence` and `POST /api/v1/scenarios/:recordId/evidence/confirm` handlers, `evidenceService.list/confirm`, `<Stage4_Evidence recordId={...} onConfirmed={...} />` — consumed by Task 22.

- [ ] **Step 1: Write failing handler tests**

```typescript
// src/mocks/handlers/evidence.test.ts
import { describe, it, expect } from 'vitest'

const BASE = 'http://localhost:8080/api/v1'

async function setup() {
  const signup = await fetch(`${BASE}/auth/signup`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: `e${Math.random()}@test.com`, password: 'pw123456', nickname: '헌터' }),
  })
  const { token } = await signup.json()
  const start = await fetch(`${BASE}/scenarios/101/start`, { method: 'POST', headers: { Authorization: `Bearer ${token}` } })
  const { record_id } = await start.json()
  return { token, recordId: record_id as number }
}

describe('evidence mock handlers', () => {
  it('lists all possible evidence with 3 pre-checked as auto-extracted', async () => {
    const { token, recordId } = await setup()
    const res = await fetch(`${BASE}/scenarios/${recordId}/evidence`, { headers: { Authorization: `Bearer ${token}` } })
    const body = await res.json()
    expect(body.length).toBe(6)
    expect(body.filter((e: { is_auto_extracted: boolean }) => e.is_auto_extracted).length).toBe(3)
  })

  it('confirms a full selection at 100% with no missed evidence', async () => {
    const { token, recordId } = await setup()
    const res = await fetch(`${BASE}/scenarios/${recordId}/evidence/confirm`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ selected_evidence_ids: [1, 2, 3, 4, 5, 6] }),
    })
    const body = await res.json()
    expect(body.evidence_collection_percentage).toBe(100)
    expect(body.missed_evidence).toHaveLength(0)
  })

  it('reports missed evidence for a partial selection', async () => {
    const { token, recordId } = await setup()
    const res = await fetch(`${BASE}/scenarios/${recordId}/evidence/confirm`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ selected_evidence_ids: [1, 2, 3] }),
    })
    const body = await res.json()
    expect(body.evidence_collection_percentage).toBe(50)
    expect(body.missed_evidence.map((m: { type: string }) => m.type)).toContain('account_number')
  })
})
```

- [ ] **Step 2: Run to verify it fails**

```bash
npx vitest run src/mocks/handlers/evidence.test.ts
```

Expected: FAIL.

- [ ] **Step 3: Implement handlers**

```typescript
// src/mocks/handlers/evidence.ts
import { http, HttpResponse } from 'msw'
import { mockDb, userIdFromToken } from '../db'
import { ALL_POSSIBLE_EVIDENCE } from '../scenarioData'

const BASE = '*/api/v1'

export const evidenceHandlers = [
  http.get(`${BASE}/scenarios/:recordId/evidence`, ({ request, params }) => {
    if (!userIdFromToken(request.headers.get('Authorization'))) {
      return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })
    }
    const record = mockDb.records.get(Number(params.recordId))
    if (!record) return HttpResponse.json({ message: 'not found' }, { status: 404 })

    return HttpResponse.json(
      ALL_POSSIBLE_EVIDENCE.map((e) => ({
        evidence_id: e.evidenceId,
        type: e.type,
        value: e.value,
        importance_level: e.importanceLevel,
        is_auto_extracted: e.isAutoExtracted,
        is_user_selected: record.selectedEvidenceIds.includes(e.evidenceId),
      })),
    )
  }),

  http.post(`${BASE}/scenarios/:recordId/evidence/confirm`, async ({ request, params }) => {
    if (!userIdFromToken(request.headers.get('Authorization'))) {
      return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })
    }
    const record = mockDb.records.get(Number(params.recordId))
    if (!record) return HttpResponse.json({ message: 'not found' }, { status: 404 })

    const { selected_evidence_ids } = (await request.json()) as { selected_evidence_ids: number[] }
    record.selectedEvidenceIds = selected_evidence_ids
    record.stage = 5

    const percentage = Math.round((selected_evidence_ids.length / ALL_POSSIBLE_EVIDENCE.length) * 100)
    const missed = ALL_POSSIBLE_EVIDENCE.filter((e) => !selected_evidence_ids.includes(e.evidenceId)).map((e) => ({
      type: e.type,
      importance: e.importanceLevel,
    }))

    return HttpResponse.json({
      evidence_collection_percentage: percentage,
      missed_evidence: missed,
      tips: missed.length > 0 ? '계좌번호·주민등록번호 요구는 매우 중요한 증거입니다.' : '완벽하게 수집했습니다!',
    })
  }),
]
```

- [ ] **Step 4: Register handlers**

```typescript
// src/mocks/handlers.ts
import type { HttpHandler } from 'msw'
import { authHandlers } from './handlers/auth'
import { gameHandlers } from './handlers/game'
import { chatHandlers } from './handlers/chat'
import { judgmentHandlers } from './handlers/judgment'
import { evidenceHandlers } from './handlers/evidence'

export const handlers: HttpHandler[] = [
  ...authHandlers,
  ...gameHandlers,
  ...chatHandlers,
  ...judgmentHandlers,
  ...evidenceHandlers,
]
```

- [ ] **Step 5: Run to verify it passes**

```bash
npx vitest run src/mocks/handlers/evidence.test.ts
```

Expected: PASS.

- [ ] **Step 6: `evidenceService.ts`**

```typescript
// src/services/evidenceService.ts
import { apiClient } from './api'
import type { Evidence, EvidenceConfirmResponse } from '@types/game'

interface EvidenceWire {
  evidence_id: number
  type: string
  value: string
  importance_level: number
  is_auto_extracted: boolean
  is_user_selected: boolean
}

interface ConfirmWire {
  evidence_collection_percentage: number
  missed_evidence: { type: string; importance: number }[]
  tips: string
}

export const evidenceService = {
  async list(recordId: number): Promise<Evidence[]> {
    const { data } = await apiClient.get<EvidenceWire[]>(`/api/v1/scenarios/${recordId}/evidence`)
    return data.map((e) => ({
      evidenceId: e.evidence_id,
      type: e.type,
      value: e.value,
      importanceLevel: e.importance_level,
      isAutoExtracted: e.is_auto_extracted,
      isUserSelected: e.is_user_selected,
    }))
  },

  async confirm(recordId: number, selectedIds: number[]): Promise<EvidenceConfirmResponse> {
    const { data } = await apiClient.post<ConfirmWire>(`/api/v1/scenarios/${recordId}/evidence/confirm`, {
      selected_evidence_ids: selectedIds,
    })
    return { evidenceCollectionPercentage: data.evidence_collection_percentage, missedEvidence: data.missed_evidence, tips: data.tips }
  },
}
```

- [ ] **Step 7: `Stage4_Evidence.tsx`**

```tsx
// src/components/game/Stage4_Evidence.tsx
import { useState, useEffect } from 'react'
import { evidenceService } from '@services/evidenceService'
import { ProgressBar } from '@components/common/ProgressBar'
import type { Evidence } from '@types/game'

interface Stage4EvidenceProps {
  recordId: number
  onConfirmed: (percentage: number) => void
}

export function Stage4_Evidence({ recordId, onConfirmed }: Stage4EvidenceProps) {
  const [evidence, setEvidence] = useState<Evidence[]>([])
  const [selected, setSelected] = useState<Set<number>>(new Set())

  useEffect(() => {
    evidenceService.list(recordId).then((list) => {
      setEvidence(list)
      setSelected(new Set(list.filter((e) => e.isAutoExtracted).map((e) => e.evidenceId)))
    })
  }, [recordId])

  const toggle = (id: number) => {
    setSelected((prev) => {
      const next = new Set(prev)
      next.has(id) ? next.delete(id) : next.add(id)
      return next
    })
  }

  const handleConfirm = async () => {
    const result = await evidenceService.confirm(recordId, Array.from(selected))
    onConfirmed(result.evidenceCollectionPercentage)
  }

  const ratio = evidence.length > 0 ? selected.size / evidence.length : 0

  return (
    <div className="flex flex-col gap-4">
      <p className="font-semibold">🔍 증거를 수집하세요!</p>
      <ProgressBar ratio={ratio} label={`${Math.round(ratio * 100)}%`} />
      <div className="flex flex-col gap-2">
        {evidence.map((e) => (
          <label key={e.evidenceId} className="flex items-center gap-2 border rounded p-2 text-sm">
            <input type="checkbox" checked={selected.has(e.evidenceId)} onChange={() => toggle(e.evidenceId)} />
            {e.value}
          </label>
        ))}
      </div>
      <button onClick={handleConfirm} className="bg-primary text-white rounded px-4 py-2">
        다음: Stage 5 신고
      </button>
    </div>
  )
}
```

- [ ] **Step 8: Commit**

```bash
git add frontend/src/mocks frontend/src/services frontend/src/components
git commit -m "feat(web): add evidence mock handlers, service, and Stage4 component"
```

---

### Task 20: Stage5_Report Component

**Files:**
- Create: `frontend/src/components/game/Stage5_Report.tsx`

**Interfaces:**
- Consumes: `useChat(recordId, 5)` (Task 14 — the chat handler already branches on `stage === 5` to serve police replies from Task 13).
- Produces: `<Stage5_Report recordId={...} onComplete={...} />` — consumed by Task 22.

- [ ] **Step 1: Implement (structurally mirrors the already-tested Stage2_Chat, with police copy)**

```tsx
// src/components/game/Stage5_Report.tsx
import { useState, useEffect, FormEvent } from 'react'
import { useChat } from '@hooks/useChat'

interface Stage5ReportProps {
  recordId: number
  onComplete: () => void
}

export function Stage5_Report({ recordId, onComplete }: Stage5ReportProps) {
  const { messages, send, isSending, stageComplete } = useChat(recordId, 5)
  const [text, setText] = useState('')

  useEffect(() => {
    if (stageComplete) onComplete()
  }, [stageComplete, onComplete])

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault()
    if (!text.trim()) return
    setText('')
    await send(text)
  }

  return (
    <div className="flex flex-col gap-4">
      <p className="font-semibold">📞 경찰 신고</p>
      <div className="flex flex-col gap-2">
        {messages
          .filter((m) => m.sender !== 'ai_criminal')
          .map((m, i) => (
            <div
              key={i}
              className={`p-3 rounded-2xl max-w-[80%] text-sm ${
                m.sender === 'user' ? 'bg-primary text-white self-end rounded-br-none' : 'bg-white border self-start rounded-bl-none'
              }`}
            >
              {m.message}
            </div>
          ))}
      </div>
      <form onSubmit={handleSubmit} className="flex gap-2">
        <input
          aria-label="신고 내용 입력"
          value={text}
          onChange={(e) => setText(e.target.value)}
          className="flex-1 border rounded px-3 py-2 text-sm"
          disabled={isSending}
        />
        <button type="submit" disabled={isSending} className="bg-primary text-white rounded px-4 py-2 text-sm disabled:opacity-50">
          전송
        </button>
      </form>
    </div>
  )
}
```

Note: `useChat`'s initial `getHistory` call will include the Stage 1 SMS and any Stage 2 criminal exchanges already in `record.chatHistory` — the `.filter((m) => m.sender !== 'ai_criminal')` keeps the police-report view free of leftover criminal messages while still showing the user's own prior `user`-sender turns mixed in. This is an acceptable MVP simplification (a real backend would likely scope history per-stage); flagged here rather than silently shipped.

- [ ] **Step 2: Commit**

```bash
git add frontend/src/components/game/Stage5_Report.tsx
git commit -m "feat(web): add Stage5 police report chat component"
```

---

### Task 21: Report Mock Handlers & Stage6_Result Component

**Files:**
- Create: `frontend/src/mocks/handlers/report.ts`, `frontend/src/mocks/handlers/report.test.ts`, `frontend/src/services/reportService.ts`, `frontend/src/components/game/Stage6_Result.tsx`
- Modify: `frontend/src/mocks/handlers.ts`, `frontend/src/mocks/db.ts` (mark `record.stage = 6` on evidence confirm was set to 5 — the report GET should also work once stage 5's 2 police turns complete; add a `record.stage = 6` transition at the end of the chat handler for stage 5 in Task 13, revisited here)

**Interfaces:**
- Consumes: `computeScenarioScore`, `computeXpBreakdown` (Task 3), `mockDb` (Task 5).
- Produces: `GET /api/v1/scenarios/:recordId/report` and `POST /api/v1/scenarios/:recordId/report/claim` handlers, `reportService.get/claim`, `<Stage6_Result recordId={...} onClaimed={...} />` — consumed by Task 22, which also calls `useAuthStore.addXp` on claim.

- [ ] **Step 1: Fix Task 13's chat handler to advance to stage 6 after 2 police turns**

In `src/mocks/handlers/chat.ts`, inside the `send` handler, after `if (isPolice) record.policeTurnsCompleted = turn`, add:
```typescript
if (isPolice && turn >= 2) record.stage = 6
```

- [ ] **Step 2: Write failing handler tests**

```typescript
// src/mocks/handlers/report.test.ts
import { describe, it, expect } from 'vitest'

const BASE = 'http://localhost:8080/api/v1'

async function playThroughToStage6(token: string, recordId: number) {
  await fetch(`${BASE}/chat/${recordId}/send`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ message: '누구세요?', stage: 2 }),
  })
  await fetch(`${BASE}/chat/${recordId}/send`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ message: '안 줄게요', stage: 2 }),
  })
  await fetch(`${BASE}/scenarios/${recordId}/judgment`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ is_phishing: true }),
  })
  await fetch(`${BASE}/scenarios/${recordId}/evidence/confirm`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ selected_evidence_ids: [1, 2, 3, 4, 5, 6] }),
  })
  await fetch(`${BASE}/chat/${recordId}/send`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ message: '신고합니다', stage: 5 }),
  })
  await fetch(`${BASE}/chat/${recordId}/send`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ message: '네 알겠습니다', stage: 5 }),
  })
}

async function setup() {
  const signup = await fetch(`${BASE}/auth/signup`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: `r${Math.random()}@test.com`, password: 'pw123456', nickname: '헌터' }),
  })
  const { token } = await signup.json()
  const start = await fetch(`${BASE}/scenarios/101/start`, { method: 'POST', headers: { Authorization: `Bearer ${token}` } })
  const { record_id } = await start.json()
  return { token, recordId: record_id as number }
}

describe('report mock handlers', () => {
  it('generates a full star-rated report after a perfect playthrough', async () => {
    const { token, recordId } = await setup()
    await playThroughToStage6(token, recordId)

    const res = await fetch(`${BASE}/scenarios/${recordId}/report`, { headers: { Authorization: `Bearer ${token}` } })
    const body = await res.json()
    expect(body.evidence_analysis.collection_percentage).toBe(100)
    expect(body.star_rating).toBeGreaterThanOrEqual(2)
    expect(body.xp_breakdown.total).toBeGreaterThan(150)
  })

  it('claims XP once and rejects a second claim', async () => {
    const { token, recordId } = await setup()
    await playThroughToStage6(token, recordId)

    const first = await fetch(`${BASE}/scenarios/${recordId}/report/claim`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}` },
    })
    expect(first.status).toBe(200)
    const firstBody = await first.json()
    expect(firstBody.xp_added).toBeGreaterThan(0)

    const second = await fetch(`${BASE}/scenarios/${recordId}/report/claim`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}` },
    })
    expect(second.status).toBe(409)
  })
})
```

- [ ] **Step 3: Run to verify it fails**

```bash
npx vitest run src/mocks/handlers/report.test.ts
```

Expected: FAIL.

- [ ] **Step 4: Implement handlers**

```typescript
// src/mocks/handlers/report.ts
import { http, HttpResponse } from 'msw'
import { mockDb, userIdFromToken } from '../db'
import { ALL_POSSIBLE_EVIDENCE } from '../scenarioData'
import { computeScenarioScore, computeXpBreakdown } from '@utils/scoring'
import { getLevelInfo } from '@utils/levels'

const BASE = '*/api/v1'

function buildReport(recordId: number) {
  const record = mockDb.records.get(recordId)
  if (!record) return null

  const durationSeconds = Math.floor((Date.now() - record.startedAt) / 1000)
  const evidencePct = Math.round((record.selectedEvidenceIds.length / ALL_POSSIBLE_EVIDENCE.length) * 100)

  const score = computeScenarioScore({
    judgmentTurn: record.judgmentTurn ?? record.currentTurn,
    wrongAttempts: record.judgmentWrongAttempts,
    evidenceCollectionPercentage: evidencePct,
    hintsUsed: record.hintsUsed,
    policeTurnsCompleted: record.policeTurnsCompleted,
    durationSeconds,
  })

  const xp = computeXpBreakdown({
    starRating: score.starRating,
    hintsUsed: record.hintsUsed,
    evidenceCollectionPercentage: evidencePct,
    reportScore: score.report,
    wrongAttempts: record.judgmentWrongAttempts,
    durationSeconds,
  })

  const missed = ALL_POSSIBLE_EVIDENCE.filter((e) => !record.selectedEvidenceIds.includes(e.evidenceId)).map((e) => ({
    type: e.type,
    importance: e.importanceLevel,
  }))

  return { record, score, xp, evidencePct, missed }
}

export const reportHandlers = [
  http.get(`${BASE}/scenarios/:recordId/report`, ({ request, params }) => {
    if (!userIdFromToken(request.headers.get('Authorization'))) {
      return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })
    }
    const built = buildReport(Number(params.recordId))
    if (!built) return HttpResponse.json({ message: 'not found' }, { status: 404 })
    const { record, score, xp, evidencePct, missed } = built

    return HttpResponse.json({
      scenario_id: record.scenarioId,
      accuracy_evaluation: {
        is_correct: record.judgmentCorrect,
        feedback: record.judgmentCorrect ? '정확한 판단입니다' : '아쉽게도 오답이었습니다',
        judgment_turn: record.judgmentTurn,
      },
      evidence_analysis: {
        collection_percentage: evidencePct,
        collected_count: record.selectedEvidenceIds.length,
        total_possible: ALL_POSSIBLE_EVIDENCE.length,
        missed,
      },
      report_handling: { police_response: record.policeTurnsCompleted >= 2 ? '완벽함' : '기본' },
      scores: {
        accuracy: score.accuracy,
        evidence: score.evidence,
        report: score.report,
        hints: score.hints,
        time: score.time,
        total: score.total,
      },
      star_rating: score.starRating,
      educational_feedback:
        missed.length > 0
          ? `${missed[0].type === 'account_number' ? '계좌번호' : missed[0].type} 등 놓친 증거가 있습니다. 다음엔 더 깊게 파고들어 보세요!`
          : '완벽한 대응이었습니다!',
      xp_breakdown: {
        base: xp.base,
        star_bonus: xp.starBonus,
        hints_bonus: xp.hintsBonus,
        evidence_bonus: xp.evidenceBonus,
        report_bonus: xp.reportBonus,
        accuracy_penalty: xp.accuracyPenalty,
        time_bonus: xp.timeBonus,
        total: xp.total,
      },
    })
  }),

  http.post(`${BASE}/scenarios/:recordId/report/claim`, ({ request, params }) => {
    const userId = userIdFromToken(request.headers.get('Authorization'))
    if (!userId) return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })

    const record = mockDb.records.get(Number(params.recordId))
    if (!record) return HttpResponse.json({ message: 'not found' }, { status: 404 })
    if (record.claimed) return HttpResponse.json({ message: '이미 보상을 수령했습니다.' }, { status: 409 })

    const built = buildReport(record.recordId)!
    const user = mockDb.users.get(userId)!
    const previousLevel = getLevelInfo(user.totalXp).level

    user.totalXp += built.xp.total
    user.currentXp = user.totalXp
    const newLevelInfo = getLevelInfo(user.totalXp)
    user.level = newLevelInfo.level

    record.claimed = true

    return HttpResponse.json({
      xp_added: built.xp.total,
      new_total_xp: user.totalXp,
      level_up: newLevelInfo.level > previousLevel,
      new_level: newLevelInfo.level,
    })
  }),
]
```

- [ ] **Step 5: Register handlers**

```typescript
// src/mocks/handlers.ts
import type { HttpHandler } from 'msw'
import { authHandlers } from './handlers/auth'
import { gameHandlers } from './handlers/game'
import { chatHandlers } from './handlers/chat'
import { judgmentHandlers } from './handlers/judgment'
import { evidenceHandlers } from './handlers/evidence'
import { reportHandlers } from './handlers/report'

export const handlers: HttpHandler[] = [
  ...authHandlers,
  ...gameHandlers,
  ...chatHandlers,
  ...judgmentHandlers,
  ...evidenceHandlers,
  ...reportHandlers,
]
```

- [ ] **Step 6: Run to verify it passes**

```bash
npx vitest run src/mocks/handlers/report.test.ts
```

Expected: PASS.

- [ ] **Step 7: `reportService.ts`**

```typescript
// src/services/reportService.ts
import { apiClient } from './api'
import type { ScenarioReport, ReportClaimResponse } from '@types/game'

export const reportService = {
  async get(recordId: number): Promise<ScenarioReport> {
    const { data } = await apiClient.get(`/api/v1/scenarios/${recordId}/report`)
    return {
      scenarioId: data.scenario_id,
      accuracyEvaluation: {
        isCorrect: data.accuracy_evaluation.is_correct,
        feedback: data.accuracy_evaluation.feedback,
        judgmentTurn: data.accuracy_evaluation.judgment_turn,
      },
      evidenceAnalysis: {
        collectionPercentage: data.evidence_analysis.collection_percentage,
        collectedCount: data.evidence_analysis.collected_count,
        totalPossible: data.evidence_analysis.total_possible,
        missed: data.evidence_analysis.missed,
      },
      reportHandling: { policeResponse: data.report_handling.police_response },
      scores: data.scores,
      starRating: data.star_rating,
      educationalFeedback: data.educational_feedback,
      xpBreakdown: {
        base: data.xp_breakdown.base,
        starBonus: data.xp_breakdown.star_bonus,
        hintsBonus: data.xp_breakdown.hints_bonus,
        evidenceBonus: data.xp_breakdown.evidence_bonus,
        reportBonus: data.xp_breakdown.report_bonus,
        accuracyPenalty: data.xp_breakdown.accuracy_penalty,
        timeBonus: data.xp_breakdown.time_bonus,
        total: data.xp_breakdown.total,
      },
    }
  },

  async claim(recordId: number): Promise<ReportClaimResponse> {
    const { data } = await apiClient.post(`/api/v1/scenarios/${recordId}/report/claim`)
    return { xpAdded: data.xp_added, newTotalXp: data.new_total_xp, levelUp: data.level_up, newLevel: data.new_level }
  },
}
```

- [ ] **Step 8: `Stage6_Result.tsx`**

```tsx
// src/components/game/Stage6_Result.tsx
import { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import { reportService } from '@services/reportService'
import { useAuthStore } from '@stores/authStore'
import type { ScenarioReport } from '@types/game'

interface Stage6ResultProps {
  recordId: number
  onClaimed: () => void
}

export function Stage6_Result({ recordId, onClaimed }: Stage6ResultProps) {
  const [report, setReport] = useState<ScenarioReport | null>(null)
  const [claimed, setClaimed] = useState(false)
  const addXp = useAuthStore((s) => s.addXp)

  useEffect(() => {
    reportService.get(recordId).then(setReport)
  }, [recordId])

  if (!report) return <p>결과를 불러오는 중...</p>

  const handleClaim = async () => {
    const result = await reportService.claim(recordId)
    addXp(result.xpAdded)
    setClaimed(true)
    if (result.levelUp) {
      // level-up toast is handled by the parent (GamePage, Task 22) via onClaimed
    }
    onClaimed()
  }

  return (
    <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} className="flex flex-col gap-4">
      <p className="text-center text-xl font-bold">🎯 Mission Complete!</p>
      <p className="text-center text-2xl">{'⭐'.repeat(report.starRating).padEnd(3, '☆')}</p>

      <div className="border rounded p-4 text-sm flex flex-col gap-1">
        <p>✓ 대응 능력: {report.accuracyEvaluation.feedback}</p>
        <p>✓ 증거 수집: {report.evidenceAnalysis.collectionPercentage}%</p>
        <p>✓ 신고 대응: {report.reportHandling.policeResponse}</p>
        <p className="text-gray-500 mt-2">{report.educationalFeedback}</p>
      </div>

      <div className="border rounded p-4 text-sm">
        <p>Base XP: +{report.xpBreakdown.base}</p>
        <p>★ Bonus: +{report.xpBreakdown.starBonus}</p>
        <p>힌트 보너스: {report.xpBreakdown.hintsBonus >= 0 ? '+' : ''}{report.xpBreakdown.hintsBonus}</p>
        <p>증거 보너스: +{report.xpBreakdown.evidenceBonus}</p>
        <p>신고 보너스: {report.xpBreakdown.reportBonus >= 0 ? '+' : ''}{report.xpBreakdown.reportBonus}</p>
        <p>시간 보너스: {report.xpBreakdown.timeBonus >= 0 ? '+' : ''}{report.xpBreakdown.timeBonus}</p>
        <p className="font-bold mt-1">Total: +{report.xpBreakdown.total} XP</p>
      </div>

      <button
        onClick={handleClaim}
        disabled={claimed}
        className="bg-primary text-white rounded px-4 py-2 disabled:opacity-50"
      >
        {claimed ? '수령 완료' : '보상 받기'}
      </button>
    </motion.div>
  )
}
```

- [ ] **Step 9: Commit**

```bash
git add frontend/src/mocks frontend/src/services frontend/src/components
git commit -m "feat(web): add report mock handlers, service, and Stage6 result component"
```

---

### Task 22: GamePage Stage Router & Level-Up Flow

**Files:**
- Create: `frontend/src/pages/GamePage.tsx`
- Modify: `frontend/src/App.tsx` (add `/game/:recordId` route)

**Interfaces:**
- Consumes: `useScenarioStatus` (Task 11), `useGameStore` (Task 15), all six `Stage*` components (Tasks 16–21), `useAuthStore` (Task 8).
- Produces: the fully wired Chapter 1 playthrough at `/game/:recordId` — this is the integration point Task 23's capstone test drives end-to-end.

- [ ] **Step 1: Implement `GamePage.tsx`**

```tsx
// src/pages/GamePage.tsx
import { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import toast from 'react-hot-toast'
import { GameLayout } from '@components/game/GameLayout'
import { Stage1_SMS } from '@components/game/Stage1_SMS'
import { Stage2_Chat } from '@components/game/Stage2_Chat'
import { Stage3_Judgment } from '@components/game/Stage3_Judgment'
import { Stage4_Evidence } from '@components/game/Stage4_Evidence'
import { Stage5_Report } from '@components/game/Stage5_Report'
import { Stage6_Result } from '@components/game/Stage6_Result'
import { useScenarioStatus } from '@hooks/useScenario'
import { useGameStore } from '@stores/gameStore'
import type { Stage } from '@types/game'

export function GamePage() {
  const { recordId } = useParams<{ recordId: string }>()
  const recordIdNum = Number(recordId)
  const navigate = useNavigate()

  const { data: status, refetch } = useScenarioStatus(recordIdNum)
  const [localStage, setLocalStage] = useState<Stage>(1)
  const startGame = useGameStore((s) => s.start)

  useEffect(() => {
    startGame(recordIdNum)
  }, [recordIdNum, startGame])

  useEffect(() => {
    if (status) setLocalStage(status.stage)
  }, [status])

  if (!status) return <p className="p-4">불러오는 중...</p>

  const advance = async () => {
    await refetch()
  }

  return (
    <GameLayout stage={localStage}>
      {localStage === 1 && (
        <Stage1_SMS message="문자 내용을 확인했다면 계속 진행하세요." onContinue={() => setLocalStage(2)} />
      )}
      {localStage === 2 && <Stage2_Chat recordId={recordIdNum} onStageComplete={() => setLocalStage(3)} />}
      {localStage === 3 && (
        <Stage3_Judgment
          recordId={recordIdNum}
          onResolved={(correct) => {
            toast(correct ? '정확한 판단입니다!' : '정답을 놓쳤지만 계속 진행합니다.')
            advance()
          }}
        />
      )}
      {localStage === 4 && <Stage4_Evidence recordId={recordIdNum} onConfirmed={() => advance()} />}
      {localStage === 5 && <Stage5_Report recordId={recordIdNum} onComplete={() => advance()} />}
      {localStage === 6 && (
        <Stage6_Result
          recordId={recordIdNum}
          onClaimed={() => {
            toast.success('보상을 수령했습니다!')
            navigate('/')
          }}
        />
      )}
    </GameLayout>
  )
}
```

- [ ] **Step 2: Register the route**

In `src/App.tsx`, inside the `<Route element={<ProtectedRoute />}>` block, add:
```tsx
<Route path="/game/:recordId" element={<GamePage />} />
```
and import `import { GamePage } from '@pages/GamePage'` at the top.

- [ ] **Step 3: Fix `Stage1_SMS`'s message prop**

`GamePage` currently passes a placeholder string instead of the real initial SMS returned by `gameService.startScenario` (Task 11) — that message is only available at the moment of `POST /scenarios/:id/start`, which already happened in `Dashboard.tsx` (Task 12) before navigating here. Thread it through via the navigation state instead of refetching:

In `src/components/dashboard/Dashboard.tsx`'s `handlePlay`, change:
```typescript
const { recordId } = await gameService.startScenario(scenarioId)
navigate(`/game/${recordId}`)
```
to:
```typescript
const { recordId, initialMessage } = await gameService.startScenario(scenarioId)
navigate(`/game/${recordId}`, { state: { initialMessage } })
```

In `GamePage.tsx`, add `import { useLocation } from 'react-router-dom'` and:
```typescript
const location = useLocation()
const initialMessage = (location.state as { initialMessage?: string } | null)?.initialMessage ?? '문자를 확인하세요.'
```
then pass `message={initialMessage}` to `<Stage1_SMS>` instead of the placeholder string.

- [ ] **Step 4: Manual verification**

```bash
npm run dev
```

Sign up → Dashboard → 플레이 → walk through all 6 stages → confirm XP/level updates on the Dashboard after "보상 받기".

- [ ] **Step 5: Commit**

```bash
git add frontend/src
git commit -m "feat(web): wire GamePage stage router for the full Chapter 1 playthrough"
```

---

### Task 23: Capstone Integration Test — Full Chapter 1 Playthrough

**Files:**
- Create: `frontend/src/test/chapter1-playthrough.test.tsx`

**Interfaces:**
- Consumes: `App` (Task 9/12/22), the full MSW handler set (Tasks 6/10/13/18/19/21).
- Produces: a regression test that renders the whole app and plays Chapter 1 start-to-finish through the real UI, guarding every task in this plan against future breakage.

- [ ] **Step 1: Write the test**

```tsx
// src/test/chapter1-playthrough.test.tsx
import { describe, it, expect } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import App from '../App'

describe('Chapter 1 full playthrough', () => {
  it('takes a new user from signup through claiming XP', async () => {
    render(<App />)
    const user = userEvent.setup()

    // Land on login, go to signup
    await user.click(await screen.findByText('회원가입'))
    await user.type(screen.getByLabelText('닉네임'), '피싱헌터')
    await user.type(screen.getByLabelText('이메일'), 'playthrough@test.com')
    await user.type(screen.getByLabelText('비밀번호'), 'pw123456')
    await user.click(screen.getByRole('button', { name: '회원가입' }))

    // Dashboard: start Chapter 1
    await user.click(await screen.findByRole('button', { name: '플레이' }))

    // Stage 1: SMS
    await user.click(await screen.findByRole('button', { name: '확인' }))

    // Stage 2: chat, 2 turns to trigger stageComplete
    const chatInput = await screen.findByLabelText('메시지 입력')
    await user.type(chatInput, '누구세요?')
    await user.click(screen.getByRole('button', { name: '전송' }))
    await waitFor(() => expect(screen.getByText(/본인 확인/)).toBeInTheDocument())
    await user.type(chatInput, '계좌번호는 안 줄게요')
    await user.click(screen.getByRole('button', { name: '전송' }))

    // Stage 3: judgment
    await user.click(await screen.findByRole('button', { name: '이것은 피싱입니다' }))

    // Stage 4: evidence — accept the pre-checked auto-extracted evidence
    await user.click(await screen.findByRole('button', { name: '다음: Stage 5 신고' }))

    // Stage 5: police chat, 2 turns
    const reportInput = await screen.findByLabelText('신고 내용 입력')
    await user.type(reportInput, '피싱 문자를 받았습니다')
    await user.click(screen.getByRole('button', { name: '전송' }))
    await waitFor(() => expect(screen.getByText(/접수되었습니다/)).toBeInTheDocument())
    await user.type(reportInput, '네 알겠습니다')
    await user.click(screen.getByRole('button', { name: '전송' }))

    // Stage 6: claim reward
    await user.click(await screen.findByRole('button', { name: '보상 받기' }))
    await waitFor(() => expect(screen.getByRole('button', { name: '수령 완료' })).toBeDisabled())

    // Back on Dashboard with XP reflected
    await waitFor(() => expect(screen.getByText(/피싱헌터/)).toBeInTheDocument())
  })
})
```

- [ ] **Step 2: Run and fix any wiring gaps**

```bash
npx vitest run src/test/chapter1-playthrough.test.tsx
```

Expected: this test will likely surface a handful of small integration mismatches on first run (e.g. an `aria-label` mismatch, a stage-transition race, or a query needing `findBy` instead of `getBy`) since it's the first time every task's output runs together. Fix issues in the component/hook files touched by earlier tasks — do not weaken assertions to make it pass.

- [ ] **Step 3: Run the full test suite to confirm no regressions**

```bash
npm test
```

Expected: all tests across every task pass.

- [ ] **Step 4: Commit**

```bash
git add frontend/src/test
git commit -m "test(web): add capstone integration test for full Chapter 1 playthrough"
```

---

## Post-Plan Notes (not tasks — read before starting Task 1)

- **Swapping in the real backend later:** once `backend/` (Spring Boot) implements the endpoints in `docs/IMPLEMENTATION_GUIDE.md` §5, set `VITE_ENABLE_MOCKS=false` in `.env.production` (already defaults to unset/false there) and remove the `src/mocks/` MSW bootstrap branch in `main.tsx` if desired — `src/services/**` require no changes since they already speak the documented wire contract.
- **Mock data resets on page refresh** — `mockDb` is an in-memory module, not `localStorage`-backed. This is intentional for MVP dev simplicity; note it if a demo needs to survive refreshes (would be a small follow-up task, not included here).
- **Scope explicitly deferred** (per `docs/PRD.md` §22.2+): OAuth login, Chapters 2–5, bank AI in Stage 5, achievements, daily missions, attendance streaks, AI-generated (LLM) reports, and STT/TTS are all out of scope for this plan.
