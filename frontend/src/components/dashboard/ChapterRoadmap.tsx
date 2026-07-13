import { Lock } from 'lucide-react'
import type { Chapter } from '@/types/game'

interface ChapterRoadmapProps {
  chapters: Chapter[]
  onPlay: (chapter: Chapter) => void
}

// The real GET /chapters response has no per-user unlock/star-rating data —
// only the first chapter (lowest orderIndex — seeded as 1, not 0) has real
// scenario content wired up end to end right now, so it's the only one
// presented as playable.
function chapterState(chapter: Chapter, firstOrderIndex: number): 'locked' | 'current' {
  return chapter.orderIndex === firstOrderIndex ? 'current' : 'locked'
}

// Hand-tuned wander pattern (fraction of the amplitude) so the path curves
// naturally instead of alternating strictly left/right. Cycles if there are
// more chapters than entries.
const WANDER_PATTERN = [0, 0.8, 0.25, -0.75, -0.2, 0.7, -0.6, 0.3]
const AMPLITUDE = 26 // max +/- % from center
const ROW_HEIGHT = 176
const NODE_SIZE = 80

function nodeCenter(i: number) {
  const x = 50 + WANDER_PATTERN[i % WANDER_PATTERN.length] * AMPLITUDE
  const y = i * ROW_HEIGHT + NODE_SIZE / 2
  return { x, y }
}

/** Smooth Catmull-Rom-through-points curve, converted to cubic beziers. */
function pathFor(points: { x: number; y: number }[]): string {
  if (points.length < 2) return ''
  let d = `M ${points[0].x} ${points[0].y}`
  for (let i = 0; i < points.length - 1; i++) {
    const p0 = points[i - 1] ?? points[i]
    const p1 = points[i]
    const p2 = points[i + 1]
    const p3 = points[i + 2] ?? p2
    const c1x = p1.x + (p2.x - p0.x) / 6
    const c1y = p1.y + (p2.y - p0.y) / 6
    const c2x = p2.x - (p3.x - p1.x) / 6
    const c2y = p2.y - (p3.y - p1.y) / 6
    d += ` C ${c1x} ${c1y}, ${c2x} ${c2y}, ${p2.x} ${p2.y}`
  }
  return d
}

export function ChapterRoadmap({ chapters, onPlay }: ChapterRoadmapProps) {
  const firstOrderIndex = Math.min(...chapters.map((c) => c.orderIndex))
  const points = chapters.map((_, i) => nodeCenter(i))
  const trackHeight = chapters.length * ROW_HEIGHT

  return (
    <div className="roadmap" style={{ height: trackHeight }}>
      <svg
        className="roadmap-path"
        viewBox={`0 0 100 ${trackHeight}`}
        preserveAspectRatio="none"
        aria-hidden="true"
      >
        <path d={pathFor(points)} vectorEffect="non-scaling-stroke" />
      </svg>

      {chapters.map((chapter, i) => {
        const state = chapterState(chapter, firstOrderIndex)
        const { x, y } = points[i]

        return (
          <div
            key={chapter.chapterId}
            className="roadmap-node-group"
            style={{ left: `${x}%`, top: y - NODE_SIZE / 2 }}
          >
            <button
              type="button"
              className={`roadmap-node roadmap-node-${state}`}
              disabled={state === 'locked'}
              onClick={() => onPlay(chapter)}
              aria-label={`Chapter ${chapter.chapterId}: ${chapter.title}`}
            >
              {state === 'locked' && <Lock size={22} />}
              {state === 'current' && <span className="roadmap-node-number mono">{chapter.chapterId}</span>}
              {state === 'current' && <span className="roadmap-node-ring" aria-hidden="true" />}
            </button>

            <div className="roadmap-info">
              <p className="roadmap-title">{chapter.title}</p>
              <p className="roadmap-status">{state === 'locked' ? '잠김' : '미완료'}</p>
              {state === 'current' && (
                <button type="button" className="roadmap-play-pill" onClick={() => onPlay(chapter)}>
                  플레이
                </button>
              )}
            </div>
          </div>
        )
      })}
    </div>
  )
}
