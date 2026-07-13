import { describe, it, expect } from 'vitest'
import { mockDb } from '../db'

const BASE = 'http://localhost:8080/api/v1'

async function signupAndGetToken(email: string) {
  const res = await fetch(`${BASE}/auth/signup`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password: 'pw123456', nickname: '헌터' }),
  })
  return (await res.json()).accessToken as string
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

  it('judges correctly on the first try and advances to stage 4', async () => {
    const token = await signupAndGetToken('judge1@test.com')
    const start = await fetch(`${BASE}/scenarios/101/start`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}` },
    })
    const { record_id } = await start.json()
    mockDb.records.get(record_id)!.stage = 3

    const res = await fetch(`${BASE}/scenarios/${record_id}/judgment`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ is_phishing: true }),
    })
    const body = await res.json()
    expect(body.is_correct).toBe(true)
    expect(body.stage_progression).toBe(4)

    const status = await fetch(`${BASE}/scenarios/${record_id}/status`, {
      headers: { Authorization: `Bearer ${token}` },
    })
    expect((await status.json()).stage).toBe(4)
  })

  it('on first wrong judgment, returns is_correct false and keeps the record at stage 3', async () => {
    const token = await signupAndGetToken('judge2@test.com')
    const start = await fetch(`${BASE}/scenarios/101/start`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}` },
    })
    const { record_id } = await start.json()
    mockDb.records.get(record_id)!.stage = 3

    const res = await fetch(`${BASE}/scenarios/${record_id}/judgment`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ is_phishing: false }),
    })
    const body = await res.json()
    expect(body.is_correct).toBe(false)
    expect(body.stage_progression).toBe(3)
    expect(body.wrong_attempts).toBe(1)

    const status = await fetch(`${BASE}/scenarios/${record_id}/status`, {
      headers: { Authorization: `Bearer ${token}` },
    })
    expect((await status.json()).stage).toBe(3)
  })

  it('forces progression to stage 4 on the second wrong judgment', async () => {
    const token = await signupAndGetToken('judge3@test.com')
    const start = await fetch(`${BASE}/scenarios/101/start`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}` },
    })
    const { record_id } = await start.json()
    mockDb.records.get(record_id)!.stage = 3

    await fetch(`${BASE}/scenarios/${record_id}/judgment`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ is_phishing: false }),
    })

    const res = await fetch(`${BASE}/scenarios/${record_id}/judgment`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ is_phishing: false }),
    })
    const body = await res.json()
    expect(body.is_correct).toBe(false)
    expect(body.stage_progression).toBe(4)
    expect(body.wrong_attempts).toBe(2)

    const status = await fetch(`${BASE}/scenarios/${record_id}/status`, {
      headers: { Authorization: `Bearer ${token}` },
    })
    expect((await status.json()).stage).toBe(4)
  })

  it('returns 401 for judgment without auth and 404 for unknown record', async () => {
    const noAuth = await fetch(`${BASE}/scenarios/1/judgment`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ is_phishing: true }),
    })
    expect(noAuth.status).toBe(401)

    const token = await signupAndGetToken('judge4@test.com')
    const notFound = await fetch(`${BASE}/scenarios/999999/judgment`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ is_phishing: true }),
    })
    expect(notFound.status).toBe(404)
  })
})
