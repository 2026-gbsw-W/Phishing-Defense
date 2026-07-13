import { describe, it, expect } from 'vitest'
import { authService } from './authService'

describe('authService', () => {
  it('signs up and returns a session', async () => {
    const session = await authService.signup({ email: 'svc@test.com', password: 'pw123456', nickname: '헌터' })
    expect(session.userId).toBeGreaterThan(0)
    expect(session.token).toMatch(/^mock-jwt\./)
    expect(session.nickname).toBe('헌터')
  })

  it('logs in an existing user', async () => {
    await authService.signup({ email: 'svc2@test.com', password: 'pw123456', nickname: '헌터2' })
    const session = await authService.login({ email: 'svc2@test.com', password: 'pw123456' })
    expect(session.nickname).toBe('헌터2')
  })

  it('throws ApiError on invalid login', async () => {
    await expect(authService.login({ email: 'nobody@test.com', password: 'x' })).rejects.toMatchObject({
      status: 401,
    })
  })

  it('fetches the current user', async () => {
    const session = await authService.signup({ email: 'svc3@test.com', password: 'pw123456', nickname: '헌터3' })
    const { setAuthToken } = await import('./api')
    setAuthToken(session.token)
    const user = await authService.fetchMe()
    expect(user.nickname).toBe('헌터3')
  })
})
