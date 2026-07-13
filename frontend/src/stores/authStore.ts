import { create } from 'zustand'
import { authService } from '@/services/authService'
import type { AuthResult, UserProfile } from '@/services/authService'
import { setAuthToken, setRefreshToken, setTokenRefreshHandlers } from '@/services/api'
import { getLevelInfo } from '@/utils/levels'
import { ApiError } from '@/types/api'
import type { AuthSession, LoginPayload, SignupPayload } from '@/types/auth'

const TOKEN_KEY = 'auth_token'
const REFRESH_TOKEN_KEY = 'auth_refresh_token'

interface AuthState {
  session: AuthSession | null
  isLoading: boolean
  error: string | null
  signup: (payload: SignupPayload) => Promise<void>
  login: (payload: LoginPayload) => Promise<void>
  logout: () => void
  hydrate: () => Promise<void>
  updateXp: (newTotalXp: number) => void
  setProfile: (profile: Partial<AuthSession>) => void
}

function buildSession(auth: AuthResult, profile: UserProfile): AuthSession {
  return {
    token: auth.token,
    refreshToken: auth.refreshToken,
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

function persistTokens(token: string, refreshToken: string) {
  localStorage.setItem(TOKEN_KEY, token)
  localStorage.setItem(REFRESH_TOKEN_KEY, refreshToken)
}

function clearTokens() {
  localStorage.removeItem(TOKEN_KEY)
  localStorage.removeItem(REFRESH_TOKEN_KEY)
}

/** signup/login share this: exchange credentials for tokens, then fetch the full profile. */
async function authenticate(request: () => Promise<AuthResult>): Promise<AuthSession> {
  const auth = await request()
  setAuthToken(auth.token)
  setRefreshToken(auth.refreshToken)
  try {
    const profile = await authService.fetchMe()
    return buildSession(auth, profile)
  } catch (err) {
    setAuthToken(null)
    setRefreshToken(null)
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
      persistTokens(session.token, session.refreshToken)
      set({ session, isLoading: false })
    } catch (err) {
      set({ isLoading: false, error: err instanceof ApiError ? err.message : '회원가입에 실패했습니다.' })
    }
  },

  async login(payload) {
    set({ isLoading: true, error: null })
    try {
      const session = await authenticate(() => authService.login(payload))
      persistTokens(session.token, session.refreshToken)
      set({ session, isLoading: false })
    } catch (err) {
      set({ isLoading: false, error: err instanceof ApiError ? err.message : '로그인에 실패했습니다.' })
    }
  },

  logout() {
    setAuthToken(null)
    setRefreshToken(null)
    clearTokens()
    set({ session: null, error: null })
  },

  async hydrate() {
    const token = localStorage.getItem(TOKEN_KEY)
    const refreshToken = localStorage.getItem(REFRESH_TOKEN_KEY)
    if (!token || !refreshToken) return
    setAuthToken(token)
    setRefreshToken(refreshToken)
    try {
      const profile = await authService.fetchMe()
      set({
        session: {
          token,
          refreshToken,
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
      setRefreshToken(null)
      clearTokens()
    }
  },

  updateXp(newTotalXp) {
    const session = get().session
    if (!session) return
    const { level } = getLevelInfo(newTotalXp)
    set({ session: { ...session, totalXp: newTotalXp, level } })
  },

  setProfile(profile) {
    const session = get().session
    if (!session) return
    set({ session: { ...session, ...profile } })
  },
}))

// api.ts's response interceptor calls these on a silent token refresh (so
// the new tokens survive a reload) or when the refresh itself fails (so a
// truly expired session logs the user out instead of looping 403s forever).
setTokenRefreshHandlers({
  onRefreshed: (accessToken, refreshToken) => {
    persistTokens(accessToken, refreshToken)
    const session = useAuthStore.getState().session
    if (session) {
      useAuthStore.setState({ session: { ...session, token: accessToken, refreshToken } })
    }
  },
  onFailed: () => {
    useAuthStore.getState().logout()
  },
})
