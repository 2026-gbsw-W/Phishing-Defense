import { useState, useRef, useEffect, type FormEvent } from 'react'
import toast from 'react-hot-toast'
import { useChat } from '@hooks/useChat'
import { ApiError } from '@/types/api'

interface Stage5ReportProps {
  recordId: number
  onComplete: () => void
}

/** Unique identity for a chat message within a record — `turn` alone collides
 * because the user and AI reply for the same turn share the same turn number. */
function messageKey(turn: number, sender: string, index: number): string {
  return `${turn}-${sender}-${index}`
}

export function Stage5_Report({ recordId, onComplete }: Stage5ReportProps) {
  const { messages, send, isSending } = useChat(recordId, 5)
  const [draft, setDraft] = useState('')
  const [hasSent, setHasSent] = useState(false)
  const listEndRef = useRef<HTMLDivElement>(null)

  // The chat history is shared across the whole scenario run (Stage 2's
  // criminal exchange and Stage 5's police exchange both land in the same
  // list) — only render this stage's own messages.
  const reportMessages = messages.filter((msg) => msg.stage === 5)

  useEffect(() => {
    listEndRef.current?.scrollIntoView?.({ block: 'end' })
  }, [reportMessages])

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault()
    const text = draft.trim()
    if (!text || isSending) return
    setDraft('')
    try {
      await send(text)
      setHasSent(true)
    } catch (err) {
      toast.error(err instanceof ApiError ? err.message : '메시지 전송에 실패했습니다.')
    }
  }

  return (
    <div className="stage5-report-container">
      <p className="stage5-report-header">📞 경찰 신고</p>

      <div className="stage5-report-messages">
        {reportMessages.length === 0 && (
          <p className="stage5-report-empty">신고할 내용을 입력해 대화를 시작하세요.</p>
        )}
        {reportMessages.map((msg, index) => {
          const key = messageKey(msg.turn, msg.sender, index)
          return (
            <div key={key} className={`stage5-report-bubble stage5-report-bubble-${msg.sender}`}>
              <p className="stage5-report-bubble-text">{msg.message}</p>
            </div>
          )
        })}
        <div ref={listEndRef} />
      </div>

      <div className="stage5-report-actions">
        <button type="button" className="btn-primary" disabled={!hasSent} onClick={onComplete}>
          신고 완료
        </button>
      </div>

      <form className="stage5-report-input-row" onSubmit={handleSubmit}>
        <input
          aria-label="메시지 입력"
          className="stage5-report-input"
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
