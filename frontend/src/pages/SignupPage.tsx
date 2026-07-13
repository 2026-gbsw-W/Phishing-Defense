import { useNavigate, Link } from 'react-router-dom'
import toast from 'react-hot-toast'
import { SignupForm } from '@components/auth/SignupForm'
import { useAuth } from '@hooks/useAuth'
import { useAuthStore } from '@stores/authStore'
import type { SignupPayload } from '@/types/auth'

export function SignupPage() {
  const { signup, isLoading } = useAuth()
  const navigate = useNavigate()

  const handleSubmit = async (payload: SignupPayload) => {
    await signup(payload)
    const { session, error } = useAuthStore.getState()
    if (error) {
      toast.error(error)
      return
    }
    if (session) {
      navigate('/')
    }
  }

  return (
    <div className="auth-page">
      <div className="card auth-card">
        <span className="eyebrow">PHISHING DEFENSE</span>
        <h1 className="auth-title">피싱 헌터 되기</h1>
        <SignupForm onSubmit={handleSubmit} isLoading={isLoading} />
        <p className="auth-switch">
          이미 계정이 있나요? <Link to="/login" className="accent">로그인</Link>
        </p>
      </div>
    </div>
  )
}
