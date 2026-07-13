// Level table anchors are the named levels from docs/PRD.md §12.1.2.
// Between anchors, XP requirement is linearly interpolated (the PRD only
// gives exact totals for 1/5/10/15/20/25/30; intermediate levels are
// described only as "~5,000XP마다"). Past level 30 the PRD states a flat
// +10,000 XP per level with no upper bound ("무한 진행").
export interface LevelInfo {
  level: number
  totalXp: number
  currentLevelXp: number
  xpForNextLevel: number
  progressRatio: number
}

const ANCHORS: { level: number; totalXp: number }[] = [
  { level: 1, totalXp: 0 },
  { level: 5, totalXp: 4000 },
  { level: 10, totalXp: 10000 },
  { level: 15, totalXp: 18000 },
  { level: 20, totalXp: 28000 },
  { level: 25, totalXp: 40000 },
  { level: 30, totalXp: 60000 },
]

const MAX_ANCHOR_LEVEL = 30
const MAX_ANCHOR_XP = 60000
const XP_PER_LEVEL_BEYOND_30 = 10000

function xpRequiredForLevel(level: number): number {
  if (level <= 1) return 0
  if (level >= MAX_ANCHOR_LEVEL) {
    return MAX_ANCHOR_XP + (level - MAX_ANCHOR_LEVEL) * XP_PER_LEVEL_BEYOND_30
  }

  let lower = ANCHORS[0]
  let upper = ANCHORS[ANCHORS.length - 1]
  for (let i = 0; i < ANCHORS.length - 1; i++) {
    if (level >= ANCHORS[i].level && level <= ANCHORS[i + 1].level) {
      lower = ANCHORS[i]
      upper = ANCHORS[i + 1]
      break
    }
  }
  const span = upper.level - lower.level
  const ratio = span === 0 ? 0 : (level - lower.level) / span
  return Math.round(lower.totalXp + ratio * (upper.totalXp - lower.totalXp))
}

export function getLevelInfo(totalXp: number): LevelInfo {
  let level = 1
  // Uncapped: keep climbing past 30 as long as XP supports it.
  while (xpRequiredForLevel(level + 1) <= totalXp) {
    level++
  }

  const currentThreshold = xpRequiredForLevel(level)
  const nextThreshold = xpRequiredForLevel(level + 1)
  const currentLevelXp = totalXp - currentThreshold
  const xpForNextLevel = nextThreshold - currentThreshold
  const progressRatio = xpForNextLevel === 0 ? 0 : currentLevelXp / xpForNextLevel

  return { level, totalXp, currentLevelXp, xpForNextLevel: nextThreshold, progressRatio }
}
