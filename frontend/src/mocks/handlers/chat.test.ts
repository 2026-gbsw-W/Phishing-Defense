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
  it('sends a message and gets a scripted criminal reply with extracted evidence', async () => {
    const { token, recordId } = await setup()
    const res = await fetch(`${BASE}/chat/${recordId}/send`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: '누구세요?', stage: 2 }),
    })
    const body = await res.json()
    expect(body.turn).toBe(1)
    expect(body.ai_response).toContain('본인 확인')
    expect(body.extracted_evidence.length).toBeGreaterThan(0)
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
  })

  it('gives a hint and decrements remaining hints', async () => {
    const { token, recordId } = await setup()
    const res = await fetch(`${BASE}/chat/${recordId}/hint`, { method: 'POST', headers: { Authorization: `Bearer ${token}` } })
    const body = await res.json()
    expect(body.hints_remaining).toBe(2)
    expect(body.hint_text.length).toBeGreaterThan(0)
  })
})
