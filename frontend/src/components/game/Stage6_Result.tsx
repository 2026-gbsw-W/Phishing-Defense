import { useState } from 'react'
import { Check, X } from 'lucide-react'
import toast from 'react-hot-toast'
import { useReport } from '@hooks/useReport'
import { reportService } from '@services/reportService'
import { useAuthStore } from '@stores/authStore'
import { ApiError } from '@/types/api'

interface Stage6ResultProps {
  recordId: number
  onClaimed: () => void
}

interface ClaimResult {
  xpAdded: number
  levelUp: boolean
}

const MAX_STARS = 3

function renderStars(starRating: number): string {
  return Array.from({ length: MAX_STARS }, (_, i) => (i < starRating ? '★' : '☆')).join('')
}

export function Stage6_Result({ recordId, onClaimed }: Stage6ResultProps) {
  const { data: report, isLoading } = useReport(recordId)
  const [isClaiming, setIsClaiming] = useState(false)
  const [claimResult, setClaimResult] = useState<ClaimResult | null>(null)

  const handleClaim = async () => {
    if (isClaiming || claimResult) return
    setIsClaiming(true)
    try {
      const result = await reportService.claimReport(recordId)
      // Reflect the reward in the global auth session immediately (Dashboard
      // XP/level display) without requiring a page reload.
      useAuthStore.getState().updateXp(result.newTotalXp)
      setClaimResult({ xpAdded: result.xpAdded, levelUp: result.levelUp })
    } catch (err) {
      toast.error(err instanceof ApiError ? err.message : '보상 수령에 실패했습니다.')
    } finally {
      setIsClaiming(false)
    }
  }

  if (isLoading || !report) {
    return (
      <div className="stage6-result-container">
        <p className="stage6-result-empty">불러오는 중...</p>
      </div>
    )
  }

  return (
    <div className="stage6-result-container">
      <div className="stage6-result-summary card">
        <p className="stage6-result-stars" aria-label={`별점 ${report.starRating}점`}>
          {renderStars(report.starRating)}
        </p>
        <p className="stage6-result-score mono">정확도 {report.accuracyScore}점</p>
      </div>

      <p className="stage6-result-feedback">{report.detailedFeedback}</p>

      <div className="stage6-result-section">
        <p className="stage6-result-section-title">
          제출한 증거 ({report.evidenceAnalysis.validCount}/{report.evidenceAnalysis.submittedCount} 유효)
        </p>
        {report.evidenceAnalysis.verdicts.length === 0 && (
          <p className="stage6-result-empty">제출한 증거가 없습니다.</p>
        )}
        {report.evidenceAnalysis.verdicts.length > 0 && (
          <ul className="stage6-result-verdict-list">
            {report.evidenceAnalysis.verdicts.map((v) => (
              <li key={v.evidenceId} className="stage6-result-verdict-item">
                <span className={`stage6-result-verdict-icon ${v.isValid ? 'is-valid' : 'is-invalid'}`}>
                  {v.isValid ? <Check size={16} /> : <X size={16} />}
                </span>
                <span className="stage6-result-verdict-body">
                  <span className="stage6-result-verdict-value">{v.value}</span>
                  <span className="stage6-result-verdict-reason">{v.reason}</span>
                </span>
              </li>
            ))}
          </ul>
        )}
      </div>

      {report.evidenceAnalysis.missedEvidence.length > 0 && (
        <div className="stage6-result-section">
          <p className="stage6-result-section-title">놓친 증거</p>
          <ul className="stage6-result-missed-list">
            {report.evidenceAnalysis.missedEvidence.map((value) => (
              <li key={value} className="stage6-result-missed-item">
                {value}
              </li>
            ))}
          </ul>
        </div>
      )}

      {report.recommendations.length > 0 && (
        <div className="stage6-result-section">
          <p className="stage6-result-section-title">추천</p>
          <ul className="stage6-result-recommendation-list">
            {report.recommendations.map((rec) => (
              <li key={rec} className="stage6-result-recommendation-item">
                {rec}
              </li>
            ))}
          </ul>
        </div>
      )}

      <button type="button" className="btn-primary" disabled={isClaiming || !!claimResult} onClick={handleClaim}>
        {claimResult ? '수령 완료' : '보상 받기'}
      </button>

      {claimResult && (
        <div className="stage6-result-claim-summary">
          <p className="stage6-result-claim-xp">+{claimResult.xpAdded} XP 획득!</p>
          {claimResult.levelUp && <p className="stage6-result-claim-levelup">레벨 업!</p>}
          <button type="button" className="btn-ghost" onClick={onClaimed}>
            완료
          </button>
        </div>
      )}
    </div>
  )
}
