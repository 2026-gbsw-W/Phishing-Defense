// Mock DB for local/offline dev and component tests. Only auth + profile are
// mocked here — the actual game flow (chapters/scenarios/chat/evidence/report)
// now talks to the real Spring backend + AI service (see docs/PRD.md §14),
// so there's no mock game-state model to maintain here anymore.
export interface MockUserRecord {
  userId: number
  email: string
  password: string
  nickname: string
  bio: string | null
  profileImageUrl: string | null
  level: number
  currentXp: number
  totalXp: number
  coins: number
  hints: number
}

let userSeq = 1

export const mockDb = {
  users: new Map<number, MockUserRecord>(),
  usersByEmail: new Map<string, MockUserRecord>(),

  reset() {
    this.users.clear()
    this.usersByEmail.clear()
    userSeq = 1
  },

  createUser(email: string, password: string, nickname: string): MockUserRecord {
    const user: MockUserRecord = {
      userId: userSeq++,
      email,
      password,
      nickname,
      bio: null,
      profileImageUrl: null,
      level: 1,
      currentXp: 0,
      totalXp: 0,
      coins: 0,
      hints: 3,
    }
    this.users.set(user.userId, user)
    this.usersByEmail.set(email, user)
    return user
  },
}

export function tokenForUser(userId: number): string {
  return `mock-jwt.${userId}`
}

export function userIdFromToken(token: string | null): number | null {
  if (!token) return null
  const match = /^mock-jwt\.(\d+)$/.exec(token.replace('Bearer ', ''))
  return match ? Number(match[1]) : null
}
