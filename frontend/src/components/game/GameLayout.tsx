import type { ReactNode } from 'react'
import { useNavigate } from 'react-router-dom'
import { ArrowLeft } from 'lucide-react'
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
    <div className="game-layout-container">
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
    </div>
  )
}
