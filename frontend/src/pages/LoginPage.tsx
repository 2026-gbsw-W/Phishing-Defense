import { useNavigate, Link } from 'react-router-dom'
import toast from 'react-hot-toast'
import { LoginForm } from '@components/auth/LoginForm'
import { useAuth } from '@hooks/useAuth'
import { useAuthStore } from '@stores/authStore'
import type { LoginPayload } from '@/types/auth'

export function LoginPage() {
  const { login, isLoading } = useAuth()
  const navigate = useNavigate()

  const handleSubmit = async (payload: LoginPayload) => {
    await login(payload)
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
        <h1 className="auth-title">다시 만나서 반가워요</h1>
        <LoginForm onSubmit={handleSubmit} isLoading={isLoading} />
        <p className="auth-switch">
          계정이 없나요? <Link to="/signup" className="accent">회원가입</Link>
        </p>
      </div>
    </div>
  )
}
