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
})
