import { useEffect, useState } from 'react'
import { useLocation, useNavigate, useParams } from 'react-router-dom'
import { GameLayout } from '@components/game/GameLayout'
import { Stage1_SMS } from '@components/game/Stage1_SMS'
import { Stage2_Chat } from '@components/game/Stage2_Chat'
import { Stage3_Judgment } from '@components/game/Stage3_Judgment'
import { Stage4_Evidence } from '@components/game/Stage4_Evidence'
import { Stage5_Report } from '@components/game/Stage5_Report'
import { Stage6_Result } from '@components/game/Stage6_Result'
import { useGameStore } from '@stores/gameStore'
import type { Stage } from '@/types/game'

/**
 * Wires all 6 already-built stage components into one page, driven by local
 * `viewStage` state. The server's own `stage`/`stageProgression` numbers are
 * an internal, unrelated concept (confirmed empirically: judgment returns
 * stageProgression 1/2, not our 1-6 scale) — so which component renders is
 * a purely client-side router, advanced only by each stage's own
 * `onProceed*`/`onComplete`/`onClaimed` callback, never by comparing to the
 * server's stage number. A page refresh mid-game restarts at Stage 1 as a
 * result — a known, accepted limitation rather than resuming at the wrong
 * screen.
 */
export function GamePage() {
  const { recordId: recordIdParam } = useParams<{ recordId: string }>()
  const recordId = Number(recordIdParam)
  const navigate = useNavigate()
  const location = useLocation()

  // The real backend's chat history never includes the initial SMS (only the
  // POST /scenarios/{stageId}/start response carries it) — Dashboard passes
  // it through router state. If it's missing (e.g. a direct refresh of this
  // URL, which can't recover the original text), skip straight to Stage 2
  // rather than get stuck showing nothing.
  const initialMessage = (location.state as { initialMessage?: string } | null)?.initialMessage ?? null
  const [viewStage, setViewStage] = useState<Stage>(initialMessage ? 1 : 2)

  useEffect(() => {
    useGameStore.getState().start(recordId)
  }, [recordId])

  return (
    <GameLayout stage={viewStage}>
      {viewStage === 1 && initialMessage !== null && (
        <Stage1_SMS message={initialMessage} onContinue={() => setViewStage(2)} />
      )}
      {viewStage === 2 && (
        <Stage2_Chat
          recordId={recordId}
          initialMessage={initialMessage}
          onProceedToJudgment={() => setViewStage(3)}
        />
      )}
      {viewStage === 3 && <Stage3_Judgment recordId={recordId} onProceed={() => setViewStage(4)} />}
      {viewStage === 4 && <Stage4_Evidence recordId={recordId} onProceed={() => setViewStage(5)} />}
      {viewStage === 5 && <Stage5_Report onComplete={() => setViewStage(6)} />}
      {viewStage === 6 && <Stage6_Result recordId={recordId} onClaimed={() => navigate('/home')} />}
    </GameLayout>
  )
}
