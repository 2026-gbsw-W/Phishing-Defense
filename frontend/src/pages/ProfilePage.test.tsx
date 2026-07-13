/// <reference types="node" />
import { describe, it, expect, vi, afterEach } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter, Routes, Route } from 'react-router-dom'
import toast from 'react-hot-toast'
import { File as NodeFile } from 'node:buffer'
import { mockDb, tokenForUser } from '@mocks/db'
import { setAuthToken } from '@services/api'
import { useAuthStore } from '@stores/authStore'
import { ProfilePage } from './ProfilePage'

// See src/services/userService.test.ts for the full explanation: this test
// environment's global File/FormData (jsdom's) aren't brand-compatible with
// the ones Node's built-in fetch (undici) uses to send/parse a real
// multipart request, which the image-upload test below exercises via the
// actual userService -> apiClient -> MSW round trip. Patching both globals
// to Node's real classes for this module's duration fixes it (done via
// top-level await, before any test/render runs, so it can't be mistaken for
// an unflushed async React update mid-test); a real browser has no such
// split and needs none of this.
globalThis.File = NodeFile as unknown as typeof File
const nativeFormDataProbe = await new Request('http://native-formdata-probe', {
  method: 'POST',
  body: 'x=1',
  headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
}).formData()
globalThis.FormData = nativeFormDataProbe.constructor as typeof FormData

function renderProfilePage() {
  return render(
    <MemoryRouter initialEntries={['/profile']}>
      <Routes>
        <Route path="/profile" element={<ProfilePage />} />
        <Route path="/home" element={<p>home page</p>} />
      </Routes>
    </MemoryRouter>,
  )
}

function loginAsMockUser(overrides: Partial<{ nickname: string; bio: string | null; profileImageUrl: string | null }> = {}) {
  const user = mockDb.createUser(`profile${Math.random()}@test.com`, 'pw123456', overrides.nickname ?? '헌터')
  if (overrides.bio !== undefined) user.bio = overrides.bio
  if (overrides.profileImageUrl !== undefined) user.profileImageUrl = overrides.profileImageUrl
  const token = tokenForUser(user.userId)
  setAuthToken(token)
  useAuthStore.setState({
    session: {
      token,
      userId: user.userId,
      email: user.email,
      nickname: user.nickname,
      level: user.level,
      currentXp: user.currentXp,
      totalXp: user.totalXp,
      bio: user.bio,
      profileImageUrl: user.profileImageUrl,
    },
  })
  return user
}

describe('ProfilePage', () => {
  afterEach(() => {
    useAuthStore.setState({ session: null, isLoading: false, error: null })
  })

  it('renders the current profile: nickname, email, level/xp', async () => {
    const user = loginAsMockUser({ nickname: '피싱헌터', bio: '자기소개' })
    renderProfilePage()

    expect(screen.getByText('피싱헌터')).toBeInTheDocument()
    expect(screen.getByText(user.email)).toBeInTheDocument()
    expect(screen.getByText('Lv.1')).toBeInTheDocument()
    expect(screen.getByLabelText('닉네임')).toHaveValue('피싱헌터')
    expect(screen.getByLabelText('자기소개')).toHaveValue('자기소개')
  })

  it('shows a placeholder avatar when profileImageUrl is null', () => {
    loginAsMockUser({ nickname: '헌터', profileImageUrl: null })
    renderProfilePage()

    expect(screen.queryByAltText('프로필 이미지')).not.toBeInTheDocument()
  })

  it('navigates back to /home via the back link', async () => {
    loginAsMockUser()
    renderProfilePage()

    await userEvent.click(screen.getByRole('link', { name: '← 홈으로' }))

    expect(await screen.findByText('home page')).toBeInTheDocument()
  })

  it('updates nickname and bio and reflects the change immediately', async () => {
    loginAsMockUser({ nickname: '헌터' })
    renderProfilePage()

    const nicknameInput = screen.getByLabelText('닉네임')
    await userEvent.clear(nicknameInput)
    await userEvent.type(nicknameInput, '새헌터')
    await userEvent.click(screen.getByRole('button', { name: '저장' }))

    await waitFor(() => {
      expect(useAuthStore.getState().session?.nickname).toBe('새헌터')
    })
    expect(screen.getByText('새헌터')).toBeInTheDocument()
  })

  it('shows an error toast when the nickname is already taken', async () => {
    mockDb.createUser('owner@test.com', 'pw123456', '선점닉네임')
    loginAsMockUser({ nickname: '도전자' })
    renderProfilePage()
    const toastErrorSpy = vi.spyOn(toast, 'error')

    const nicknameInput = screen.getByLabelText('닉네임')
    await userEvent.clear(nicknameInput)
    await userEvent.type(nicknameInput, '선점닉네임')
    await userEvent.click(screen.getByRole('button', { name: '저장' }))

    await waitFor(() => expect(toastErrorSpy).toHaveBeenCalled())
  })

  it('changes the password and clears the password fields on success', async () => {
    loginAsMockUser()
    // signup via mockDb.createUser sets password to 'pw123456' (see loginAsMockUser)
    renderProfilePage()

    await userEvent.type(screen.getByLabelText('현재 비밀번호'), 'pw123456')
    await userEvent.type(screen.getByLabelText('새 비밀번호'), 'newpass123')
    await userEvent.click(screen.getByRole('button', { name: '비밀번호 변경' }))

    await waitFor(() => {
      expect(screen.getByLabelText('현재 비밀번호')).toHaveValue('')
      expect(screen.getByLabelText('새 비밀번호')).toHaveValue('')
    })
  })

  it('shows an error toast when the current password is wrong', async () => {
    loginAsMockUser()
    renderProfilePage()
    const toastErrorSpy = vi.spyOn(toast, 'error')

    await userEvent.type(screen.getByLabelText('현재 비밀번호'), 'wrongpassword')
    await userEvent.type(screen.getByLabelText('새 비밀번호'), 'newpass123')
    await userEvent.click(screen.getByRole('button', { name: '비밀번호 변경' }))

    await waitFor(() => expect(toastErrorSpy).toHaveBeenCalled())
  })

  it('uploads a profile image and displays it', async () => {
    loginAsMockUser({ profileImageUrl: null })
    renderProfilePage()

    const file = new File(['fake-image-bytes'], 'avatar.png', { type: 'image/png' })
    const input = document.getElementById('profile-image-input') as HTMLInputElement
    await userEvent.upload(input, file)

    await waitFor(() => {
      expect(useAuthStore.getState().session?.profileImageUrl).toMatch(/^data:image\/png;base64,/)
    })
    expect(screen.getByAltText('프로필 이미지')).toBeInTheDocument()
  })
})
