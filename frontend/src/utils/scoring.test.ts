import { describe, it, expect } from 'vitest'
import { computeScenarioScore, computeXpBreakdown } from './scoring'

describe('computeScenarioScore', () => {
  it('awards top marks for a fast, correct, fully-evidenced, no-hint run', () => {
    const result = computeScenarioScore({
      judgmentTurn: 2,
      wrongJudgmentAttempts: 0,
      responseWisdomScore: 20,
      evidenceValidPercentage: 100,
      missedCoreEvidenceCount: 0,
      reportQuality: 'excellent',
      hintsUsed: 0,
    })
    expect(result.accuracy).toBe(50) // 30 (judgment) + 20 (wisdom)
    expect(result.evidence).toBe(20)
    expect(result.report).toBe(20)
    expect(result.hints).toBe(10)
    expect(result.total).toBe(100)
    expect(result.starRating).toBe(3)
  })

  it('awards bronze for a slow run with mistakes', () => {
    const result = computeScenarioScore({
      judgmentTurn: 6,
      wrongJudgmentAttempts: 1,
      responseWisdomScore: 15,
      evidenceValidPercentage: 65,
      missedCoreEvidenceCount: 2,
      reportQuality: 'basic',
      hintsUsed: 3,
    })
    // accuracy: 15 (wrongAttempts===1 overrides turn count) + 15 (wisdom) = 30
    expect(result.accuracy).toBe(30)
    expect(result.evidence).toBe(10)
    expect(result.report).toBe(10)
    expect(result.hints).toBe(4)
    expect(result.total).toBe(30 + 10 + 10 + 4)
    expect(result.starRating).toBe(0)
  })

  it('drops to the lowest accuracy tier after 2+ wrong judgment attempts', () => {
    const result = computeScenarioScore({
      judgmentTurn: 1,
      wrongJudgmentAttempts: 2,
      responseWisdomScore: 20,
      evidenceValidPercentage: 100,
      missedCoreEvidenceCount: 0,
      reportQuality: 'excellent',
      hintsUsed: 0,
    })
    expect(result.accuracy).toBe(30) // 10 (2+ wrong) + 20 (wisdom)
  })
})

describe('computeXpBreakdown', () => {
  it('sums base, star, and completion bonuses for a perfect run', () => {
    const xp = computeXpBreakdown({
      starRating: 3,
      hintsUsed: 0,
      evidenceValidPercentage: 100,
      missedCoreEvidenceCount: 0,
      reportQuality: 'excellent',
      wrongEvidenceSubmittedCount: 0,
    })
    expect(xp.base).toBe(150)
    expect(xp.starBonus).toBe(70)
    expect(xp.hintsBonus).toBe(20)
    expect(xp.evidenceBonus).toBe(40)
    expect(xp.reportBonus).toBe(50)
    expect(xp.penalty).toBe(0)
    expect(xp.total).toBe(150 + 70 + 20 + 40 + 50)
  })

  it('applies penalties for hints used and wrong evidence submissions', () => {
    const xp = computeXpBreakdown({
      starRating: 0,
      hintsUsed: 3,
      evidenceValidPercentage: 50,
      missedCoreEvidenceCount: 1,
      reportQuality: 'poor',
      wrongEvidenceSubmittedCount: 2,
    })
    expect(xp.hintsBonus).toBe(0)
    expect(xp.evidenceBonus).toBe(0)
    expect(xp.reportBonus).toBe(0)
    // penalty: hints 3*-5=-15, wrong evidence 2*-5=-10, report incomplete -20
    expect(xp.penalty).toBe(45)
    expect(xp.total).toBe(150 + 0 - 45)
  })
})
