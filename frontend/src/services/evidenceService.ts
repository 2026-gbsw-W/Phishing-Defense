import { apiClient } from './api'
import type { Evidence, EvidenceSubmitResponse, EvidenceType } from '@/types/game'

interface EvidenceWire {
  evidence_id: number
  type: EvidenceType
  value: string
  turn: number
}

interface EvidenceSubmitWire {
  submitted_count: number
}

export const evidenceService = {
  async getEvidence(recordId: number): Promise<Evidence[]> {
    const { data } = await apiClient.get<EvidenceWire[]>(`/api/v1/scenarios/${recordId}/evidence`)
    return data.map((e) => ({
      evidenceId: e.evidence_id,
      type: e.type,
      value: e.value,
      turn: e.turn,
      // Not carried by the list endpoint — true state comes from a fresh
      // fetch after a submit/report action, not this mid-flow snapshot.
      isSubmitted: false,
      isValid: null,
      validityReason: null,
      importanceLevel: null,
    }))
  },

  async submitEvidence(recordId: number, evidenceIds: number[]): Promise<EvidenceSubmitResponse> {
    const { data } = await apiClient.post<EvidenceSubmitWire>(`/api/v1/scenarios/${recordId}/evidence/submit`, {
      evidence_ids: evidenceIds,
    })
    return { submittedCount: data.submitted_count }
  },
}
