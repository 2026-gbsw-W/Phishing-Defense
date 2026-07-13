/// <reference types="node" />
import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { File as NodeFile } from 'node:buffer'
import { userService } from './userService'
import { authService } from './authService'
import { setAuthToken } from './api'

async function loginAsNewUser(email: string, nickname: string) {
  const session = await authService.signup({ email, password: 'pw123456', nickname })
  setAuthToken(session.token)
  return session
}

// --- Multipart test-environment plumbing -----------------------------------
// This suite's jsdom test environment shadows the global `File`/`FormData`
// with jsdom's own classes, which breaks `userService.uploadProfileImage`
// (unmodified, real production code) in two ways when run against MSW here:
//
// 1. jsdom's `FormData.append(name, value)` only treats `value` as a file
//    part if it's an instance of jsdom's *own* Blob/File class — appending a
//    File built from a different realm silently stringifies it instead
//    (`"[object File]"`), so `formData.append('file', file)` inside
//    `uploadProfileImage` would never actually attach real bytes.
// 2. Server-side, Node's built-in fetch (undici) parses multipart bodies by
//    internally constructing `new File(...)` via the *global* File binding,
//    then brand-checking the result against undici's own internal File
//    class. Under jsdom that binding resolves to jsdom's File, so the
//    object undici just built fails its own check — a crash inside the mock
//    handler before it ever runs.
//
// Neither of these exists in a real browser (File/FormData/fetch all come
// from the same implementation there — no split-realm mismatch). To
// exercise the real `uploadProfileImage` function against the mock here, we
// patch `File` and `FormData` back to Node's own classes (the ones undici's
// parser actually expects) for the duration of this suite. The FormData
// class itself isn't exported anywhere importable, so it's recovered by
// reading `.constructor` off an instance obtained via a throwaway native
// Request parse — that instance is guaranteed to be undici's real FormData.
// Worked out empirically by running these tests, per the task's "test it,
// don't assume" instruction for the upload mechanics.
let originalFile: typeof File
let originalFormData: typeof FormData
beforeAll(async () => {
  originalFile = globalThis.File
  originalFormData = globalThis.FormData
  globalThis.File = NodeFile as unknown as typeof File

  const nativeFormDataProbe = await new Request('http://native-formdata-probe', {
    method: 'POST',
    body: 'x=1',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  }).formData()
  globalThis.FormData = nativeFormDataProbe.constructor as typeof FormData
})
afterAll(() => {
  globalThis.File = originalFile
  globalThis.FormData = originalFormData
})
// -----------------------------------------------------------------------

describe('userService', () => {
  it('updates nickname and bio via PATCH /users/me', async () => {
    await loginAsNewUser('svc-update@test.com', '헌터')

    const profile = await userService.updateProfile({ nickname: '새헌터', bio: '자기소개입니다.' })

    expect(profile.nickname).toBe('새헌터')
    expect(profile.bio).toBe('자기소개입니다.')
  })

  it('throws ApiError with status 409 when the nickname is taken', async () => {
    await loginAsNewUser('svc-taken-owner@test.com', '선점닉네임')
    await loginAsNewUser('svc-taken-challenger@test.com', '도전자2')

    await expect(userService.updateProfile({ nickname: '선점닉네임' })).rejects.toMatchObject({
      status: 409,
    })
  })

  it('throws ApiError with status 401 when currentPassword is wrong', async () => {
    await loginAsNewUser('svc-badpw@test.com', '헌터2')

    await expect(
      userService.updateProfile({ currentPassword: 'wrong', newPassword: 'newpass1' }),
    ).rejects.toMatchObject({ status: 401 })
  })

  // This is the load-bearing test for the multipart upload mechanics: it
  // calls the real, unmodified `userService.uploadProfileImage` (which
  // builds its own `FormData` and calls `apiClient.post` with a
  // Content-Type override) and proves the request actually arrives at the
  // mock's `request.formData()` as a parseable multipart body with the file
  // bytes intact — rather than being silently mangled by axios's
  // default-JSON transformRequest or by this test environment's FormData
  // quirks (see the block comment above).
  it('uploads a profile image via multipart/form-data and returns the updated profile', async () => {
    await loginAsNewUser('svc-upload@test.com', '헌터3')
    const file = new File(['fake-image-bytes'], 'avatar.png', { type: 'image/png' })

    const profile = await userService.uploadProfileImage(file)

    expect(profile.profileImageUrl).toMatch(/^data:image\/png;base64,/)
  })

  it('throws ApiError with status 400 for a disallowed image type', async () => {
    await loginAsNewUser('svc-upload-bad@test.com', '헌터4')
    const file = new File(['not an image'], 'a.txt', { type: 'text/plain' })

    await expect(userService.uploadProfileImage(file)).rejects.toMatchObject({ status: 400 })
  })
})
