import { useState, type ChangeEvent, type FormEvent } from 'react'
import { Link } from 'react-router-dom'
import toast from 'react-hot-toast'
import { useAuth } from '@hooks/useAuth'
import { useAuthStore } from '@stores/authStore'
import { userService } from '@services/userService'
import { getLevelInfo } from '@utils/levels'
import { ProgressBar } from '@components/common/ProgressBar'
import { ApiError } from '@/types/api'

function errorMessage(err: unknown, fallback: string): string {
  return err instanceof ApiError ? err.message : fallback
}

export function ProfilePage() {
  const { session } = useAuth()
  const setProfile = useAuthStore((s) => s.setProfile)

  const [nickname, setNickname] = useState(session?.nickname ?? '')
  const [bio, setBio] = useState(session?.bio ?? '')
  const [isSavingProfile, setIsSavingProfile] = useState(false)

  const [currentPassword, setCurrentPassword] = useState('')
  const [newPassword, setNewPassword] = useState('')
  const [isSavingPassword, setIsSavingPassword] = useState(false)

  const [isUploadingImage, setIsUploadingImage] = useState(false)

  if (!session) return null
  const levelInfo = getLevelInfo(session.totalXp)

  const handleProfileSubmit = async (e: FormEvent) => {
    e.preventDefault()
    setIsSavingProfile(true)
    try {
      const updated = await userService.updateProfile({ nickname, bio })
      setProfile(updated)
      toast.success('프로필이 저장되었습니다.')
    } catch (err) {
      toast.error(errorMessage(err, '프로필 저장에 실패했습니다.'))
    } finally {
      setIsSavingProfile(false)
    }
  }

  const handlePasswordSubmit = async (e: FormEvent) => {
    e.preventDefault()
    setIsSavingPassword(true)
    try {
      await userService.updateProfile({ currentPassword, newPassword })
      toast.success('비밀번호가 변경되었습니다.')
      setCurrentPassword('')
      setNewPassword('')
    } catch (err) {
      toast.error(errorMessage(err, '비밀번호 변경에 실패했습니다.'))
    } finally {
      setIsSavingPassword(false)
    }
  }

  const handleImageChange = async (e: ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    e.target.value = ''
    if (!file) return
    setIsUploadingImage(true)
    try {
      const updated = await userService.uploadProfileImage(file)
      setProfile(updated)
      toast.success('프로필 이미지가 변경되었습니다.')
    } catch (err) {
      toast.error(errorMessage(err, '이미지 업로드에 실패했습니다.'))
    } finally {
      setIsUploadingImage(false)
    }
  }

  return (
    <div className="profile-page hex-bg">
      <div className="profile-wrap">
        <Link to="/home" className="profile-back-link accent">
          ← 홈으로
        </Link>

        <section className="card profile-summary">
          <div className="profile-avatar-row">
            {session.profileImageUrl ? (
              <img src={session.profileImageUrl} alt="프로필 이미지" className="profile-avatar" />
            ) : (
              <div className="profile-avatar profile-avatar-placeholder" aria-hidden="true">
                {session.nickname.slice(0, 1)}
              </div>
            )}
            <div className="profile-avatar-upload">
              <label htmlFor="profile-image-input" className="btn-ghost profile-avatar-upload-label">
                {isUploadingImage ? '업로드 중...' : '이미지 변경'}
              </label>
              <input
                id="profile-image-input"
                type="file"
                accept="image/jpeg,image/png,image/webp"
                onChange={handleImageChange}
                disabled={isUploadingImage}
                className="profile-avatar-upload-input"
              />
            </div>
          </div>
          <p className="dashboard-nickname">{session.nickname}</p>
          <p className="profile-email mono">{session.email}</p>
          <div className="dashboard-level-row">
            <span className="mono">Lv.{levelInfo.level}</span>
          </div>
          <ProgressBar
            ratio={levelInfo.progressRatio}
            label={`${levelInfo.currentLevelXp} / ${levelInfo.xpForNextLevel} XP`}
          />
        </section>

        <section className="card profile-section">
          <h2 className="dashboard-section-title">프로필 수정</h2>
          <form onSubmit={handleProfileSubmit} className="auth-form">
            <div className="field">
              <label htmlFor="profile-nickname">닉네임</label>
              <input
                id="profile-nickname"
                value={nickname}
                onChange={(e) => setNickname(e.target.value)}
                minLength={2}
                maxLength={50}
                required
              />
            </div>
            <div className="field">
              <label htmlFor="profile-bio">자기소개</label>
              <textarea
                id="profile-bio"
                value={bio}
                onChange={(e) => setBio(e.target.value)}
                maxLength={255}
                rows={3}
              />
            </div>
            <button type="submit" disabled={isSavingProfile} className="btn-primary auth-form-submit">
              저장
            </button>
          </form>
        </section>

        <section className="card profile-section">
          <h2 className="dashboard-section-title">비밀번호 변경</h2>
          <form onSubmit={handlePasswordSubmit} className="auth-form">
            <div className="field">
              <label htmlFor="profile-current-password">현재 비밀번호</label>
              <input
                id="profile-current-password"
                type="password"
                value={currentPassword}
                onChange={(e) => setCurrentPassword(e.target.value)}
                required
              />
            </div>
            <div className="field">
              <label htmlFor="profile-new-password">새 비밀번호</label>
              <input
                id="profile-new-password"
                type="password"
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                minLength={8}
                required
              />
            </div>
            <button type="submit" disabled={isSavingPassword} className="btn-primary auth-form-submit">
              비밀번호 변경
            </button>
          </form>
        </section>
      </div>
    </div>
  )
}
