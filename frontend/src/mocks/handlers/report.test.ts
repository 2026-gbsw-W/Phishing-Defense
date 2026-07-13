import { describe, it, expect } from 'vitest'
import { mockDb } from '../db'

const BASE = 'http://localhost:8080/api/v1'

async function signupAndGetToken(email: string) {
  const res = await fetch(`${BASE}/auth/signup`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password: 'pw123456', nickname: '헌터' }),
  })
  return (await res.json()).token as string
}

async function markEvidence(token: string, recordId: number, turn: number, value: string) {
  const res = await fetch(`${BASE}/chat/${recordId}/evidence/mark`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ turn, evidence_value: value }),
  })
  return (await res.json()).evidence_id as number
}

async function submitEvidence(token: string, recordId: number, evidenceIds: number[]) {
  await fetch(`${BASE}/scenarios/${recordId}/evidence/submit`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ evidence_ids: evidenceIds }),
  })
}

/**
 * Sets up a record that has walked through the full Stage 2-5 flow: two
 * evidence items that DO match GROUND_TRUTH_EVIDENCE (a phone number
 * embedded in a longer marked message, and an exact URL match), one that
 * does NOT match anything, and several ground-truth items (including
 * high-importance ones) left entirely unmatched. Judgment/police-chat state
 * is set directly on the mockDb record, mirroring the Stage3/4/5 test
 * convention for state no HTTP endpoint yet drives end-to-end.
 */
