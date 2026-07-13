import { useState, useEffect, useCallback } from 'react'
import { chatService } from '@/services/chatService'
import type { ChatMessage, Stage } from '@/types/game'

export function useChat(recordId: number, stage: Stage) {
  const [messages, setMessages] = useState<ChatMessage[]>([])
  const [isSending, setIsSending] = useState(false)

  useEffect(() => {
    chatService.getHistory(recordId).then(setMessages)
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
