import { apiClient } from '@/services/api'
import type { ChatMessage, ChatSendResponse, EvidenceMarkResponse, HintResponse, Stage } from '@/types/game'

interface HistoryWire {
  turn: number
  sender: ChatMessage['sender']
  message: string
  timestamp: string
  stage: Stage
}

interface SendWire {
  ai_response: string
  turn: number
  hint_available: boolean
}

interface HintWire {
  hint_text: string
  remaining_hints: number
}

interface EvidenceMarkWire {
  evidence_id: number
  evidence_type_guess: EvidenceMarkResponse['evidenceTypeGuess']
  saved: true
}

export const chatService = {
  async getHistory(recordId: number): Promise<ChatMessage[]> {
    const { data } = await apiClient.get<HistoryWire[]>(`/api/v1/chat/${recordId}/history`)
    return data.map((m) => ({
      turn: m.turn,
      sender: m.sender,
      message: m.message,
      timestamp: m.timestamp,
      stage: m.stage,
    }))
  },

  async sendMessage(recordId: number, message: string, stage: Stage): Promise<ChatSendResponse> {
    const { data } = await apiClient.post<SendWire>(`/api/v1/chat/${recordId}/send`, {
      message,
      stage,
    })
    return {
      aiResponse: data.ai_response,
      turn: data.turn,
      hintAvailable: data.hint_available,
    }
  },

  async requestHint(recordId: number): Promise<HintResponse> {
    const { data } = await apiClient.post<HintWire>(`/api/v1/chat/${recordId}/hint`)
    return {
      hintText: data.hint_text,
      remainingHints: data.remaining_hints,
    }
  },

  async markEvidence(recordId: number, turn: number, evidenceValue: string): Promise<EvidenceMarkResponse> {
    const { data } = await apiClient.post<EvidenceMarkWire>(`/api/v1/chat/${recordId}/evidence/mark`, {
      turn,
      evidence_value: evidenceValue,
    })
    return {
      evidenceId: data.evidence_id,
      evidenceTypeGuess: data.evidence_type_guess,
      saved: data.saved,
    }
  },
}
