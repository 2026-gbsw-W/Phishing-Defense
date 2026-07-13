import { describe, it, expect, beforeEach } from 'vitest'
import { render, screen } from '@testing-library/react'
import App from './App'
import { mockDb, tokenForUser } from '@mocks/db'
import { setAuthToken } from '@services/api'
import { useAuthStore } from '@stores/authStore'

describe('App root route', () => {
  beforeEach(() => {
    useAuthStore.setState({ session: null, isLoading: false, error: null })
    localStorage.removeItem('auth_token')
    window.history.pushState({}, '', '/')
  })

  it('renders the landing page for an unauthenticated visitor at "/"', async () => {
    render(<App />)
    expect(await screen.findByText(/AI가 실제 사기꾼처럼/)).toBeInTheDocument()
  })

  it('redirects an authenticated visitor at "/" to the dashboard', async () => {
    const user = mockDb.createUser('root-route@test.com', 'pw123456', '헌터')
    setAuthToken(tokenForUser(user.userId))
    useAuthStore.setState({
      session: {
        token: tokenForUser(user.userId),
        userId: user.userId,
        email: user.email,
        nickname: user.nickname,
        level: 1,
        currentXp: 0,
        totalXp: 0,
        bio: null,
        profileImageUrl: null,
      },
    })

    render(<App />)

    expect(await screen.findByText('Story Progress')).toBeInTheDocument()
    expect(window.location.pathname).toBe('/home')
  })
})
