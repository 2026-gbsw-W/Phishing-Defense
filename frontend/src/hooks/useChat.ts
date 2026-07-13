import { useState, useEffect, useCallback } from 'react'
import toast from 'react-hot-toast'
import { chatService } from '@/services/chatService'
import { ApiError } from '@/types/api'
import type { ChatMessage, Stage } from '@/types/game'

export function useChat(recordId: number, stage: Stage) {
  const [messages, setMessages] = useState<ChatMessage[]>([])
  const [isSending, setIsSending] = useState(false)

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
        const result = await chatService.sendMessage(recordId, text, stage)
        const history = await chatService.getHistory(recordId)
        setMessages(history)
        return result
      } finally {
        setIsSending(false)
      }
    },
    [recordId, stage],
  )

  const requestHint = useCallback(() => chatService.requestHint(recordId), [recordId])

  const markEvidence = useCallback(
    (turn: number, evidenceValue: string) => chatService.markEvidence(recordId, turn, evidenceValue),
    [recordId],
  )

  return { messages, send, requestHint, markEvidence, isSending }
}
