// UI-level stage (1-6, our own game-screen concept). The real backend also
// has an entity called "Stage" but that's their internal name for what we
// call a Scenario (a chapter's individual playable case) — see `Scenario`
// below. Do not confuse the two.
export type Stage = 1 | 2 | 3 | 4 | 5 | 6

export interface Chapter {
  chapterId: number
  title: string
  description: string
  difficulty: number
  scenarioCount: number
  orderIndex: number
}

// Backend calls this a "Stage" (GET /chapters/{chapterId}/stages, DB table
// `scenarios`) — renamed here to Scenario to avoid colliding with our UI
// Stage concept above.
export interface Scenario {
  stageId: number
  chapterId: number
  title: string
  initialMessage: string
  phishingType: string
  difficulty: number
  completed: boolean | null
}

export interface ScenarioStartResponse {
  recordId: number
  initialMessage: string
  timestamp: string
}

export interface ScenarioStatus {
  recordId: number
  scenarioId: number
  stage: number
  currentTurn: number
  isCompleted: boolean
  hintsUsed: number
}

export type ChatSender = 'user' | 'ai'

export interface ChatHistoryEntry {
  turn: number
  sender: ChatSender
  message: string
  timestamp: string
}

export interface ExtractedEvidenceItem {
  type: string
  value: string
}

export interface ChatSendResponse {
  aiResponse: string
  turn: number
  extractedEvidence: ExtractedEvidenceItem[]
  hintAvailable: boolean
}

export interface HintResponse {
  hintText: string
  remainingHints: number
}

export interface JudgmentResponse {
  isCorrect: boolean
  feedback: string
  stageProgression: number
}

export interface EvidenceItem {
  evidenceId: number
  type: string
  value: string
  importance: number
}

export interface EvidenceConfirmResponse {
  evidenceCollectionPercentage: number
  missedEvidence: EvidenceItem[]
}

/** Mirrors the AI-generated risk analysis embedded in a scenario report,
 * when the backend was able to reach the AI service (`aiAnalysis` is null
 * otherwise). Field set matches `TrainingResultResponse` from
 * POST /chat/{recordId}/end, which the report reuses. */
export interface AiRiskAnalysis {
  personalInfoRequested: boolean
  accountNumberRequested: boolean
  moneyRequested: boolean
  urgencyCreated: boolean
  authorityImpersonation: boolean
  suspiciousLink: boolean
  userFellForIt: boolean
  riskScore: number
  dangerousMessages: string[]
  evidenceFeedback: string
  goodPoints: string
  mistakes: string
  improvementTips: string
}

export interface ScenarioReport {
  accuracyScore: number
  starRating: number
  xpEarned: number
  detailedFeedback: string
  evidenceAnalysis: {
    submittedCount: number
    totalCount: number
    missedEvidence: EvidenceItem[]
  }
  recommendations: string[]
  aiAnalysis: AiRiskAnalysis | null
}

export interface ReportClaimResponse {
  xpAdded: number
  levelUp: boolean
  newBalance: number
}
