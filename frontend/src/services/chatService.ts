import { apiClient } from '@/services/api'
import type { ChatMessage, ChatSendResponse, HintResponse, Stage } from '@/types/game'

interface HistoryWire {
  turn: number
  sender: ChatMessage['sender']
  message: string
  timestamp: string
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

export const chatService = {
  async getHistory(recordId: number): Promise<ChatMessage[]> {
    const { data } = await apiClient.get<HistoryWire[]>(`/api/v1/chat/${recordId}/history`)
    return data
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
}
