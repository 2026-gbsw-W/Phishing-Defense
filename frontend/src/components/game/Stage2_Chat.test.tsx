import { describe, it, expect, vi } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { mockDb, tokenForUser } from '@mocks/db'
import { setAuthToken } from '@services/api'
import { Stage2_Chat } from './Stage2_Chat'

function setup() {
  const user = mockDb.createUser(`chat${Math.random()}@test.com`, 'pw123456', '헌터')
  setAuthToken(tokenForUser(user.userId))
  const record = mockDb.createRecord(user.userId, 101)
  // The mock hint handler keys HINT_TEXTS off record.stage; simulate the
  // record already having progressed to Stage 2 (no "advance stage" mock
  // endpoint exists yet to do this via HTTP).
  record.stage = 2
  return { user, record }
}

describe('Stage2_Chat', () => {
  it('sends a message and renders the user message + scripted AI reply', async () => {
    const { record } = setup()
    render(<Stage2_Chat recordId={record.recordId} onProceedToJudgment={vi.fn()} />)

    await userEvent.type(screen.getByLabelText('메시지 입력'), '누구세요?')
    await userEvent.click(screen.getByRole('button', { name: '전송' }))

    expect(await screen.findByText('누구세요?')).toBeInTheDocument()
    await waitFor(() => {
      expect(screen.getByText(/본인 확인/)).toBeInTheDocument()
    })
  })

  it('marks a message as evidence and shows a visible confirmation', async () => {
    const { record } = setup()
    render(<Stage2_Chat recordId={record.recordId} onProceedToJudgment={vi.fn()} />)

    await userEvent.type(screen.getByLabelText('메시지 입력'), '누구세요?')
    await userEvent.click(screen.getByRole('button', { name: '전송' }))
    await screen.findByText(/본인 확인/)

    const markButtons = await screen.findAllByRole('button', { name: '증거로 저장' })
    await userEvent.click(markButtons[0])

    await waitFor(() => {
      expect(screen.getAllByRole('button', { name: '증거로 저장됨' }).length).toBeGreaterThan(0)
    })
  })

  it('calls onProceedToJudgment when the judgment button is clicked', async () => {
    const { record } = setup()
    const onProceedToJudgment = vi.fn()
    render(<Stage2_Chat recordId={record.recordId} onProceedToJudgment={onProceedToJudgment} />)

    await userEvent.click(screen.getByRole('button', { name: '판단하러 가기' }))

    expect(onProceedToJudgment).toHaveBeenCalledTimes(1)
  })

  it('requests a hint and displays the hint text', async () => {
    const { record } = setup()
    render(<Stage2_Chat recordId={record.recordId} onProceedToJudgment={vi.fn()} />)

    await userEvent.click(screen.getByRole('button', { name: '힌트 요청' }))

    await waitFor(() => {
      expect(screen.getByText(/채팅으로 비밀번호/)).toBeInTheDocument()
    })
  })
})
