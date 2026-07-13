import { useState, useRef, useEffect, type FormEvent } from 'react'
import toast from 'react-hot-toast'
import { useChat } from '@hooks/useChat'
import { ApiError } from '@/types/api'

interface Stage2ChatProps {
  recordId: number
  onProceedToJudgment: () => void
}

export function Stage2_Chat({ recordId, onProceedToJudgment }: Stage2ChatProps) {
  const { messages, send, requestHint, isSending, newlyExtractedEvidence } = useChat(recordId)
  const [draft, setDraft] = useState('')
  const [hintText, setHintText] = useState<string | null>(null)
  const [isHinting, setIsHinting] = useState(false)
  const listEndRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    listEndRef.current?.scrollIntoView?.({ block: 'end' })
  }, [messages])

  useEffect(() => {
    if (newlyExtractedEvidence.length === 0) return
    toast.success(`증거가 자동으로 발견되었습니다: ${newlyExtractedEvidence.map((e) => e.value).join(', ')}`)
  }, [newlyExtractedEvidence])

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault()
    const text = draft.trim()
    if (!text || isSending) return
    setDraft('')
    try {
      await send(text)
    } catch (err) {
      setDraft(text)
      toast.error(err instanceof ApiError ? err.message : '메시지 전송에 실패했습니다.')
    }
  }

  const handleHint = async () => {
    setIsHinting(true)
    try {
      const result = await requestHint()
      setHintText(result.hintText)
    } catch (err) {
      toast.error(err instanceof ApiError ? err.message : '힌트를 가져오지 못했습니다.')
    } finally {
      setIsHinting(false)
    }
  }

  return (
    <div className="stage2-chat-container">
      <div className="stage2-chat-messages">
        {messages.map((msg, index) => (
          <div key={`${msg.turn}-${msg.sender}-${index}`} className={`stage2-chat-bubble stage2-chat-bubble-${msg.sender}`}>
            <p className="stage2-chat-bubble-text">{msg.message}</p>
          </div>
        ))}
        <div ref={listEndRef} />
      </div>

      {hintText && (
        <p className="stage2-chat-hint-text">
          <span className="mono">HINT</span> {hintText}
        </p>
      )}

      <div className="stage2-chat-actions">
        <button type="button" className="btn-ghost" onClick={handleHint} disabled={isHinting}>
          힌트 요청
        </button>
        <button type="button" className="btn-primary" onClick={onProceedToJudgment}>
          판단하러 가기
        </button>
      </div>

      <form className="stage2-chat-input-row" onSubmit={handleSubmit}>
        <input
          aria-label="메시지 입력"
          className="stage2-chat-input"
          value={draft}
          onChange={(e) => setDraft(e.target.value)}
          disabled={isSending}
          placeholder="메시지를 입력하세요"
        />
        <button type="submit" className="btn-primary" disabled={isSending || !draft.trim()}>
          전송
        </button>
      </form>
    </div>
  )
}
