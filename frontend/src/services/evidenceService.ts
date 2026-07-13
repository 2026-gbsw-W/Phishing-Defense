import { apiClient } from './api'
import type { EvidenceConfirmResponse, EvidenceItem } from '@/types/game'

export const evidenceService = {
  /** Evidence here is auto-extracted server-side as the player chats (rule-based
   * keyword matching against the scenario's evidence catalog) — there is no
   * user "mark" action; this just lists what's been found so far. */
  async getEvidence(recordId: number): Promise<EvidenceItem[]> {
    const { data } = await apiClient.get<EvidenceItem[]>(`/api/v1/scenarios/${recordId}/evidence`)
    return data
  },

  async confirmEvidence(recordId: number, evidenceIds: number[]): Promise<EvidenceConfirmResponse> {
    const { data } = await apiClient.post<EvidenceConfirmResponse>(
      `/api/v1/scenarios/${recordId}/evidence/confirm`,
      { selectedEvidenceIds: evidenceIds },
    )
    return data
  },
}
