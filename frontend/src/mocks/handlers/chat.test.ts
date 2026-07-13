import { describe, it, expect } from 'vitest'

const BASE = 'http://localhost:8080/api/v1'

async function setup() {
  const signup = await fetch(`${BASE}/auth/signup`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: `chat${Math.random()}@test.com`, password: 'pw123456', nickname: '헌터' }),
  })
  const { token } = await signup.json()
  const start = await fetch(`${BASE}/scenarios/101/start`, { method: 'POST', headers: { Authorization: `Bearer ${token}` } })
  const { record_id } = await start.json()
  return { token, recordId: record_id as number }
}

describe('chat mock handlers', () => {
  it('sends a message and gets a scripted criminal reply', async () => {
    const { token, recordId } = await setup()
    const res = await fetch(`${BASE}/chat/${recordId}/send`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: '누구세요?', stage: 2 }),
    })
    const body = await res.json()
    expect(body.turn).toBe(1)
    expect(body.ai_response).toContain('본인 확인')
    expect(body.hint_available).toBe(true)
    expect(body).not.toHaveProperty('extracted_evidence')
    expect(body).not.toHaveProperty('stage_complete')
  })

  it('returns full chat history including the initial SMS', async () => {
    const { token, recordId } = await setup()
    await fetch(`${BASE}/chat/${recordId}/send`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: '누구세요?', stage: 2 }),
    })
    const res = await fetch(`${BASE}/chat/${recordId}/history`, { headers: { Authorization: `Bearer ${token}` } })
    const body = await res.json()
    expect(body.length).toBe(3) // initial SMS + 1 user message + 1 AI response = 3 messages
    expect(body[0].stage).toBe(1) // initial SMS is seeded before Stage 2 chat starts
    expect(body[1].stage).toBe(2)
    expect(body[2].stage).toBe(2)
  })

  it('gives a hint and decrements remaining hints', async () => {
    const { token, recordId } = await setup()
    const res = await fetch(`${BASE}/chat/${recordId}/hint`, { method: 'POST', headers: { Authorization: `Bearer ${token}` } })
    const body = await res.json()
    expect(body.remaining_hints).toBe(2)
    expect(body.hint_text.length).toBeGreaterThan(0)
  })

  describe('evidence/mark', () => {
    it('marks a phone-number-shaped value as phone_number', async () => {
      const { token, recordId } = await setup()
      const res = await fetch(`${BASE}/chat/${recordId}/evidence/mark`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({ turn: 1, evidence_value: '050-1234-5678' }),
      })
      const body = await res.json()
      expect(res.status).toBe(201)
      expect(body.evidence_type_guess).toBe('phone_number')
      expect(body.saved).toBe(true)
      expect(typeof body.evidence_id).toBe('number')
    })

    it('marks a value containing an urgency keyword as urgency', async () => {
      const { token, recordId } = await setup()
      const res = await fetch(`${BASE}/chat/${recordId}/evidence/mark`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({ turn: 2, evidence_value: '지금 바로 계좌번호를 알려주세요' }),
      })
      const body = await res.json()
      expect(body.evidence_type_guess).toBe('urgency')
    })

    it('marks a generic value as etc', async () => {
      const { token, recordId } = await setup()
      const res = await fetch(`${BASE}/chat/${recordId}/evidence/mark`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({ turn: 1, evidence_value: '국민은행 사칭' }),
      })
      const body = await res.json()
      expect(body.evidence_type_guess).toBe('etc')
    })

    it('returns 401 without auth', async () => {
      const { recordId } = await setup()
      const res = await fetch(`${BASE}/chat/${recordId}/evidence/mark`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ turn: 1, evidence_value: 'x' }),
      })
      expect(res.status).toBe(401)
    })

    it('returns 404 for a non-existent record', async () => {
      const { token } = await setup()
      const res = await fetch(`${BASE}/chat/999999/evidence/mark`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({ turn: 1, evidence_value: 'x' }),
      })
      expect(res.status).toBe(404)
    })
  })
})
