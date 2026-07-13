import { http, HttpResponse } from 'msw'
import { mockDb, tokenForUser, userIdFromToken } from '../db'

const BASE = '*/api/v1'

export const authHandlers = [
  http.post(`${BASE}/auth/signup`, async ({ request }) => {
    const { email, password, nickname } = (await request.json()) as {
      email: string
      password: string
      nickname: string
    }
    if (mockDb.usersByEmail.has(email)) {
      return HttpResponse.json({ message: '이미 가입된 이메일입니다.' }, { status: 409 })
    }
    const user = mockDb.createUser(email, password, nickname)
    return HttpResponse.json(
      {
        accessToken: tokenForUser(user.userId),
        tokenType: 'Bearer',
        expiresIn: 3600,
        userId: user.userId,
        email: user.email,
        nickname: user.nickname,
        level: user.level,
      },
      { status: 201 },
    )
  }),

  http.post(`${BASE}/auth/login`, async ({ request }) => {
    const { email, password } = (await request.json()) as { email: string; password: string }
    const user = mockDb.usersByEmail.get(email)
    if (!user || user.password !== password) {
      return HttpResponse.json({ message: '이메일 또는 비밀번호가 올바르지 않습니다.' }, { status: 401 })
    }
    return HttpResponse.json({
      accessToken: tokenForUser(user.userId),
      tokenType: 'Bearer',
      expiresIn: 3600,
      userId: user.userId,
      email: user.email,
      nickname: user.nickname,
      level: user.level,
    })
  }),

  http.get(`${BASE}/users/me`, ({ request }) => {
    const userId = userIdFromToken(request.headers.get('Authorization'))
    const user = userId ? mockDb.users.get(userId) : undefined
    if (!user) {
      return HttpResponse.json({ message: '인증이 필요합니다.' }, { status: 401 })
    }
    return HttpResponse.json({
      userId: user.userId,
      email: user.email,
      nickname: user.nickname,
      bio: user.bio,
      profileImageUrl: user.profileImageUrl,
      level: user.level,
      currentXp: user.currentXp,
      totalXp: user.totalXp,
    })
  }),
]
