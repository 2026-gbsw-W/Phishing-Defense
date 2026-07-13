import { apiClient } from './api'
import type { EvidenceVerdict, ReportClaimResponse, ScenarioReport } from '@/types/game'

interface EvidenceVerdictWire {
  evidence_id: number
  value: string
  is_valid: boolean
  reason: string
}

interface ScenarioReportWire {
  accuracy_score: number
  star_rating: number
  xp_earned: number
  detailed_feedback: string
  evidence_analysis: {
    submitted_count: number
    valid_count: number
    verdicts: EvidenceVerdictWire[]
    missed_evidence: string[]
  }
  recommendations: string[]
}

interface ReportClaimWire {
  xp_added: number
  level_up: boolean
  new_total_xp: number
}

function toVerdict(w: EvidenceVerdictWire): EvidenceVerdict {
  return { evidenceId: w.evidence_id, value: w.value, isValid: w.is_valid, reason: w.reason }
}

export const reportService = {
  async getReport(recordId: number): Promise<ScenarioReport> {
    const { data } = await apiClient.get<ScenarioReportWire>(`/api/v1/scenarios/${recordId}/report`)
    return {
      accuracyScore: data.accuracy_score,
      starRating: data.star_rating,
      xpEarned: data.xp_earned,
      detailedFeedback: data.detailed_feedback,
      evidenceAnalysis: {
        submittedCount: data.evidence_analysis.submitted_count,
        validCount: data.evidence_analysis.valid_count,
        verdicts: data.evidence_analysis.verdicts.map(toVerdict),
        missedEvidence: data.evidence_analysis.missed_evidence,
      },
      recommendations: data.recommendations,
    }
  },

  async claimReport(recordId: number): Promise<ReportClaimResponse> {
    const { data } = await apiClient.post<ReportClaimWire>(`/api/v1/scenarios/${recordId}/report/claim`, {})
    return { xpAdded: data.xp_added, levelUp: data.level_up, newTotalXp: data.new_total_xp }
  },
}
