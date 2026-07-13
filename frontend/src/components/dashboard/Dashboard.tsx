import { useNavigate, Link } from 'react-router-dom'
import toast from 'react-hot-toast'
import { useChapters } from '@hooks/useChapters'
import { useAuth } from '@hooks/useAuth'
import { gameService } from '@services/gameService'
import { getLevelInfo } from '@utils/levels'
import { ProgressBar } from '@components/common/ProgressBar'
import { ChapterRoadmap } from './ChapterRoadmap'
import type { Chapter } from '@/types/game'

export function Dashboard() {
  const { session } = useAuth()
  const { data: chapters, isLoading } = useChapters()
  const navigate = useNavigate()

  const handlePlay = async (chapter: Chapter) => {
    if (!chapter.isUnlocked) return
    try {
      // Scenario 101 (Chapter 1 / Scenario 1-1) is the only playable scenario in this MVP.
      const { recordId } = await gameService.startScenario(101)
      navigate(`/game/${recordId}`)
    } catch {
      toast.error('시나리오를 시작할 수 없습니다.')
    }
  }

  if (!session) return null
  const levelInfo = getLevelInfo(session.totalXp)

  return (
    <div className="dashboard-page">
      <div className="dashboard-wrap">
        <header className="card dashboard-header">
          <div className="dashboard-header-row">
            <p className="dashboard-nickname">{session.nickname}</p>
            <Link to="/profile" className="dashboard-profile-link">
              내 프로필
            </Link>
          </div>
          <div className="dashboard-level-row">
            <span className="mono">
              Lv.{levelInfo.level}
            </span>
          </div>
          <ProgressBar ratio={levelInfo.progressRatio} label={`${levelInfo.currentLevelXp} XP`} />
        </header>

        <section className="dashboard-section">
          <h2 className="dashboard-section-title">Story Progress</h2>
          {isLoading && <p className="dashboard-empty">불러오는 중...</p>}
          {!isLoading && chapters?.length === 0 && (
            <p className="dashboard-empty">아직 챕터가 없습니다.</p>
          )}
          {chapters && chapters.length > 0 && <ChapterRoadmap chapters={chapters} onPlay={handlePlay} />}
        </section>
      </div>
    </div>
  )
}
