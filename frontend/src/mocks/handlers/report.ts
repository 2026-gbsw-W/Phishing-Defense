import { http, HttpResponse } from 'msw'
import { mockDb, userIdFromToken, type MockRecord } from '../db'
import { GROUND_TRUTH_EVIDENCE, type GroundTruthEvidence } from '../scenarioData'
import { computeScenarioScore, computeXpBreakdown, type ReportQuality } from '@/utils/scoring'
import { getLevelInfo } from '@/utils/levels'

const BASE = '*/api/v1'

// Two Korean strings "match" if either is a substring of the other — this
// covers both directions the PRD's worked examples need: a marked chat
// excerpt like "저는 발신 번호 050-1234-5678로 연락드리고..." contains the
// ground-truth "050-1234-5678", while a user who marks the exact ground-truth
// string verbatim also matches.
function overlaps(a: string, b: string): boolean {
  return a.includes(b) || b.includes(a)
}

function matchGroundTruth(value: string): GroundTruthEvidence | undefined {
  return GROUND_TRUTH_EVIDENCE.find((gt) => overlaps(value, gt.value))
}

// Reason text tiers by the matched ground truth's importance (docs/PRD.md
// §17.3): specific, identifying evidence (phone/URL/account-number-shaped,
// importanceLevel >= 4) reads as "핵심 증거"; softer circumstantial evidence
// (tone/urgency-shaped, importanceLevel < 4) still counts but reads weaker.
function reasonForValid(gt: GroundTruthEvidence, value: string): string {
  if (gt.importanceLevel >= 4) {
    return `"${value}"은(는) 가해자를 특정할 수 있는 핵심 증거로 인정됩니다.`
  }
  return `"${value}"은(는) 유효한 증거이며 정황을 뒷받침하는 데 도움이 됩니다.`
}

function reasonForInvalid(value: string): string {
  return `"${value}"은(는) 정황일 뿐 단독 증거로 보기 어렵습니다.`
}

function reportQualityFor(policeTurnsCompleted: number): ReportQuality {
  if (policeTurnsCompleted >= 2) return 'excellent'
  if (policeTurnsCompleted === 1) return 'good'
  return 'poor'
}

export interface ComputedEvidenceVerdict {
  evidenceId: number
  value: string
  isValid: boolean
  reason: string
}

export interface ComputedReport {
  accuracyScore: number
  starRating: number
  xpEarned: number
  detailedFeedback: string
  evidenceAnalysis: {
    submittedCount: number
    validCount: number
    verdicts: ComputedEvidenceVerdict[]
    missedEvidence: string[]
  }
  recommendations: string[]
}

/**
 * Pure derivation of a Stage 6 report from a scenario record. Both HTTP
 * handlers below call this so the scoring/evidence-matching logic lives in
 * exactly one place. Feeds `computeScenarioScore`/`computeXpBreakdown`
 * (frontend/src/utils/scoring.ts) — those already implement the correct
 * formulas; this function's only job is deriving their inputs from `mockDb`.
 */
