import { useState } from 'react'
import toast from 'react-hot-toast'
import { useEvidenceList } from '@hooks/useEvidence'
import { evidenceService } from '@services/evidenceService'
import { ApiError } from '@/types/api'
import type { EvidenceType } from '@/types/game'

interface Stage4EvidenceProps {
  recordId: number
  onProceed: () => void
}

// Short Korean labels for the evidence types the user can mark during Stage 2
// chat (docs/PRD.md §17, frontend/src/mocks/handlers/chat.ts's guessEvidenceType).
const EVIDENCE_TYPE_LABELS: Record<EvidenceType, string> = {
  phone_number: '전화번호',
  name: '이름',
  email: '이메일',
  amount_mentioned: '금액',
  account_number: '계좌번호',
  suspicious_url: '의심 URL',
  impersonation_type: '사칭 유형',
  impersonation_detail: '사칭 정황',
  urgency: '긴급성 유도',
  tone_unnatural: '부자연스러운 말투',
  information_pattern: '정보 요구 패턴',
  transaction_request: '송금 요구',
  personal_info_request: '개인정보 요구',
  etc: '기타',
}

export function Stage4_Evidence({ recordId, onProceed }: Stage4EvidenceProps) {
  const { data: evidenceList, isLoading } = useEvidenceList(recordId)
  const [selectedIds, setSelectedIds] = useState<Set<number>>(new Set())
  const [isSubmitting, setIsSubmitting] = useState(false)

  const toggleSelected = (evidenceId: number) => {
    setSelectedIds((prev) => {
      const next = new Set(prev)
      if (next.has(evidenceId)) {
        next.delete(evidenceId)
      } else {
        next.add(evidenceId)
      }
      return next
    })
  }

  const handleSubmit = async () => {
    if (isSubmitting) return
    setIsSubmitting(true)
    try {
      await evidenceService.submitEvidence(recordId, [...selectedIds])
      onProceed()
    } catch (err) {
      toast.error(err instanceof ApiError ? err.message : '증거 제출에 실패했습니다.')
    } finally {
      setIsSubmitting(false)
    }
  }

  if (isLoading) {
    return (
      <div className="stage4-evidence-container">
        <p className="stage4-evidence-empty">불러오는 중...</p>
      </div>
    )
  }

  const hasEvidence = !!evidenceList && evidenceList.length > 0

  return (
    <div className="stage4-evidence-container">
      <p className="stage4-evidence-prompt">수집한 증거를 확인하고 제출할 항목을 선택하세요</p>

      {!hasEvidence && (
        <p className="stage4-evidence-empty">저장한 증거가 없습니다. 그래도 신고를 진행할 수 있어요.</p>
      )}

      {hasEvidence && (
        <ul className="stage4-evidence-list">
          {evidenceList.map((evidence) => {
            const isSelected = selectedIds.has(evidence.evidenceId)
            return (
              <li key={evidence.evidenceId} className="stage4-evidence-item">
                <label className="stage4-evidence-item-label">
                  <input
                    type="checkbox"
                    checked={isSelected}
                    onChange={() => toggleSelected(evidence.evidenceId)}
                  />
                  <span className="stage4-evidence-item-body">
                    <span className="stage4-evidence-item-value">{evidence.value}</span>
                    <span className="stage4-evidence-item-type mono">{EVIDENCE_TYPE_LABELS[evidence.type]}</span>
                  </span>
                </label>
              </li>
            )
          })}
        </ul>
      )}

      <button type="button" className="btn-primary" disabled={isSubmitting} onClick={handleSubmit}>
        제출하고 계속하기
      </button>
    </div>
  )
}
