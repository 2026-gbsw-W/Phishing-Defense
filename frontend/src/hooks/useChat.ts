import { useState, useEffect, useCallback } from 'react'
import toast from 'react-hot-toast'
import { chatService } from '@/services/chatService'
import { ApiError } from '@/types/api'
import type { ChatHistoryEntry, ExtractedEvidenceItem } from '@/types/game'

export function useChat(recordId: number) {
  const [messages, setMessages] = useState<ChatHistoryEntry[]>([])
  const [isSending, setIsSending] = useState(false)
  const [newlyExtractedEvidence, setNewlyExtractedEvidence] = useState<ExtractedEvidenceItem[]>([])

  useEffect(() => {
    chatService
      .getHistory(recordId)
      .then(setMessages)
      .catch((err) => {
        toast.error(err instanceof ApiError ? err.message : '대화 기록을 불러오지 못했습니다.')
      })
  }, [recordId])

  const send = useCallback(
    async (text: string) => {
      setIsSending(true)
      try {
        const result = await chatService.sendMessage(recordId, text)
        const history = await chatService.getHistory(recordId)
        setMessages(history)
        if (result.extractedEvidence.length > 0) {
          setNewlyExtractedEvidence(result.extractedEvidence)
        }
        return result
      } finally {
        setIsSending(false)
      }
    },
    [recordId],
  )

  const requestHint = useCallback(() => chatService.requestHint(recordId), [recordId])

  return { messages, send, requestHint, isSending, newlyExtractedEvidence }
}
