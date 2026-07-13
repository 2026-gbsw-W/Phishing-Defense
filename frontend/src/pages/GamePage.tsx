import { useEffect, useRef, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import toast from 'react-hot-toast'
import { GameLayout } from '@components/game/GameLayout'
import { Stage1_SMS } from '@components/game/Stage1_SMS'
import { Stage2_Chat } from '@components/game/Stage2_Chat'
import { Stage3_Judgment } from '@components/game/Stage3_Judgment'
import { Stage4_Evidence } from '@components/game/Stage4_Evidence'
import { Stage5_Report } from '@components/game/Stage5_Report'
import { Stage6_Result } from '@components/game/Stage6_Result'
import { useScenarioStatus } from '@hooks/useScenario'
import { chatService } from '@services/chatService'
import { useGameStore } from '@stores/gameStore'
import { ApiError } from '@/types/api'
import type { Stage } from '@/types/game'

/**
 * Wires all 6 already-built stage components into one page, driven by local
 * `viewStage` state. The server is the source of truth for judgment/claim
 * outcomes, but which component renders is a purely client-side router —
 * each stage's own `onProceed*`/`onComplete`/`onClaimed` callback advances it.
 */
export function GamePage() {
  const { recordId: recordIdParam } = useParams<{ recordId: string }>()
  const recordId = Number(recordIdParam)
  const navigate = useNavigate()

  const [viewStage, setViewStage] = useState<Stage>(1)
  const [initialMessage, setInitialMessage] = useState<string | null>(null)

  const { data: status } = useScenarioStatus(recordId)
  const hasSeededFromStatus = useRef(false)

  useEffect(() => {
    useGameStore.getState().start(recordId)
  }, [recordId])

  useEffect(() => {
    let cancelled = false
    chatService
      .getHistory(recordId)
      .then((history) => {
        if (cancelled) return
        const initial = history.find((m) => m.turn === 0)
        if (initial) setInitialMessage(initial.message)
      })
      .catch((err) => {
        if (cancelled) return
        toast.error(err instanceof ApiError ? err.message : '메시지를 불러오지 못했습니다.')
      })
    return () => {
      cancelled = true
    }
  }, [recordId])

  // Refresh-resilience: seed the view stage from the server's status once,
  // the first time it resolves, so a page refresh mid/post-judgment (stage
  // 4+) lands back where the server thinks the player is instead of
  // restarting at Stage 1. Only applied once (not on every status refetch),
  // and always via Math.max against the CURRENT viewStage rather than a bare
  // overwrite, so a slow-resolving status fetch can never stomp a viewStage
  // the player has already advanced past locally in the meantime (e.g.
  // clicking through Stage 1 before this request lands).
  useEffect(() => {
    if (status && !hasSeededFromStatus.current) {
      hasSeededFromStatus.current = true
      setViewStage((prev) => Math.max(prev, status.stage) as Stage)
    }
  }, [status])

  if (viewStage === 1 && initialMessage === null) {
    return null
  }

  return (
    <GameLayout stage={viewStage}>
      {viewStage === 1 && initialMessage !== null && (
        <Stage1_SMS message={initialMessage} onContinue={() => setViewStage(2)} />
      )}
      {viewStage === 2 && (
        <Stage2_Chat recordId={recordId} onProceedToJudgment={() => setViewStage(3)} />
      )}
      {viewStage === 3 && (
        <Stage3_Judgment recordId={recordId} onProceed={(stageProgression) => setViewStage(stageProgression)} />
      )}
      {viewStage === 4 && <Stage4_Evidence recordId={recordId} onProceed={() => setViewStage(5)} />}
      {viewStage === 5 && <Stage5_Report recordId={recordId} onComplete={() => setViewStage(6)} />}
      {viewStage === 6 && <Stage6_Result recordId={recordId} onClaimed={() => navigate('/')} />}
    </GameLayout>
  )
}
