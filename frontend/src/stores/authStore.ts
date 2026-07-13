import { create } from 'zustand'
import { authService } from '@/services/authService'
import { setAuthToken } from '@/services/api'
import { getLevelInfo } from '@/utils/levels'
import { ApiError } from '@/types/api'
import type { AuthSession, LoginPayload, SignupPayload } from '@/types/auth'

const TOKEN_KEY = 'auth_token'

interface AuthState {
  session: AuthSession | null
  isLoading: boolean
  error: string | null
  signup: (payload: SignupPayload) => Promise<void>
  login: (payload: LoginPayload) => Promise<void>
  logout: () => void
  hydrate: () => Promise<void>
  updateXp: (newTotalXp: number) => void
}

function persistSession(session: AuthSession) {
  setAuthToken(session.token)
  localStorage.setItem(TOKEN_KEY, session.token)
}

export const useAuthStore = create<AuthState>((set, get) => ({
  session: null,
  isLoading: false,
  error: null,

  async signup(payload) {
    set({ isLoading: true, error: null })
    try {
      const session = await authService.signup(payload)
      persistSession(session)
      set({ session, isLoading: false })
    } catch (err) {
      set({ isLoading: false, error: err instanceof ApiError ? err.message : '회원가입에 실패했습니다.' })
    }
  },

  async login(payload) {
    set({ isLoading: true, error: null })
    try {
      const session = await authService.login(payload)
      persistSession(session)
      set({ session, isLoading: false })
    } catch (err) {
      set({ isLoading: false, error: err instanceof ApiError ? err.message : '로그인에 실패했습니다.' })
    }
  },

  logout() {
    setAuthToken(null)
    localStorage.removeItem(TOKEN_KEY)
    set({ session: null, error: null })
  },

  async hydrate() {
    const token = localStorage.getItem(TOKEN_KEY)
    if (!token) return
    setAuthToken(token)
    try {
      const user = await authService.fetchMe()
      set({ session: { token, userId: user.userId, nickname: user.nickname, level: user.level, totalXp: user.totalXp } })
    } catch {
      setAuthToken(null)
      localStorage.removeItem(TOKEN_KEY)
    }
  },

  updateXp(newTotalXp) {
    const session = get().session
    if (!session) return
    const { level } = getLevelInfo(newTotalXp)
    set({ session: { ...session, totalXp: newTotalXp, level } })
  },
}))
