import { useState, useRef, useEffect, type FormEvent } from 'react'
import toast from 'react-hot-toast'
import { useQueryClient } from '@tanstack/react-query'
import { useChat } from '@hooks/useChat'
import { useEvidenceList } from '@hooks/useEvidence'
import { evidenceTypeLabel } from '@utils/evidenceLabels'
import { ApiError } from '@/types/api'

interface Stage2ChatProps {
  recordId: number
  // The real backend's chat history never includes the initial SMS (it's
  // only returned once, from the scenario-start response) — show it as the
  // conversation's opening bubble here too, otherwise the chat screen looks
  // empty until the player sends something.
  initialMessage: string | null
  onProceedToJudgment: () => void
}

export function Stage2_Chat({ recordId, initialMessage, onProceedToJudgment }: Stage2ChatProps) {
  const queryClient = useQueryClient()
  const { messages, send, requestHint, isSending, newlyExtractedEvidence } = useChat(recordId)
  const { data: evidenceList } = useEvidenceList(recordId)
  const displayMessages = initialMessage
    ? [{ turn: 0, sender: 'ai' as const, message: initialMessage, timestamp: '' }, ...messages]
    : messages
  const [draft, setDraft] = useState('')
  const [hintText, setHintText] = useState<string | null>(null)
  const [isHinting, setIsHinting] = useState(false)
  const [isEvidenceOpen, setIsEvidenceOpen] = useState(false)
  const listEndRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    listEndRef.current?.scrollIntoView?.({ block: 'end' })
  }, [messages])

  useEffect(() => {
    if (newlyExtractedEvidence.length === 0) return
    toast.success(`증거가 자동으로 발견되었습니다: ${newlyExtractedEvidence.map((e) => e.value).join(', ')}`)
    // The chat send response carries newly-found evidence inline, but the
    // evidence catalog itself lives server-side — refetch it so the "내
    // 증거함" count/list here stays in sync with what Stage 4 will show.
    queryClient.invalidateQueries({ queryKey: ['evidence', recordId] })
  }, [newlyExtractedEvidence, queryClient, recordId])

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

  const evidenceCount = evidenceList?.length ?? 0

  return (
    <div className="stage2-chat-container">
      <div className="stage2-chat-messages">
        {displayMessages.map((msg, index) => (
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

      <div className="stage2-chat-evidence-box">
        <button
          type="button"
          className="stage2-chat-evidence-toggle"
          onClick={() => setIsEvidenceOpen((v) => !v)}
          disabled={evidenceCount === 0}
        >
          내 증거함 ({evidenceCount}개 저장됨)
        </button>
        {isEvidenceOpen && evidenceCount > 0 && (
          <ul className="stage2-chat-evidence-list">
            {evidenceList!.map((item) => (
              <li key={item.evidenceId} className="stage2-chat-evidence-item">
                <span className="stage2-chat-evidence-item-value">{item.value}</span>
                <span className="stage2-chat-evidence-item-type mono">
                  {evidenceTypeLabel(item.type)}
                </span>
              </li>
            ))}
          </ul>
        )}
      </div>

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
