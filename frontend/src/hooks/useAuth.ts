import { useAuthStore } from '@/stores/authStore'

export function useAuth() {
  const session = useAuthStore((s) => s.session)
  const isLoading = useAuthStore((s) => s.isLoading)
  const error = useAuthStore((s) => s.error)
  const login = useAuthStore((s) => s.login)
  const signup = useAuthStore((s) => s.signup)
  const logout = useAuthStore((s) => s.logout)

  return { session, isAuthenticated: session !== null, isLoading, error, login, signup, logout }
}
