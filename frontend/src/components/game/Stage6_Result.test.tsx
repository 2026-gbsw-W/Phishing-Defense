import type { ReactElement } from 'react'
import { describe, it, expect, vi } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { mockDb, tokenForUser } from '@mocks/db'
import { setAuthToken } from '@services/api'
import { useAuthStore } from '@stores/authStore'
import { Stage6_Result } from './Stage6_Result'

function renderWithQueryClient(ui: ReactElement) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  return render(<QueryClientProvider client={queryClient}>{ui}</QueryClientProvider>)
}

function setup() {
  const user = mockDb.createUser(`stage6${Math.random()}@test.com`, 'pw123456', '헌터')
  setAuthToken(tokenForUser(user.userId))
  const record = mockDb.createRecord(user.userId, 101)
  record.stage = 6
  record.judgmentCorrect = true
  record.judgmentTurn = 2
  record.wrongJudgmentAttempts = 0
  record.policeTurnsCompleted = 2
  record.hintsUsed = 0

  // Matches GROUND_TRUTH_EVIDENCE's '050-1234-5678' phone number entry —
  // one valid, submitted piece of evidence out of several ground-truth items.
  mockDb.addEvidence(record, {
    evidenceId: mockDb.nextEvidenceId(),
    type: 'phone_number',
    value: '050-1234-5678',
    turn: 1,
    isSubmitted: true,
    isValid: null,
    validityReason: null,
    importanceLevel: null,
  })

  return { user, record }
}

describe('Stage6_Result', () => {
  it('renders the report with star rating, accuracy, and a valid verdict', async () => {
    const { record } = setup()
    renderWithQueryClient(<Stage6_Result recordId={record.recordId} onClaimed={vi.fn()} />)

    await waitFor(() => {
      expect(screen.getByText('050-1234-5678')).toBeInTheDocument()
    })
    expect(screen.getByLabelText(/별점/)).toBeInTheDocument()
    expect(screen.getByText(/정확도/)).toBeInTheDocument()
    expect(screen.getByText('✅')).toBeInTheDocument()
  })

  it('shows the missed evidence list for ground-truth items that were never submitted', async () => {
    const { record } = setup()
    renderWithQueryClient(<Stage6_Result recordId={record.recordId} onClaimed={vi.fn()} />)

    await waitFor(() => {
      expect(screen.getByText('놓친 증거')).toBeInTheDocument()
    })
    expect(screen.getByText('국민은행 사칭')).toBeInTheDocument()
  })

  it('claiming the reward shows XP gained, updates the auth session, and calling 완료 fires onClaimed', async () => {
    const { user, record } = setup()
    useAuthStore.setState({
      session: {
        token: tokenForUser(user.userId),
        userId: user.userId,
        nickname: user.nickname,
        level: 1,
        totalXp: 0,
      },
    })
    const onClaimed = vi.fn()

    renderWithQueryClient(<Stage6_Result recordId={record.recordId} onClaimed={onClaimed} />)

    await waitFor(() => {
      expect(screen.getByRole('button', { name: '보상 받기' })).toBeInTheDocument()
    })

    const claimButton = screen.getByRole('button', { name: '보상 받기' })
    await userEvent.click(claimButton)

    await waitFor(() => {
      expect(screen.getByText(/XP 획득/)).toBeInTheDocument()
    })
    // Claim button becomes disabled/relabeled so it can't be clicked again.
    expect(screen.getByRole('button', { name: '수령 완료' })).toBeDisabled()
    expect(useAuthStore.getState().session?.totalXp).toBeGreaterThan(0)
    expect(mockDb.records.get(record.recordId)!.claimed).toBe(true)

    await userEvent.click(screen.getByRole('button', { name: '완료' }))
    expect(onClaimed).toHaveBeenCalledTimes(1)
  })
})
