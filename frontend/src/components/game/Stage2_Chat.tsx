import { useState, useRef, useEffect, type FormEvent } from 'react'
import toast from 'react-hot-toast'
import { useChat } from '@hooks/useChat'
import { ApiError } from '@/types/api'

interface Stage2ChatProps {
  recordId: number
  onProceedToJudgment: () => void
}

/** Unique identity for a chat message within a record — `turn` alone collides
 * because the user and AI reply for the same turn share the same turn number. */
function messageKey(turn: number, sender: string, index: number): string {
  return `${turn}-${sender}-${index}`
}

export function Stage2_Chat({ recordId, onProceedToJudgment }: Stage2ChatProps) {
  const { messages, send, requestHint, markEvidence, isSending } = useChat(recordId, 2)
  const [draft, setDraft] = useState('')
  const [hintText, setHintText] = useState<string | null>(null)
  const [isHinting, setIsHinting] = useState(false)
  const [markedKeys, setMarkedKeys] = useState<Set<string>>(new Set())
  const listEndRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    listEndRef.current?.scrollIntoView?.({ block: 'end' })
  }, [messages])

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault()
    const text = draft.trim()
    if (!text || isSending) return
    setDraft('')
    try {
      await send(text)
    } catch (err) {
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

  const handleMark = async (turn: number, message: string, key: string) => {
    try {
      await markEvidence(turn, message)
      setMarkedKeys((prev) => new Set(prev).add(key))
    } catch (err) {
      toast.error(err instanceof ApiError ? err.message : '증거 저장에 실패했습니다.')
    }
  }

  return (
    <div className="stage2-chat-container">
      <div className="stage2-chat-messages">
        {messages.map((msg, index) => {
          const key = messageKey(msg.turn, msg.sender, index)
          const isMarked = markedKeys.has(key)
          return (
            <div key={key} className={`stage2-chat-bubble stage2-chat-bubble-${msg.sender}`}>
              <p className="stage2-chat-bubble-text">{msg.message}</p>
              <button
                type="button"
                className="stage2-chat-mark-btn"
                aria-label={isMarked ? '증거로 저장됨' : '증거로 저장'}
                disabled={isMarked}
                onClick={() => handleMark(msg.turn, msg.message, key)}
              >
                {isMarked ? '저장됨 ✓' : '증거로 저장'}
              </button>
            </div>
          )
        })}
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
