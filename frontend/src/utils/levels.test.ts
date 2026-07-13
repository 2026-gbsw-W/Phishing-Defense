import { describe, it, expect } from 'vitest'
import { getLevelInfo } from './levels'

describe('getLevelInfo', () => {
  it('returns level 1 at 0 xp', () => {
    const info = getLevelInfo(0)
    expect(info.level).toBe(1)
    expect(info.progressRatio).toBe(0)
  })

  it('returns level 5 exactly at its threshold', () => {
    expect(getLevelInfo(4000).level).toBe(5)
  })

  it('interpolates per-level thresholds between named anchors', () => {
    // Lv2 sits 1/4 of the way from Lv1(0) to Lv5(4000) => 1000 XP.
    // Lv3 sits 2/4 of the way => 2000 XP.
    const info = getLevelInfo(1500)
    expect(info.level).toBe(2)
    expect(info.xpForNextLevel).toBe(2000)
    expect(info.progressRatio).toBeCloseTo(0.5, 2)
  })

  it('returns level 30 exactly at its threshold', () => {
    expect(getLevelInfo(60000).level).toBe(30)
  })

  it('keeps progressing past level 30 at +10,000 XP per level', () => {
    expect(getLevelInfo(70000).level).toBe(31)
    expect(getLevelInfo(80000).level).toBe(32)
    expect(getLevelInfo(65000).level).toBe(30)
  })
})
