import type { ReactNode } from 'react'
import { useNavigate } from 'react-router-dom'
import { ArrowLeft, Signal, Wifi, BatteryFull } from 'lucide-react'
import type { Stage } from '@/types/game'
import { ProgressBar } from '@components/common/ProgressBar'

const STAGE_LABELS: Record<Stage, string> = {
  1: 'SMS 수신',
  2: 'AI 채팅',
  3: '피싱 판단',
  4: '증거 수집',
  5: '신고',
  6: '결과',
}

interface GameLayoutProps {
  stage: Stage
  children: ReactNode
}

export function GameLayout({ stage, children }: GameLayoutProps) {
  const navigate = useNavigate()
  return (
    <div className="game-layout-page">
      <div className="game-layout-glow game-layout-glow-1" aria-hidden="true" />
      <div className="game-layout-glow game-layout-glow-2" aria-hidden="true" />

      <div className="game-layout-phone">
        <div className="game-layout-screen">
          <div className="game-layout-statusbar mono" aria-hidden="true">
            <span>9:41</span>
            <span className="game-layout-statusbar-icons">
              <Signal size={13} />
              <Wifi size={13} />
              <BatteryFull size={15} />
            </span>
          </div>
          <div className="game-layout-island" aria-hidden="true">
            <span className="game-layout-island-cam" />
          </div>

          <header className="game-layout-header">
            <button onClick={() => navigate('/')} aria-label="뒤로가기" className="game-layout-back-btn">
              <ArrowLeft size={20} />
            </button>
            <div className="game-layout-header-content">
              <p className="game-layout-title">Chapter 1 - {STAGE_LABELS[stage]}</p>
              <ProgressBar ratio={stage / 6} />
            </div>
          </header>

          <main className="game-layout-main">{children}</main>
          <div className="game-layout-screen-sheen" aria-hidden="true" />
        </div>
        <div className="game-layout-home-indicator" aria-hidden="true" />
      </div>
    </div>
  )
}
