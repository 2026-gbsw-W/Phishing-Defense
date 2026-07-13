import { useState } from 'react'
import toast from 'react-hot-toast'
import { gameService } from '@/services/gameService'
import { ApiError } from '@/types/api'
import type { Stage } from '@/types/game'

interface Stage3JudgmentProps {
  recordId: number
  onProceed: (stageProgression: Stage) => void
}

export function Stage3_Judgment({ recordId, onProceed }: Stage3JudgmentProps) {
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [feedback, setFeedback] = useState<string | null>(null)
  const [isCorrect, setIsCorrect] = useState<boolean | null>(null)
  const [canProceed, setCanProceed] = useState(false)
  const [stageProgression, setStageProgression] = useState<Stage | null>(null)

  const handleJudge = async (isPhishing: boolean) => {
    if (isSubmitting) return
    setIsSubmitting(true)
    try {
      const result = await gameService.submitJudgment(recordId, isPhishing)
      setFeedback(result.feedback)
      setIsCorrect(result.isCorrect)
      if (result.stageProgression !== 3) {
        setCanProceed(true)
        setStageProgression(result.stageProgression)
      }
    } catch (err) {
      toast.error(err instanceof ApiError ? err.message : '판단 제출에 실패했습니다.')
    } finally {
      setIsSubmitting(false)
    }
  }

  const handleContinue = () => {
    if (stageProgression !== null) {
      onProceed(stageProgression)
    }
  }

  return (
    <div className="stage3-judgment-container">
      <p className="stage3-judgment-prompt">이 상황이 피싱이라고 생각하시나요?</p>

      {!canProceed && (
        <div className="stage3-judgment-actions">
          <button
            type="button"
            className="btn-primary"
            disabled={isSubmitting}
            onClick={() => handleJudge(true)}
          >
            피싱이 맞습니다
          </button>
          <button
            type="button"
            className="btn-ghost"
            disabled={isSubmitting}
            onClick={() => handleJudge(false)}
          >
            정상적인 문자입니다
          </button>
        </div>
      )}

      {feedback && (
        <p className={`stage3-judgment-feedback ${isCorrect ? 'stage3-judgment-feedback-correct' : 'stage3-judgment-feedback-wrong'}`}>
          {feedback}
        </p>
      )}

      {canProceed && (
        <button type="button" className="btn-primary" onClick={handleContinue}>
          다음으로
        </button>
      )}
    </div>
  )
}
