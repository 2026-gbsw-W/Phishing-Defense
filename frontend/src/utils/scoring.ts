// Star rating and XP formulas per docs/PRD.md §12.1.1 (XP) and §12.2.1
// (star rating). Both are a clean 100/no-time model — there is no
// duration/time-bonus component in the current spec.

export type ReportQuality = 'excellent' | 'good' | 'basic' | 'poor'

export interface ScoreInput {
  judgmentTurn: number
  wrongJudgmentAttempts: number
  /** 20 = no over-disclosure, 15 = slightly suspicious answer, 0 = gave up personal info */
  responseWisdomScore: 0 | 15 | 20
  /** validCount / submittedCount * 100, or 0 if nothing was submitted */
  evidenceValidPercentage: number
  missedCoreEvidenceCount: number
  reportQuality: ReportQuality
  hintsUsed: number
}

export interface ScoreResult {
  accuracy: number // /50
  evidence: number // /20
  report: number // /20
  hints: number // /10
  total: number // /100
  starRating: 0 | 1 | 2 | 3
}

function judgmentAccuracyScore(turn: number, wrongAttempts: number): number {
  if (wrongAttempts >= 2) return 10
  if (wrongAttempts === 1) return 15
  if (turn <= 2) return 30
  if (turn <= 4) return 25
  return 20
}

function evidenceScore(pct: number, missedCore: number): number {
  if (pct >= 100 && missedCore === 0) return 20
  if (pct >= 90) return 18
  if (pct >= 70) return 15
  if (pct >= 50) return 10
  return 5
}

function reportScore(quality: ReportQuality): number {
  switch (quality) {
    case 'excellent':
      return 20
    case 'good':
      return 15
    case 'basic':
      return 10
    case 'poor':
      return 5
  }
}

function hintsScore(hintsUsed: number): number {
  if (hintsUsed <= 0) return 10
  if (hintsUsed === 1) return 9
  if (hintsUsed === 2) return 7
  if (hintsUsed === 3) return 4
  return 0
}

export function computeScenarioScore(input: ScoreInput): ScoreResult {
  const accuracy =
    judgmentAccuracyScore(input.judgmentTurn, input.wrongJudgmentAttempts) +
    input.responseWisdomScore
  const evidence = evidenceScore(input.evidenceValidPercentage, input.missedCoreEvidenceCount)
  const report = reportScore(input.reportQuality)
  const hints = hintsScore(input.hintsUsed)
  const total = accuracy + evidence + report + hints

  const starRating = total >= 90 ? 3 : total >= 80 ? 2 : total >= 60 ? 1 : 0

  return { accuracy, evidence, report, hints, total, starRating }
}

export interface XpInput {
  starRating: 0 | 1 | 2 | 3
  hintsUsed: number
  evidenceValidPercentage: number
  missedCoreEvidenceCount: number
  reportQuality: ReportQuality
  wrongEvidenceSubmittedCount: number
}

export interface XpBreakdown {
  base: number
  starBonus: number
  hintsBonus: number
  evidenceBonus: number
  reportBonus: number
  penalty: number
  total: number
}

const STAR_BONUS = [0, 10, 30, 70] as const

export function computeXpBreakdown(input: XpInput): XpBreakdown {
  const base = 150
  const starBonus = STAR_BONUS[input.starRating]

  const hintsBonus = input.hintsUsed === 0 ? 20 : 0
  const evidenceBonus =
    input.evidenceValidPercentage >= 100 && input.missedCoreEvidenceCount === 0 ? 40 : 0
  const reportBonus = input.reportQuality === 'excellent' ? 50 : 0

  const hintsPenalty = input.hintsUsed > 0 ? 5 * input.hintsUsed : 0
  const wrongEvidencePenalty = 5 * input.wrongEvidenceSubmittedCount
  const reportPenalty = input.reportQuality === 'poor' ? 20 : 0
  const penalty = hintsPenalty + wrongEvidencePenalty + reportPenalty

  const total = base + starBonus + hintsBonus + evidenceBonus + reportBonus - penalty

  return { base, starBonus, hintsBonus, evidenceBonus, reportBonus, penalty, total }
}