async function setupScoredRecord(email: string) {
  const token = await signupAndGetToken(email)
  const start = await fetch(`${BASE}/scenarios/101/start`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${token}` },
  })
  const { record_id: recordId } = await start.json()

  const phoneId = await markEvidence(token, recordId, 1, '저는 발신 번호 050-1234-5678로 연락드리고 있고요')
  const urlId = await markEvidence(token, recordId, 1, 'bit.ly/2xK9fZ')
  const irrelevantId = await markEvidence(token, recordId, 2, '오늘 날씨가 참 좋네요')
  await submitEvidence(token, recordId, [phoneId, urlId, irrelevantId])

  const record = mockDb.records.get(recordId)!
  record.judgmentCorrect = true
  record.judgmentTurn = 2
  record.wrongJudgmentAttempts = 0
  record.policeTurnsCompleted = 2
  record.hintsUsed = 0
  record.stage = 6

  return { token, recordId: recordId as number, phoneId, urlId, irrelevantId }
}

describe('report mock handlers', () => {
  describe('GET /scenarios/:recordId/report', () => {
    it('computes verdicts, score, and star rating from submitted evidence', async () => {
      const { token, recordId, phoneId, urlId, irrelevantId } = await setupScoredRecord('report1@test.com')

      const res = await fetch(`${BASE}/scenarios/${recordId}/report`, {
        headers: { Authorization: `Bearer ${token}` },
      })
      expect(res.status).toBe(200)
      const body = await res.json()

      // Matching evidence (phone number substring, exact URL) is valid;
      // the irrelevant marked text is not.
      const verdictsById = new Map(body.evidence_analysis.verdicts.map((v: { evidence_id: number }) => [v.evidence_id, v]))
      expect((verdictsById.get(phoneId) as { is_valid: boolean }).is_valid).toBe(true)
      expect((verdictsById.get(urlId) as { is_valid: boolean }).is_valid).toBe(true)
      expect((verdictsById.get(irrelevantId) as { is_valid: boolean }).is_valid).toBe(false)
      expect((verdictsById.get(irrelevantId) as { reason: string }).reason.length).toBeGreaterThan(0)

      expect(body.evidence_analysis.submitted_count).toBe(3)
      expect(body.evidence_analysis.valid_count).toBe(2)

      // 4 ground-truth items were never matched by any submitted evidence.
      expect(body.evidence_analysis.missed_evidence).toHaveLength(4)
      expect(body.evidence_analysis.missed_evidence).toEqual(
        expect.arrayContaining(['국민은행 사칭', '주민등록번호 뒷자리 요구', '계좌번호와 비밀번호 요구', '지금 바로']),
      )

      // judgmentTurn=2 (<=2, no wrong attempts) -> 30 + wisdom 20 = 50 accuracy;
      // evidence pct = round(2/3*100) = 67 with 3 missed core items -> 10;
      // reportQuality 'excellent' (2 police turns) -> 20; hints 0 -> 10.
      // total = 50 + 10 + 20 + 10 = 90 -> 3 stars.
      expect(body.accuracy_score).toBe(90)
      expect(body.star_rating).toBe(3)
      expect(body.accuracy_score).toBeGreaterThanOrEqual(0)
      expect(body.accuracy_score).toBeLessThanOrEqual(100)
      expect([0, 1, 2, 3]).toContain(body.star_rating)

      // base 150 + starBonus 70 + hintsBonus 20 + evidenceBonus 0 + reportBonus 50
      // - (wrongEvidencePenalty 5*1) = 285.
      expect(body.xp_earned).toBe(285)

      expect(typeof body.detailed_feedback).toBe('string')
      expect(body.detailed_feedback.length).toBeGreaterThan(0)
      // Mentions the missed high-importance evidence by name per the PRD tone.
      expect(body.detailed_feedback).toContain('국민은행 사칭')
      expect(Array.isArray(body.recommendations)).toBe(true)
      expect(body.recommendations.length).toBeGreaterThan(0)
    })

    it('treats evidence marked and never submitted as absent from verdicts', async () => {
      const token = await signupAndGetToken('report2@test.com')
      const start = await fetch(`${BASE}/scenarios/101/start`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}` },
      })
      const { record_id: recordId } = await start.json()
      await markEvidence(token, recordId, 1, '050-1234-5678') // marked, never submitted

      const res = await fetch(`${BASE}/scenarios/${recordId}/report`, {
        headers: { Authorization: `Bearer ${token}` },
      })
      const body = await res.json()
      expect(body.evidence_analysis.submitted_count).toBe(0)
      expect(body.evidence_analysis.verdicts).toEqual([])
      // Never-submitted evidence doesn't count as a match for missed evidence either.
      expect(body.evidence_analysis.missed_evidence).toContain('050-1234-5678')
    })

    it('returns 401 without auth and 404 for an unknown record', async () => {
      const noAuth = await fetch(`${BASE}/scenarios/1/report`)
      expect(noAuth.status).toBe(401)

      const token = await signupAndGetToken('report3@test.com')
      const notFound = await fetch(`${BASE}/scenarios/999999/report`, {
        headers: { Authorization: `Bearer ${token}` },
      })
      expect(notFound.status).toBe(404)
    })
  })

  describe('POST /scenarios/:recordId/report/claim', () => {
    it('adds xp_earned to the user total and reports level_up correctly', async () => {
      const { token, recordId } = await setupScoredRecord('report4@test.com')
      const record = mockDb.records.get(recordId)!
      const userBefore = mockDb.users.get(record.userId)!
      expect(userBefore.totalXp).toBe(0)

      const res = await fetch(`${BASE}/scenarios/${recordId}/report/claim`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({}),
      })
      expect(res.status).toBe(200)
      const body = await res.json()

      expect(body.xp_added).toBe(285)
      expect(body.new_total_xp).toBe(285)
      expect(body.level_up).toBe(false) // 285 XP stays within level 1's threshold

      const userAfter = mockDb.users.get(record.userId)!
      expect(userAfter.totalXp).toBe(285)
      expect(mockDb.records.get(recordId)!.claimed).toBe(true)
    })

    it('returns 400 on a second claim attempt and does not double-award xp', async () => {
      const { token, recordId } = await setupScoredRecord('report5@test.com')
      const record = mockDb.records.get(recordId)!

      await fetch(`${BASE}/scenarios/${recordId}/report/claim`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({}),
      })
      const totalAfterFirstClaim = mockDb.users.get(record.userId)!.totalXp

      const res = await fetch(`${BASE}/scenarios/${recordId}/report/claim`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({}),
      })
      expect(res.status).toBe(400)
      const body = await res.json()
      expect(body.message).toBeTruthy()
      expect(mockDb.users.get(record.userId)!.totalXp).toBe(totalAfterFirstClaim)
    })

    it('returns 401 without auth and 404 for an unknown record', async () => {
      const noAuth = await fetch(`${BASE}/scenarios/1/report/claim`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({}),
      })
      expect(noAuth.status).toBe(401)

      const token = await signupAndGetToken('report6@test.com')
      const notFound = await fetch(`${BASE}/scenarios/999999/report/claim`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({}),
      })
      expect(notFound.status).toBe(404)
    })
  })
})
