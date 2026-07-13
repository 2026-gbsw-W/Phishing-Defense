import { useState, type FormEvent } from 'react'
import type { SignupPayload } from '@/types/auth'

interface SignupFormProps {
  onSubmit: (payload: SignupPayload) => Promise<void>
  isLoading: boolean
}

export function SignupForm({ onSubmit, isLoading }: SignupFormProps) {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [nickname, setNickname] = useState('')

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault()
    onSubmit({ email, password, nickname })
  }

  return (
    <form onSubmit={handleSubmit} className="auth-form">
      <div className="field">
        <label htmlFor="signup-nickname">닉네임</label>
        <input
          id="signup-nickname"
          value={nickname}
          onChange={(e) => setNickname(e.target.value)}
          required
        />
      </div>
      <div className="field">
        <label htmlFor="signup-email">이메일</label>
        <input
          id="signup-email"
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
        />
      </div>
      <div className="field">
        <label htmlFor="signup-password">비밀번호</label>
        <input
          id="signup-password"
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
          minLength={8}
        />
      </div>
      <button type="submit" disabled={isLoading} className="btn-primary auth-form-submit">
        회원가입
      </button>
    </form>
  )
}
