import { describe, it, expect } from 'vitest'

const BASE = 'http://localhost:8080/api/v1'

describe('auth mock handlers', () => {
  it('signs up a new user', async () => {
    const res = await fetch(`${BASE}/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'a@test.com', password: 'pw123456', nickname: '피싱헌터' }),
    })
    expect(res.status).toBe(201)
    const body = await res.json()
    expect(body.token).toMatch(/^mock-jwt\./)
    expect(body.nickname).toBe('피싱헌터')
  })

  it('rejects duplicate signup email', async () => {
    await fetch(`${BASE}/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'dup@test.com', password: 'pw123456', nickname: 'A' }),
    })
    const res = await fetch(`${BASE}/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'dup@test.com', password: 'pw123456', nickname: 'B' }),
    })
    expect(res.status).toBe(409)
  })

  it('logs in with correct credentials and rejects wrong password', async () => {
    await fetch(`${BASE}/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'login@test.com', password: 'correct1', nickname: 'A' }),
    })

    const ok = await fetch(`${BASE}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'login@test.com', password: 'correct1' }),
    })
    expect(ok.status).toBe(200)

    const bad = await fetch(`${BASE}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'login@test.com', password: 'wrong' }),
    })
    expect(bad.status).toBe(401)
  })

  it('fetches the current user with a valid token', async () => {
    const signup = await fetch(`${BASE}/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'me@test.com', password: 'pw123456', nickname: '헌터' }),
    })
    const { token } = await signup.json()

    const res = await fetch(`${BASE}/users/me`, {
      headers: { Authorization: `Bearer ${token}` },
    })
    expect(res.status).toBe(200)
    const body = await res.json()
    expect(body.nickname).toBe('헌터')
  })

  it('rejects /users/me without a valid token', async () => {
    const res = await fetch(`${BASE}/users/me`, {
      headers: { Authorization: 'Bearer garbage' },
    })
    expect(res.status).toBe(401)
  })
})
