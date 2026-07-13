import { describe, it, expect, vi } from 'vitest'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { LoginForm } from './LoginForm'

describe('LoginForm', () => {
  it('calls onSubmit with entered credentials', async () => {
    const onSubmit = vi.fn().mockResolvedValue(undefined)
    render(<LoginForm onSubmit={onSubmit} isLoading={false} />)

    await userEvent.type(screen.getByLabelText('이메일'), 'a@test.com')
    await userEvent.type(screen.getByLabelText('비밀번호'), 'pw123456')
    await userEvent.click(screen.getByRole('button', { name: '로그인' }))

    expect(onSubmit).toHaveBeenCalledWith({ email: 'a@test.com', password: 'pw123456' })
  })
})
