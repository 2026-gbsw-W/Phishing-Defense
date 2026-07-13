import { http, HttpResponse } from 'msw'
import { mockDb, userIdFromToken } from '../db'
import type { MockUserRecord } from '../db'

const BASE = '*/api/v1'
const NICKNAME_PATTERN = /^[a-zA-Z0-9가-힣_-]+$/
const ALLOWED_IMAGE_TYPES = ['image/jpeg', 'image/png', 'image/webp']

function requireUser(request: Request): MockUserRecord | null {
  const userId = userIdFromToken(request.headers.get('Authorization'))
  return userId ? (mockDb.users.get(userId) ?? null) : null
}

function toProfileResponse(user: MockUserRecord) {
  return {
    userId: user.userId,
    email: user.email,
    nickname: user.nickname,
    bio: user.bio,
    profileImageUrl: user.profileImageUrl,
    level: user.level,
    currentXp: user.currentXp,
    totalXp: user.totalXp,
  }
}

export const userHandlers = [
  http.patch(`${BASE}/users/me`, async ({ request }) => {
    const user = requireUser(request)
    if (!user) {
      return HttpResponse.json({ message: '인증이 필요합니다.' }, { status: 401 })
    }

    const body = (await request.json()) as {
      nickname?: string
      bio?: string
      currentPassword?: string
      newPassword?: string
    }

    if (body.nickname !== undefined) {
      if (body.nickname.length < 2 || body.nickname.length > 50 || !NICKNAME_PATTERN.test(body.nickname)) {
        return HttpResponse.json(
          { message: '닉네임은 한글/영문/숫자/_/-만 사용할 수 있습니다.', code: 'INVALID_INPUT' },
          { status: 400 },
        )
      }
      if (body.nickname !== user.nickname) {
        const taken = [...mockDb.users.values()].some(
          (u) => u.userId !== user.userId && u.nickname === body.nickname,
        )
        if (taken) {
          return HttpResponse.json(
            { message: '이미 사용 중인 닉네임입니다.', code: 'DUPLICATE_NICKNAME' },
            { status: 409 },
          )
        }
        user.nickname = body.nickname
      }
    }

    if (body.bio !== undefined) {
      if (body.bio.length > 255) {
        return HttpResponse.json(
          { message: '자기소개는 255자를 초과할 수 없습니다.', code: 'INVALID_INPUT' },
          { status: 400 },
        )
      }
      user.bio = body.bio
    }

    if (body.newPassword) {
      if (!body.currentPassword) {
        return HttpResponse.json(
          { message: '현재 비밀번호를 입력해주세요.', code: 'MISSING_CURRENT_PASSWORD' },
          { status: 400 },
        )
      }
      if (body.currentPassword !== user.password) {
        return HttpResponse.json(
          { message: '현재 비밀번호가 올바르지 않습니다.', code: 'INVALID_CURRENT_PASSWORD' },
          { status: 401 },
        )
      }
      if (body.newPassword.length < 8 || body.newPassword.length > 100) {
        return HttpResponse.json(
          { message: '비밀번호는 8자 이상 100자 이하여야 합니다.', code: 'INVALID_INPUT' },
          { status: 400 },
        )
      }
      user.password = body.newPassword
    }

    return HttpResponse.json(toProfileResponse(user))
  }),

  http.post(`${BASE}/users/me/profile-image`, async ({ request }) => {
    const user = requireUser(request)
    if (!user) {
      return HttpResponse.json({ message: '인증이 필요합니다.' }, { status: 401 })
    }

    const formData = await request.formData()
    const file = formData.get('file')

    // Deliberately not `file instanceof File`: the File constructor that
    // produced this value (via undici's multipart parser) is not guaranteed
    // to be reference-equal to the environment's global `File` (e.g. jsdom's
    // File in tests differs from undici's), so duck-type on shape instead.
    const isFileLike = (v: unknown): v is File =>
      typeof v === 'object' && v !== null && 'size' in v && 'type' in v && 'arrayBuffer' in v

    if (!isFileLike(file) || file.size === 0) {
      return HttpResponse.json({ message: '업로드할 파일이 비어 있습니다.' }, { status: 400 })
    }
    if (!ALLOWED_IMAGE_TYPES.includes(file.type)) {
      return HttpResponse.json(
        { message: '이미지 파일(JPEG, PNG, WEBP)만 업로드할 수 있습니다.' },
        { status: 400 },
      )
    }

    // No real file storage in the mock — a placeholder data URL stands in for
    // whatever URL the real backend's FileStorageService would return.
    user.profileImageUrl = `data:${file.type};base64,mock-${user.userId}`
    return HttpResponse.json(toProfileResponse(user))
  }),
]
