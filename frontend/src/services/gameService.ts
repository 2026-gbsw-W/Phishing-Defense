import { apiClient } from './api'
import type { Chapter, JudgmentResponse, Scenario, ScenarioStartResponse, ScenarioStatus } from '@/types/game'

export const gameService = {
  async getChapters(): Promise<Chapter[]> {
    const { data } = await apiClient.get<Chapter[]>('/api/v1/chapters')
    return data
  },

  async getChapter(chapterId: number): Promise<Chapter> {
    const { data } = await apiClient.get<Chapter>(`/api/v1/chapters/${chapterId}`)
    return data
  },

  /** Backend calls these "stages" (its internal name for a playable scenario). */
  async getScenarios(chapterId: number): Promise<Scenario[]> {
    const { data } = await apiClient.get<Scenario[]>(`/api/v1/chapters/${chapterId}/stages`)
    return data
  },

  async startScenario(stageId: number): Promise<ScenarioStartResponse> {
    const { data } = await apiClient.post<ScenarioStartResponse>(`/api/v1/scenarios/${stageId}/start`)
    return data
  },

  async getStatus(recordId: number): Promise<ScenarioStatus> {
    const { data } = await apiClient.get<ScenarioStatus>(`/api/v1/scenarios/${recordId}/status`)
    return data
  },

  async submitJudgment(recordId: number, isPhishing: boolean): Promise<JudgmentResponse> {
    const { data } = await apiClient.post<JudgmentResponse>(`/api/v1/scenarios/${recordId}/judgment`, {
      isPhishing,
    })
    return data
  },
}
