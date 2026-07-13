export interface User {
  userId: number
  email: string
  nickname: string
  level: number
  totalXp: number
  coins: number
  hints: number
}

export interface AuthSession {
  token: string
  userId: number
  email: string
  nickname: string
  level: number
  currentXp: number
  totalXp: number
  bio: string | null
  profileImageUrl: string | null
}

export interface SignupPayload {
  email: string
  password: string
  nickname: string
}

export interface LoginPayload {
  email: string
  password: string
}
