import { describe, it, expect, vi } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { mockDb, tokenForUser } from '@mocks/db'
import { setAuthToken } from '@services/api'
import { Stage5_Report } from './Stage5_Report'

function setup() {
  const user = mockDb.createUser(`report${Math.random()}@test.com`, 'pw123456', '헌터')
  setAuthToken(tokenForUser(user.userId))
  const record = mockDb.createRecord(user.userId, 101)
  // Simulate a record that already went through Stage 2's criminal chat —
  // this leftover history must NOT leak into the Stage 5 police-report view.
  record.chatHistory.push({
    turn: 1,
    sender: 'ai',
    message: '저는 발신 번호 050-1234-5678로 연락드리고 있고요',
    timestamp: new Date().toISOString(),
    stage: 2,
  })
  record.stage = 5
  return { user, record }
}

describe('Stage5_Report', () => {
  it('does not render leftover Stage 2 criminal chat history', async () => {
    const { record } = setup()
    render(<Stage5_Report recordId={record.recordId} onComplete={vi.fn()} />)

    // Wait for the initial history fetch to settle (confirmed by the
    // empty-state prompt, since the Stage 2 message is filtered out) before
    // asserting the Stage 2 message never appears.
    await waitFor(() => {
      expect(screen.getByText('신고할 내용을 입력해 대화를 시작하세요.')).toBeInTheDocument()
    })
    expect(screen.queryByText(/050-1234-5678/)).not.toBeInTheDocument()
  })

  it('sends a message and renders the user message + scripted police reply', async () => {
    const { record } = setup()
    render(<Stage5_Report recordId={record.recordId} onComplete={vi.fn()} />)

    await userEvent.type(screen.getByLabelText('메시지 입력'), '신고합니다')
    await userEvent.click(screen.getByRole('button', { name: '전송' }))

    expect(await screen.findByText('신고합니다')).toBeInTheDocument()
    await waitFor(() => {
      expect(screen.getByText(/사이버범죄수사팀/)).toBeInTheDocument()
    })
  })

  it('disables "신고 완료" until the user has sent at least one message', async () => {
    const { record } = setup()
    render(<Stage5_Report recordId={record.recordId} onComplete={vi.fn()} />)

    await waitFor(() => {
      expect(screen.getByText('신고할 내용을 입력해 대화를 시작하세요.')).toBeInTheDocument()
    })
    expect(screen.getByRole('button', { name: '신고 완료' })).toBeDisabled()
  })

  it('calls onComplete when "신고 완료" is clicked after sending a message', async () => {
    const { record } = setup()
    const onComplete = vi.fn()
    render(<Stage5_Report recordId={record.recordId} onComplete={onComplete} />)

    await userEvent.type(screen.getByLabelText('메시지 입력'), '신고합니다')
    await userEvent.click(screen.getByRole('button', { name: '전송' }))
    await screen.findByText(/사이버범죄수사팀/)

    await userEvent.click(screen.getByRole('button', { name: '신고 완료' }))

    expect(onComplete).toHaveBeenCalledTimes(1)
  })
})
