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

// DB schema (docs/PRD.md §13.1.4) only distinguishes 'user' vs 'ai' —
// which persona is speaking is implied by the current stage.
export type ChatSender = 'user' | 'ai'

export interface ChatMessage {
  turn: number
  sender: ChatSender
  message: string
  timestamp: string
}

export interface ChatSendResponse {
  aiResponse: string
  turn: number
  hintAvailable: boolean
}

export interface HintResponse {
  hintText: string
  remainingHints: number
}

// User-marked evidence (docs/PRD.md §11.1 F2, §13.1.5, §17) — the user
// long-presses a chat message to save it; the AI never auto-extracts it.
export type EvidenceType =
  | 'phone_number'
  | 'name'
  | 'email'
  | 'amount_mentioned'
  | 'account_number'
  | 'suspicious_url'
  | 'impersonation_type'
  | 'impersonation_detail'
  | 'urgency'
  | 'tone_unnatural'
  | 'information_pattern'
  | 'transaction_request'
  | 'personal_info_request'
  | 'etc'

export interface Evidence {
  evidenceId: number
  type: EvidenceType
  value: string
  turn: number
  isSubmitted: boolean
  // Both are only meaningful once Stage 6 has judged the evidence.
  isValid: boolean | null
  validityReason: string | null
  importanceLevel: number | null
}

export interface EvidenceMarkResponse {
  evidenceId: number
  evidenceTypeGuess: EvidenceType
  saved: true
}

export interface EvidenceSubmitResponse {
  submittedCount: number
}

export interface JudgmentResponse {
  isCorrect: boolean
  feedback: string
  wrongAttempts: number
  stageProgression: Stage
}

export interface EvidenceVerdict {
  evidenceId: number
  value: string
  isValid: boolean
  reason: string
}

export interface ScenarioReport {
  accuracyScore: number
  starRating: number
  xpEarned: number
  detailedFeedback: string
  evidenceAnalysis: {
    submittedCount: number
    validCount: number
    verdicts: EvidenceVerdict[]
    missedEvidence: string[]
  }
  recommendations: string[]
}

export interface ReportClaimResponse {
  xpAdded: number
  levelUp: boolean
  newTotalXp: number
}
