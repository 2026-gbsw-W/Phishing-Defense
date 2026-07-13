import { Lock, Star } from 'lucide-react'
import type { Chapter } from '@/types/game'

interface ChapterRoadmapProps {
  chapters: Chapter[]
  onPlay: (chapter: Chapter) => void
}

function chapterState(chapter: Chapter, isFirstPlayable: boolean): 'locked' | 'current' | 'completed' | 'unlocked' {
  if (!chapter.isUnlocked) return 'locked'
  if (chapter.isCompleted) return 'completed'
  if (isFirstPlayable) return 'current'
  return 'unlocked'
}

export function ChapterRoadmap({ chapters, onPlay }: ChapterRoadmapProps) {
  const firstPlayableId = chapters.find((c) => c.isUnlocked && !c.isCompleted)?.chapterId

  return (
    <div className="roadmap">
      {chapters.map((chapter, i) => {
        const state = chapterState(chapter, chapter.chapterId === firstPlayableId)
        const side = i % 2 === 0 ? 'side-left' : 'side-right'

        return (
          <div key={chapter.chapterId} className={`roadmap-item ${side}`}>
            <div className="roadmap-node-group">
              <button
                type="button"
                className={`roadmap-node roadmap-node-${state}`}
                disabled={state === 'locked'}
                onClick={() => onPlay(chapter)}
                aria-label={`Chapter ${chapter.chapterId}: ${chapter.title}`}
              >
                {state === 'locked' && <Lock size={22} />}
                {state === 'completed' && <Star size={26} fill="currentColor" strokeWidth={0} />}
                {(state === 'current' || state === 'unlocked') && (
                  <span className="roadmap-node-number mono">{chapter.chapterId}</span>
                )}
                {state === 'current' && <span className="roadmap-node-ring" aria-hidden="true" />}
              </button>

              <div className="roadmap-info">
                <p className="roadmap-title">{chapter.title}</p>
                {state === 'completed' ? (
                  <p className="roadmap-stars mono">{'★'.repeat(chapter.bestStar).padEnd(3, '☆')}</p>
                ) : (
                  <p className="roadmap-status">{state === 'locked' ? '잠김' : '미완료'}</p>
                )}
                {state === 'current' && (
                  <button type="button" className="roadmap-play-pill" onClick={() => onPlay(chapter)}>
                    플레이
                  </button>
                )}
              </div>
            </div>
          </div>
        )
      })}
    </div>
  )
}
