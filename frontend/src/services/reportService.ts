import { apiClient } from './api'
import type { ReportClaimResponse, ScenarioReport } from '@/types/game'

export const reportService = {
  async getReport(recordId: number): Promise<ScenarioReport> {
    const { data } = await apiClient.get<ScenarioReport>(`/api/v1/scenarios/${recordId}/report`)
    return data
  },

  async claimReport(recordId: number): Promise<ReportClaimResponse> {
    const { data } = await apiClient.post<ReportClaimResponse>(`/api/v1/scenarios/${recordId}/report/claim`, {})
    return data
  },
}