export function computeReportForRecord(record: MockRecord): ComputedReport {
  const submitted = record.evidence.filter((e) => e.isSubmitted)

  const verdicts: ComputedEvidenceVerdict[] = submitted.map((e) => {
    const match = matchGroundTruth(e.value)
    return match
      ? { evidenceId: e.evidenceId, value: e.value, isValid: true, reason: reasonForValid(match, e.value) }
      : { evidenceId: e.evidenceId, value: e.value, isValid: false, reason: reasonForInvalid(e.value) }
  })

  const missedGroundTruth = GROUND_TRUTH_EVIDENCE.filter(
    (gt) => !submitted.some((e) => overlaps(e.value, gt.value)),
  )
  const missedEvidence = missedGroundTruth.map((gt) => gt.value)
  const missedCoreEvidenceCount = missedGroundTruth.filter((gt) => gt.importanceLevel >= 4).length

  const submittedCount = submitted.length
  const validCount = verdicts.filter((v) => v.isValid).length
  const evidenceValidPercentage = submittedCount > 0 ? Math.round((validCount / submittedCount) * 100) : 0

  const reportQuality = reportQualityFor(record.policeTurnsCompleted)
  const judgmentTurn = record.judgmentTurn ?? record.currentTurn
  const wrongJudgmentAttempts = record.wrongJudgmentAttempts
  const hintsUsed = record.hintsUsed

  const score = computeScenarioScore({
    judgmentTurn,
    wrongJudgmentAttempts,
    responseWisdomScore: 20, // NLP over-disclosure detection is out of MVP scope; always full marks.
    evidenceValidPercentage,
    missedCoreEvidenceCount,
    reportQuality,
    hintsUsed,
  })

  const xp = computeXpBreakdown({
    starRating: score.starRating,
    hintsUsed,
    evidenceValidPercentage,
    missedCoreEvidenceCount,
    reportQuality,
    wrongEvidenceSubmittedCount: submittedCount - validCount,
  })

  const missedCoreItem = missedGroundTruth.find((gt) => gt.importanceLevel >= 4)

  const judgmentComment =
    wrongJudgmentAttempts === 0
      ? '피싱 여부를 정확히 판단했습니다.'
      : `${wrongJudgmentAttempts}번의 시행착오 끝에 피싱임을 판단했습니다.`
  const evidenceComment =
    submittedCount === 0
      ? '제출한 증거가 없어 신고의 신뢰도가 낮습니다.'
      : `제출한 증거 ${submittedCount}건 중 ${validCount}건이 유효한 증거로 인정되었습니다.`
  const missedComment = missedCoreItem ? ` 다만 "${missedCoreItem.value}"은(는) 매우 중요한 증거입니다.` : ''
  const detailedFeedback = `${judgmentComment} ${evidenceComment}${missedComment}`

  const recommendations = [
    '다음 챕터에서 더 연습해보세요.',
    ...(missedCoreItem ? [`"${missedCoreItem.value}"과(와) 같은 핵심 증거를 놓치지 않도록 주의하세요.`] : []),
  ]

  return {
    accuracyScore: score.total,
    starRating: score.starRating,
    xpEarned: xp.total,
    detailedFeedback,
    evidenceAnalysis: { submittedCount, validCount, verdicts, missedEvidence },
    recommendations,
  }
}

export const reportHandlers = [
  http.get(`${BASE}/scenarios/:recordId/report`, ({ request, params }) => {
    if (!userIdFromToken(request.headers.get('Authorization'))) {
      return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })
    }
    const record = mockDb.records.get(Number(params.recordId))
    if (!record) return HttpResponse.json({ message: 'not found' }, { status: 404 })

    const report = computeReportForRecord(record)
    return HttpResponse.json({
      accuracy_score: report.accuracyScore,
      star_rating: report.starRating,
      xp_earned: report.xpEarned,
      detailed_feedback: report.detailedFeedback,
      evidence_analysis: {
        submitted_count: report.evidenceAnalysis.submittedCount,
        valid_count: report.evidenceAnalysis.validCount,
        verdicts: report.evidenceAnalysis.verdicts.map((v) => ({
          evidence_id: v.evidenceId,
          value: v.value,
          is_valid: v.isValid,
          reason: v.reason,
        })),
        missed_evidence: report.evidenceAnalysis.missedEvidence,
      },
      recommendations: report.recommendations,
    })
  }),

  http.post(`${BASE}/scenarios/:recordId/report/claim`, ({ request, params }) => {
    const userId = userIdFromToken(request.headers.get('Authorization'))
    if (!userId) return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })
    const record = mockDb.records.get(Number(params.recordId))
    if (!record) return HttpResponse.json({ message: 'not found' }, { status: 404 })
    if (record.claimed) {
      return HttpResponse.json({ message: '이미 보상을 수령했습니다.' }, { status: 400 })
    }

    const report = computeReportForRecord(record)
    const user = mockDb.users.get(record.userId)
    if (!user) return HttpResponse.json({ message: 'not found' }, { status: 404 })

    const previousLevel = getLevelInfo(user.totalXp).level
    user.totalXp += report.xpEarned
    const newLevel = getLevelInfo(user.totalXp).level
    record.claimed = true
    // A successful claim is the last step of a full playthrough — mark the
    // record's stage as fully complete so GET .../status's is_completed
    // (stage === 6 && claimed) reflects reality instead of staying stuck.
    record.stage = 6

    return HttpResponse.json({
      xp_added: report.xpEarned,
      level_up: newLevel > previousLevel,
      new_total_xp: user.totalXp,
    })
  }),
]
