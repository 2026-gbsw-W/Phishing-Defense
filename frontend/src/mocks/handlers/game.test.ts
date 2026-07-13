import { describe, it, expect } from 'vitest'

const BASE = 'http://localhost:8080/api/v1'

async function signupAndGetToken(email: string) {
  const res = await fetch(`${BASE}/auth/signup`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password: 'pw123456', nickname: '헌터' }),
  })
  return (await res.json()).token as string
}

describe('game mock handlers', () => {
  it('lists chapters with chapter 1 unlocked', async () => {
    const token = await signupAndGetToken('game1@test.com')
    const res = await fetch(`${BASE}/chapters`, { headers: { Authorization: `Bearer ${token}` } })
    const body = await res.json()
    expect(body[0].chapter_id).toBe(1)
    expect(body[0].is_unlocked).toBe(true)
    expect(body[1].is_unlocked).toBe(false)
  })

  it('lists scenarios for a chapter', async () => {
    const token = await signupAndGetToken('game2@test.com')
    const res = await fetch(`${BASE}/chapters/1/scenarios`, { headers: { Authorization: `Bearer ${token}` } })
    const body = await res.json()
    expect(body[0].scenario_id).toBe(101)
  })

  it('starts a scenario and returns the initial SMS', async () => {
    const token = await signupAndGetToken('game3@test.com')
    const res = await fetch(`${BASE}/scenarios/101/start`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}` },
    })
    expect(res.status).toBe(201)
    const body = await res.json()
    expect(body.record_id).toBeGreaterThan(0)
    expect(body.initial_message).toContain('국민은행')
  })

  it('returns scenario status at stage 1', async () => {
    const token = await signupAndGetToken('game4@test.com')
    const start = await fetch(`${BASE}/scenarios/101/start`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}` },
    })
    const { record_id } = await start.json()

    const res = await fetch(`${BASE}/scenarios/${record_id}/status`, {
      headers: { Authorization: `Bearer ${token}` },
    })
    const body = await res.json()
    expect(body.stage).toBe(1)
    expect(body.hints_remaining).toBe(3)
  })
})
