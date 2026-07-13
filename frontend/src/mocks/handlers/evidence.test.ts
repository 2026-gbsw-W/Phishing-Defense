import { describe, it, expect } from 'vitest'
import { mockDb } from '../db'

const BASE = 'http://localhost:8080/api/v1'

async function setup() {
  const signup = await fetch(`${BASE}/auth/signup`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: `evidence${Math.random()}@test.com`, password: 'pw123456', nickname: '헌터' }),
  })
  const { accessToken: token } = await signup.json()
  const start = await fetch(`${BASE}/scenarios/101/start`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${token}` },
  })
  const { record_id } = await start.json()
  return { token, recordId: record_id as number }
}

async function markEvidence(token: string, recordId: number, turn: number, value: string) {
  const res = await fetch(`${BASE}/chat/${recordId}/evidence/mark`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ turn, evidence_value: value }),
  })
  return (await res.json()).evidence_id as number
}

describe('evidence mock handlers', () => {
  describe('GET /scenarios/:recordId/evidence', () => {
    it('lists evidence marked during chat in the wire shape', async () => {
      const { token, recordId } = await setup()
      await markEvidence(token, recordId, 1, '050-1234-5678')
      await markEvidence(token, recordId, 2, '지금 바로 계좌번호를 알려주세요')

      const res = await fetch(`${BASE}/scenarios/${recordId}/evidence`, {
        headers: { Authorization: `Bearer ${token}` },
      })
      const body = await res.json()

      expect(res.status).toBe(200)
      expect(body).toHaveLength(2)
      expect(body[0]).toEqual({
        evidence_id: expect.any(Number),
        type: 'phone_number',
        value: '050-1234-5678',
        turn: 1,
      })
      expect(body[1]).toEqual({
        evidence_id: expect.any(Number),
        type: 'urgency',
        value: '지금 바로 계좌번호를 알려주세요',
        turn: 2,
      })
      // list response must not leak submission/validity fields (those belong to Stage 6 report)
      expect(body[0]).not.toHaveProperty('isSubmitted')
      expect(body[0]).not.toHaveProperty('is_submitted')
      expect(body[0]).not.toHaveProperty('isValid')
      expect(body[0]).not.toHaveProperty('is_valid')
    })

    it('returns an empty list when nothing was marked', async () => {
      const { token, recordId } = await setup()
      const res = await fetch(`${BASE}/scenarios/${recordId}/evidence`, {
        headers: { Authorization: `Bearer ${token}` },
      })
      expect(await res.json()).toEqual([])
    })

    it('returns 401 without auth and 404 for an unknown record', async () => {
      const noAuth = await fetch(`${BASE}/scenarios/1/evidence`)
      expect(noAuth.status).toBe(401)

      const { token } = await setup()
      const notFound = await fetch(`${BASE}/scenarios/999999/evidence`, {
        headers: { Authorization: `Bearer ${token}` },
      })
      expect(notFound.status).toBe(404)
    })
  })

  describe('POST /scenarios/:recordId/evidence/submit', () => {
    it('marks the submitted entries isSubmitted and returns the correct count', async () => {
      const { token, recordId } = await setup()
      const id1 = await markEvidence(token, recordId, 1, '050-1234-5678')
      const id2 = await markEvidence(token, recordId, 2, '지금 바로 계좌번호를 알려주세요')
      await markEvidence(token, recordId, 3, '국민은행 사칭') // left unsubmitted

      const res = await fetch(`${BASE}/scenarios/${recordId}/evidence/submit`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({ evidence_ids: [id1, id2] }),
      })
      const body = await res.json()

      expect(res.status).toBe(200)
      expect(body).toEqual({ submitted_count: 2 })

      const record = mockDb.records.get(recordId)!
      expect(record.evidence.find((e) => e.evidenceId === id1)!.isSubmitted).toBe(true)
      expect(record.evidence.find((e) => e.evidenceId === id2)!.isSubmitted).toBe(true)
      expect(record.evidence.find((e) => e.value === '국민은행 사칭')!.isSubmitted).toBe(false)
    })

    it('silently ignores ids that do not match any evidence', async () => {
      const { token, recordId } = await setup()
      const id1 = await markEvidence(token, recordId, 1, '050-1234-5678')

      const res = await fetch(`${BASE}/scenarios/${recordId}/evidence/submit`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({ evidence_ids: [id1, 999999] }),
      })
      const body = await res.json()

      expect(res.status).toBe(200)
      expect(body).toEqual({ submitted_count: 1 })
      const record = mockDb.records.get(recordId)!
      expect(record.evidence.find((e) => e.evidenceId === id1)!.isSubmitted).toBe(true)
    })

    it('returns 401 without auth and 404 for an unknown record', async () => {
      const noAuth = await fetch(`${BASE}/scenarios/1/evidence/submit`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ evidence_ids: [] }),
      })
      expect(noAuth.status).toBe(401)

      const { token } = await setup()
      const notFound = await fetch(`${BASE}/scenarios/999999/evidence/submit`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({ evidence_ids: [] }),
      })
      expect(notFound.status).toBe(404)
    })
  })
})
