import { apiClient } from '@/services/api'
import type { ChatHistoryEntry, ChatSendResponse, HintResponse } from '@/types/game'

export const chatService = {
  async getHistory(recordId: number): Promise<ChatHistoryEntry[]> {
    const { data } = await apiClient.get<ChatHistoryEntry[]>(`/api/v1/chat/${recordId}/history`)
    return data
  },

  async sendMessage(recordId: number, message: string): Promise<ChatSendResponse> {
    const { data } = await apiClient.post<ChatSendResponse>(`/api/v1/chat/${recordId}/send`, { message })
    return data
  },

  async requestHint(recordId: number): Promise<HintResponse> {
    const { data } = await apiClient.post<HintResponse>(`/api/v1/chat/${recordId}/hint`)
    return data
  },
}
