import { apiClient } from './api'
import type { AuthSession, LoginPayload, SignupPayload } from '@/types/auth'

/** Wire shape of Spring's `AuthResponse` (POST /auth/signup, /auth/login). No XP fields. */
interface AuthWireResponse {
  accessToken: string
  tokenType: string
  expiresIn: number
  userId: number
  email: string
  nickname: string
  level: number
}

/** Wire shape of Spring's `UserProfileResponse` (GET /users/me). */
interface UserWireResponse {
  userId: number
  email: string
  nickname: string
  bio: string | null
  profileImageUrl: string | null
  level: number
  currentXp: number
  totalXp: number
}

/** What signup/login give us: identity + token, but no XP/bio/image yet. */
export type AuthResult = Pick<AuthSession, 'token' | 'userId' | 'email' | 'nickname' | 'level'>

/** Full profile as returned by GET /users/me. */
export type UserProfile = Pick<
  AuthSession,
  'userId' | 'email' | 'nickname' | 'bio' | 'profileImageUrl' | 'level' | 'currentXp' | 'totalXp'
>

function toAuthResult(body: AuthWireResponse): AuthResult {
  return {
    token: body.accessToken,
    userId: body.userId,
    email: body.email,
    nickname: body.nickname,
    level: body.level,
  }
}

function toUserProfile(body: UserWireResponse): UserProfile {
  return {
    userId: body.userId,
    email: body.email,
    nickname: body.nickname,
    bio: body.bio,
    profileImageUrl: body.profileImageUrl,
    level: body.level,
    currentXp: body.currentXp,
    totalXp: body.totalXp,
  }
}

export const authService = {
  async signup(payload: SignupPayload): Promise<AuthResult> {
    const { data } = await apiClient.post<AuthWireResponse>('/api/v1/auth/signup', payload)
    return toAuthResult(data)
  },

  async login(payload: LoginPayload): Promise<AuthResult> {
    const { data } = await apiClient.post<AuthWireResponse>('/api/v1/auth/login', payload)
    return toAuthResult(data)
  },

  async fetchMe(): Promise<UserProfile> {
    const { data } = await apiClient.get<UserWireResponse>('/api/v1/users/me')
    return toUserProfile(data)
  },
}
