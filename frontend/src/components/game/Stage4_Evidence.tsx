import { useState } from 'react'
import toast from 'react-hot-toast'
import { useEvidenceList } from '@hooks/useEvidence'
import { evidenceService } from '@services/evidenceService'
import { evidenceTypeLabel } from '@utils/evidenceLabels'
import { ApiError } from '@/types/api'

interface Stage4EvidenceProps {
  recordId: number
  onProceed: () => void
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
      await evidenceService.confirmEvidence(recordId, [...selectedIds])
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
      <p className="stage4-evidence-prompt">자동으로 수집된 증거를 확인하고 제출할 항목을 선택하세요</p>

      {!hasEvidence && (
        <p className="stage4-evidence-empty">아직 발견된 증거가 없습니다. 그래도 신고를 진행할 수 있어요.</p>
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
                    <span className="stage4-evidence-item-type mono">
                      {evidenceTypeLabel(evidence.type)}
                    </span>
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
