/// <reference types="node" />
import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { File as NodeFile } from 'node:buffer'

const BASE = 'http://localhost:8080/api/v1'

// This project's jsdom test environment shadows the global `File` with
// jsdom's own class. That's unrelated to (and harmless for) most tests, but
// the profile-image handler below calls `request.formData()` on a genuine
// multipart body, and Node's built-in fetch (undici) internally constructs
// `new File(...)` — via the *global* `File` binding — while parsing each
// file part. Under jsdom that resolves to jsdom's File constructor, which
// then fails undici's own internal brand check on the object it just built,
// crashing with a webidl assertion before the handler ever runs. Swapping
// the global back to Node's real File (same one undici's parser expects)
// for the duration of this file fixes it — verified empirically; see the
// task's multipart-mechanics note for why this had to be tested, not assumed.
let originalFile: typeof File
beforeAll(() => {
  originalFile = globalThis.File
  globalThis.File = NodeFile as unknown as typeof File
})
afterAll(() => {
  globalThis.File = originalFile
})

// Raw multipart/form-data bytes, built by hand rather than via the
// FormData/File Web APIs — this is what a real browser's fetch would put on
// the wire, and it keeps these tests free of any client-side File/FormData
// class concerns (only the server-side parsing above needed the patch).
function multipartBody(boundary: string, fieldName: string, filename: string, contentType: string, content: string) {
  return (
    `--${boundary}\r\n` +
    `Content-Disposition: form-data; name="${fieldName}"; filename="${filename}"\r\n` +
    `Content-Type: ${contentType}\r\n\r\n` +
    `${content}\r\n` +
    `--${boundary}--\r\n`
  )
}

function emptyMultipartBody(boundary: string) {
  return `--${boundary}--\r\n`
}

async function signupAndGetToken(email: string, nickname: string, password = 'pw123456') {
  const res = await fetch(`${BASE}/auth/signup`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password, nickname }),
  })
  const { accessToken } = await res.json()
  return accessToken as string
}

describe('user mock handlers', () => {
  describe('PATCH /users/me', () => {
    it('rejects without a valid token', async () => {
      const res = await fetch(`${BASE}/users/me`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json', Authorization: 'Bearer garbage' },
        body: JSON.stringify({ nickname: '새닉네임' }),
      })
      expect(res.status).toBe(401)
    })

    it('updates nickname and bio', async () => {
      const token = await signupAndGetToken('patch1@test.com', '헌터')

      const res = await fetch(`${BASE}/users/me`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify({ nickname: '새닉네임', bio: '피싱을 잡는 사람입니다.' }),
      })

      expect(res.status).toBe(200)
      const body = await res.json()
      expect(body.nickname).toBe('새닉네임')
      expect(body.bio).toBe('피싱을 잡는 사람입니다.')
    })

    it('rejects an invalid nickname pattern with 400', async () => {
      const token = await signupAndGetToken('patch2@test.com', '헌터')

      const res = await fetch(`${BASE}/users/me`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify({ nickname: '닉네임 with space!' }),
      })

      expect(res.status).toBe(400)
    })

    it('rejects a bio over 255 characters with 400', async () => {
      const token = await signupAndGetToken('patch3@test.com', '헌터')

      const res = await fetch(`${BASE}/users/me`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify({ bio: 'a'.repeat(256) }),
      })

      expect(res.status).toBe(400)
    })

    it('rejects a nickname already taken by another user with 409', async () => {
      await signupAndGetToken('owner@test.com', '이미있음')
      const token = await signupAndGetToken('challenger@test.com', '도전자')

      const res = await fetch(`${BASE}/users/me`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify({ nickname: '이미있음' }),
      })

      expect(res.status).toBe(409)
    })

    it('allows re-sending the same nickname the user already has', async () => {
      const token = await signupAndGetToken('same-nick@test.com', '동일닉네임')

      const res = await fetch(`${BASE}/users/me`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify({ nickname: '동일닉네임' }),
      })

      expect(res.status).toBe(200)
    })

    it('changes the password when currentPassword matches', async () => {
      const token = await signupAndGetToken('pw1@test.com', '헌터', 'oldpass1')

      const res = await fetch(`${BASE}/users/me`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify({ currentPassword: 'oldpass1', newPassword: 'newpass1' }),
      })
      expect(res.status).toBe(200)

      const login = await fetch(`${BASE}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: 'pw1@test.com', password: 'newpass1' }),
      })
      expect(login.status).toBe(200)
    })

    it('rejects newPassword sent without currentPassword with 400', async () => {
      const token = await signupAndGetToken('pw2@test.com', '헌터')

      const res = await fetch(`${BASE}/users/me`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify({ newPassword: 'newpass1' }),
      })

      expect(res.status).toBe(400)
    })

    it('rejects a wrong currentPassword with 401', async () => {
      const token = await signupAndGetToken('pw3@test.com', '헌터', 'correctpw')

      const res = await fetch(`${BASE}/users/me`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify({ currentPassword: 'wrongpw', newPassword: 'newpass1' }),
      })

      expect(res.status).toBe(401)
    })
  })

  describe('POST /users/me/profile-image', () => {
    it('rejects without a valid token', async () => {
      const boundary = 'boundary-noauth'
      const res = await fetch(`${BASE}/users/me/profile-image`, {
        method: 'POST',
        headers: {
          Authorization: 'Bearer garbage',
          'Content-Type': `multipart/form-data; boundary=${boundary}`,
        },
        body: multipartBody(boundary, 'file', 'a.png', 'image/png', 'x'),
      })

      expect(res.status).toBe(401)
    })

    it('uploads an image and returns the updated profile', async () => {
      const token = await signupAndGetToken('img1@test.com', '헌터')
      const boundary = 'boundary-upload'

      const res = await fetch(`${BASE}/users/me/profile-image`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': `multipart/form-data; boundary=${boundary}`,
        },
        body: multipartBody(boundary, 'file', 'avatar.png', 'image/png', 'fake-image-bytes'),
      })

      expect(res.status).toBe(200)
      const body = await res.json()
      expect(body.profileImageUrl).toMatch(/^data:image\/png;base64,/)
    })

    it('rejects a disallowed content type with 400', async () => {
      const token = await signupAndGetToken('img2@test.com', '헌터')
      const boundary = 'boundary-badtype'

      const res = await fetch(`${BASE}/users/me/profile-image`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': `multipart/form-data; boundary=${boundary}`,
        },
        body: multipartBody(boundary, 'file', 'a.txt', 'text/plain', 'not an image'),
      })

      expect(res.status).toBe(400)
    })

    it('rejects a missing file with 400', async () => {
      const token = await signupAndGetToken('img3@test.com', '헌터')
      const boundary = 'boundary-empty'

      const res = await fetch(`${BASE}/users/me/profile-image`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': `multipart/form-data; boundary=${boundary}`,
        },
        body: emptyMultipartBody(boundary),
      })

      expect(res.status).toBe(400)
    })
  })
})
