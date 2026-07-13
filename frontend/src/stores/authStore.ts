import { create } from 'zustand'
import { authService } from '@/services/authService'
import type { AuthResult, UserProfile } from '@/services/authService'
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

function buildSession(auth: AuthResult, profile: UserProfile): AuthSession {
  return {
    token: auth.token,
    userId: auth.userId,
    email: auth.email,
    nickname: auth.nickname,
    level: auth.level,
    currentXp: profile.currentXp,
    totalXp: profile.totalXp,
    bio: profile.bio,
    profileImageUrl: profile.profileImageUrl,
  }
}

/** signup/login share this: exchange credentials for a token, then fetch the full profile. */
async function authenticate(request: () => Promise<AuthResult>): Promise<AuthSession> {
  const auth = await request()
  setAuthToken(auth.token)
  try {
    const profile = await authService.fetchMe()
    return buildSession(auth, profile)
  } catch (err) {
    setAuthToken(null)
    throw err
  }
}

export const useAuthStore = create<AuthState>((set, get) => ({
  session: null,
  isLoading: false,
  error: null,

  async signup(payload) {
    set({ isLoading: true, error: null })
    try {
      const session = await authenticate(() => authService.signup(payload))
      localStorage.setItem(TOKEN_KEY, session.token)
      set({ session, isLoading: false })
    } catch (err) {
      set({ isLoading: false, error: err instanceof ApiError ? err.message : '회원가입에 실패했습니다.' })
    }
  },

  async login(payload) {
    set({ isLoading: true, error: null })
    try {
      const session = await authenticate(() => authService.login(payload))
      localStorage.setItem(TOKEN_KEY, session.token)
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
      const profile = await authService.fetchMe()
      set({
        session: {
          token,
          userId: profile.userId,
          email: profile.email,
          nickname: profile.nickname,
          level: profile.level,
          currentXp: profile.currentXp,
          totalXp: profile.totalXp,
          bio: profile.bio,
          profileImageUrl: profile.profileImageUrl,
        },
      })
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
