import { useNavigate } from 'react-router-dom'
import toast from 'react-hot-toast'
import { useChapters } from '@hooks/useChapters'
import { useAuth } from '@hooks/useAuth'
import { gameService } from '@services/gameService'
import { getLevelInfo } from '@utils/levels'
import { ChapterCard } from './ChapterCard'

export function Dashboard() {
  const { session } = useAuth()
  const { data: chapters, isLoading } = useChapters()
  const navigate = useNavigate()

  const handlePlay = async (scenarioId: number) => {
    try {
      const { recordId } = await gameService.startScenario(scenarioId)
      navigate(`/game/${recordId}`)
    } catch {
      toast.error('시나리오를 시작할 수 없습니다.')
    }
  }

  if (!session) return null
  const levelInfo = getLevelInfo(session.totalXp)

  return (
    <div className="dashboard-page hex-bg">
      <div className="dashboard-wrap">
        <header className="card dashboard-header">
          <p className="dashboard-nickname">{session.nickname}</p>
          <div className="dashboard-level-row">
            <span className="mono">
              Lv.{levelInfo.level} · {levelInfo.currentLevelXp} XP
            </span>
          </div>
          <div className="dashboard-level-bar">
            <div
              className="dashboard-level-bar-fill"
              style={{ width: `${Math.min(levelInfo.progressRatio, 1) * 100}%` }}
            />
          </div>
        </header>

        <section className="dashboard-section">
          <h2 className="dashboard-section-title">📚 Story Progress</h2>
          {isLoading && <p className="dashboard-empty">불러오는 중...</p>}
          {!isLoading && chapters?.length === 0 && (
            <p className="dashboard-empty">아직 챕터가 없습니다.</p>
          )}
          {chapters?.map((chapter) => (
            <ChapterCard
              key={chapter.chapterId}
              chapter={chapter}
              onPlay={() => handlePlay(101 /* Scenario 1-1, hardcoded for the single-scenario MVP */)}
            />
          ))}
        </section>
      </div>
    </div>
  )
}
