import { apiClient } from './api'
import type { AuthSession, LoginPayload, SignupPayload, User } from '@/types/auth'

interface AuthWireResponse {
  token: string
  user_id: number
  nickname: string
  level: number
  xp: number
}

interface UserWireResponse {
  user_id: number
  nickname: string
  level: number
  xp: number
}

function toSession(body: AuthWireResponse): AuthSession {
  return { token: body.token, userId: body.user_id, nickname: body.nickname, level: body.level, totalXp: body.xp }
}

export const authService = {
  async signup(payload: SignupPayload): Promise<AuthSession> {
    const { data } = await apiClient.post<AuthWireResponse>('/api/v1/auth/signup', payload)
    return toSession(data)
  },

  async login(payload: LoginPayload): Promise<AuthSession> {
    const { data } = await apiClient.post<AuthWireResponse>('/api/v1/auth/login', payload)
    return toSession(data)
  },

  async logout(): Promise<void> {
    await apiClient.post('/api/v1/auth/logout')
  },

  async fetchMe(): Promise<Pick<User, 'userId' | 'nickname' | 'level' | 'totalXp'>> {
    const { data } = await apiClient.get<UserWireResponse>('/api/v1/users/me')
    return { userId: data.user_id, nickname: data.nickname, level: data.level, totalXp: data.xp }
  },
}
