import { describe, it, expect, vi } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { mockDb, tokenForUser } from '@mocks/db'
import { setAuthToken } from '@services/api'
import { Stage3_Judgment } from './Stage3_Judgment'

function setup() {
  const user = mockDb.createUser(`judge${Math.random()}@test.com`, 'pw123456', '헌터')
  setAuthToken(tokenForUser(user.userId))
  const record = mockDb.createRecord(user.userId, 101)
  record.stage = 3
  return { user, record }
}

describe('Stage3_Judgment', () => {
  it('calls onProceed with the new stage when the correct choice is made', async () => {
    const { record } = setup()
    const onProceed = vi.fn()
    render(<Stage3_Judgment recordId={record.recordId} onProceed={onProceed} />)

    await userEvent.click(screen.getByRole('button', { name: '피싱이 맞습니다' }))

    await waitFor(() => {
      expect(screen.getByText(/정확합니다/)).toBeInTheDocument()
    })

    await userEvent.click(screen.getByRole('button', { name: '다음으로' }))
    expect(onProceed).toHaveBeenCalledWith(4)
  })

  it('shows feedback and does not proceed after a single wrong choice', async () => {
    const { record } = setup()
    const onProceed = vi.fn()
    render(<Stage3_Judgment recordId={record.recordId} onProceed={onProceed} />)

    await userEvent.click(screen.getByRole('button', { name: '정상적인 문자입니다' }))

    await waitFor(() => {
      expect(screen.getByText(/다시 한 번 생각해보세요/)).toBeInTheDocument()
    })

    expect(onProceed).not.toHaveBeenCalled()
    expect(screen.getByRole('button', { name: '피싱이 맞습니다' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: '정상적인 문자입니다' })).toBeInTheDocument()
  })

  it('eventually calls onProceed after two wrong choices reveal the answer', async () => {
    const { record } = setup()
    const onProceed = vi.fn()
    render(<Stage3_Judgment recordId={record.recordId} onProceed={onProceed} />)

    await userEvent.click(screen.getByRole('button', { name: '정상적인 문자입니다' }))
    await waitFor(() => {
      expect(screen.getByText(/다시 한 번 생각해보세요/)).toBeInTheDocument()
    })

    await userEvent.click(screen.getByRole('button', { name: '정상적인 문자입니다' }))
    await waitFor(() => {
      expect(screen.getByText(/정답 공개/)).toBeInTheDocument()
    })

    expect(onProceed).not.toHaveBeenCalled()
    await userEvent.click(screen.getByRole('button', { name: '다음으로' }))
    expect(onProceed).toHaveBeenCalledWith(4)
  })
})
