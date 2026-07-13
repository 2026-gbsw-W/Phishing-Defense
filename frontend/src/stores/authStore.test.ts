import { describe, it, expect, beforeEach } from 'vitest'
import { useAuthStore } from './authStore'

describe('authStore', () => {
  beforeEach(() => {
    useAuthStore.setState({ session: null, isLoading: false, error: null })
    localStorage.removeItem('auth_token')
  })

  it('starts logged out', () => {
    expect(useAuthStore.getState().session).toBeNull()
  })

  it('signs up and persists the session in state + localStorage', async () => {
    await useAuthStore.getState().signup({ email: 'store@test.com', password: 'pw123456', nickname: '헌터' })
    expect(useAuthStore.getState().session?.nickname).toBe('헌터')
    expect(localStorage.getItem('auth_token')).toMatch(/^mock-jwt\./)
  })

  it('logs out by clearing the session and localStorage', async () => {
    await useAuthStore.getState().signup({ email: 'store2@test.com', password: 'pw123456', nickname: '헌터' })
    useAuthStore.getState().logout()
    expect(useAuthStore.getState().session).toBeNull()
    expect(localStorage.getItem('auth_token')).toBeNull()
  })

  it('sets an error message on failed login instead of throwing', async () => {
    await useAuthStore.getState().login({ email: 'nobody@test.com', password: 'x' })
    expect(useAuthStore.getState().session).toBeNull()
    expect(useAuthStore.getState().error).toBeTruthy()
  })

  it('updateXp updates totalXp and level via getLevelInfo', async () => {
    await useAuthStore.getState().signup({ email: 'store3@test.com', password: 'pw123456', nickname: '헌터' })
    useAuthStore.getState().updateXp(4000)
    expect(useAuthStore.getState().session?.totalXp).toBe(4000)
    expect(useAuthStore.getState().session?.level).toBe(5)
  })

  it('hydrate restores the session from a persisted token', async () => {
    await useAuthStore.getState().signup({ email: 'store4@test.com', password: 'pw123456', nickname: '헌터' })
    const token = localStorage.getItem('auth_token')
    useAuthStore.setState({ session: null })
    expect(useAuthStore.getState().session).toBeNull()

    await useAuthStore.getState().hydrate()

    expect(useAuthStore.getState().session?.nickname).toBe('헌터')
    expect(localStorage.getItem('auth_token')).toBe(token)
  })

  it('hydrate clears the token when the persisted session is no longer valid', async () => {
    localStorage.setItem('auth_token', 'mock-jwt.999999')

    await useAuthStore.getState().hydrate()

    expect(useAuthStore.getState().session).toBeNull()
    expect(localStorage.getItem('auth_token')).toBeNull()
  })

  it('hydrate is a no-op when there is no persisted token', async () => {
    await useAuthStore.getState().hydrate()
    expect(useAuthStore.getState().session).toBeNull()
  })

  it('setProfile merges partial profile fields into the current session', async () => {
    await useAuthStore.getState().signup({ email: 'store5@test.com', password: 'pw123456', nickname: '헌터' })

    useAuthStore.getState().setProfile({ nickname: '새헌터', bio: '안녕하세요' })

    expect(useAuthStore.getState().session?.nickname).toBe('새헌터')
    expect(useAuthStore.getState().session?.bio).toBe('안녕하세요')
    // Unrelated fields are preserved, not wiped out by the partial update.
    expect(useAuthStore.getState().session?.email).toBe('store5@test.com')
  })

  it('setProfile is a no-op when there is no session', () => {
    useAuthStore.getState().setProfile({ nickname: '무시됨' })
    expect(useAuthStore.getState().session).toBeNull()
  })
})
