import { Lock } from 'lucide-react'
import type { Chapter } from '@/types/game'

interface ChapterCardProps {
  chapter: Chapter
  onPlay: () => void
}

export function ChapterCard({ chapter, onPlay }: ChapterCardProps) {
  return (
    <div className="card chapter-card">
      <div>
        <p className="chapter-card-title">
          Chapter {chapter.chapterId}: {chapter.title}
        </p>
        <p className="chapter-card-meta mono">
          {chapter.isCompleted ? '★'.repeat(chapter.bestStar).padEnd(3, '☆') : '미완료'}
        </p>
      </div>
      {chapter.isUnlocked ? (
        <button onClick={onPlay} className="chapter-card-play">
          플레이
        </button>
      ) : (
        <span className="chapter-card-locked">
          <Lock size={20} />
        </span>
      )}
    </div>
  )
}
