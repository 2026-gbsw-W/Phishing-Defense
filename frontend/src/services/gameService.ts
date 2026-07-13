import { apiClient } from './api'
import type { Chapter, JudgmentResponse, Scenario, ScenarioStartResponse, ScenarioStatus, Stage } from '@/types/game'

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

interface JudgmentWire {
  is_correct: boolean
  feedback: string
  wrong_attempts: number
  stage_progression: Stage
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

  async submitJudgment(recordId: number, isPhishing: boolean): Promise<JudgmentResponse> {
    const { data } = await apiClient.post<JudgmentWire>(`/api/v1/scenarios/${recordId}/judgment`, {
      is_phishing: isPhishing,
    })
    return {
      isCorrect: data.is_correct,
      feedback: data.feedback,
      wrongAttempts: data.wrong_attempts,
      stageProgression: data.stage_progression,
    }
  },
}
