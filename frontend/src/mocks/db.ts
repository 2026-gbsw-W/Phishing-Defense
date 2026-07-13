import type { ChatMessage, Evidence, Stage } from '@/types/game'
import { CHAPTERS } from './scenarioData'

export interface MockUserRecord {
  userId: number
  email: string
  password: string
  nickname: string
  level: number
  totalXp: number
  coins: number
  hints: number
}

export interface MockEvidence extends Evidence {
  recordId: number
}

export interface MockRecord {
  recordId: number
  userId: number
  scenarioId: number
  stage: Stage
  currentTurn: number
  chatHistory: ChatMessage[]
  hintsUsed: number
  hintsRemaining: number
  wrongJudgmentAttempts: number
  judgmentCorrect: boolean | null
  judgmentTurn: number | null
  evidence: MockEvidence[]
  policeTurnsCompleted: number
  isCompleted: boolean
  claimed: boolean
}

let userSeq = 1
let recordSeq = 1
let evidenceSeq = 1

export const mockDb = {
  users: new Map<number, MockUserRecord>(),
  usersByEmail: new Map<string, MockUserRecord>(),
  chapters: CHAPTERS.map((c) => ({ ...c })),
  records: new Map<number, MockRecord>(),

  reset() {
    this.users.clear()
    this.usersByEmail.clear()
    this.records.clear()
    this.chapters = CHAPTERS.map((c) => ({ ...c }))
    userSeq = 1
    recordSeq = 1
    evidenceSeq = 1
  },

  createUser(email: string, password: string, nickname: string): MockUserRecord {
    const user: MockUserRecord = {
      userId: userSeq++,
      email,
      password,
      nickname,
      level: 1,
      totalXp: 0,
      coins: 0,
      hints: 3,
    }
    this.users.set(user.userId, user)
    this.usersByEmail.set(email, user)
    return user
  },

  createRecord(userId: number, scenarioId: number): MockRecord {
    const record: MockRecord = {
      recordId: recordSeq++,
      userId,
      scenarioId,
      stage: 1,
      currentTurn: 0,
      chatHistory: [],
      hintsUsed: 0,
      hintsRemaining: 3,
      wrongJudgmentAttempts: 0,
      judgmentCorrect: null,
      judgmentTurn: null,
      evidence: [],
      policeTurnsCompleted: 0,
      isCompleted: false,
      claimed: false,
    }
    this.records.set(record.recordId, record)
    return record
  },

  nextEvidenceId(): number {
    return evidenceSeq++
  },

  addEvidence(record: MockRecord, evidence: Omit<MockEvidence, 'recordId'>): MockEvidence {
    const full: MockEvidence = { ...evidence, recordId: record.recordId }
    record.evidence.push(full)
    return full
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
