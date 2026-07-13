import type { ReactElement } from 'react'
import { describe, it, expect, vi } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { mockDb, tokenForUser } from '@mocks/db'
import { setAuthToken } from '@services/api'
import { Stage4_Evidence } from './Stage4_Evidence'

function renderWithQueryClient(ui: ReactElement) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  return render(<QueryClientProvider client={queryClient}>{ui}</QueryClientProvider>)
}

function setup() {
  const user = mockDb.createUser(`evidence${Math.random()}@test.com`, 'pw123456', '헌터')
  setAuthToken(tokenForUser(user.userId))
  const record = mockDb.createRecord(user.userId, 101)
  record.stage = 4
  return { user, record }
}

describe('Stage4_Evidence', () => {
  it('renders the evidence collected during Stage 2 chat', async () => {
    const { record } = setup()
    mockDb.addEvidence(record, {
      evidenceId: mockDb.nextEvidenceId(),
      type: 'phone_number',
      value: '050-1234-5678',
      turn: 1,
      isSubmitted: false,
      isValid: null,
      validityReason: null,
      importanceLevel: null,
    })
    mockDb.addEvidence(record, {
      evidenceId: mockDb.nextEvidenceId(),
      type: 'urgency',
      value: '지금 바로 계좌번호를 알려주세요',
      turn: 2,
      isSubmitted: false,
      isValid: null,
      validityReason: null,
      importanceLevel: null,
    })

    renderWithQueryClient(<Stage4_Evidence recordId={record.recordId} onProceed={vi.fn()} />)

    await waitFor(() => {
      expect(screen.getByText('050-1234-5678')).toBeInTheDocument()
    })
    expect(screen.getByText('지금 바로 계좌번호를 알려주세요')).toBeInTheDocument()
  })

  it('selecting items and submitting calls through to onProceed', async () => {
    const { record } = setup()
    const evidence = mockDb.addEvidence(record, {
      evidenceId: mockDb.nextEvidenceId(),
      type: 'phone_number',
      value: '050-1234-5678',
      turn: 1,
      isSubmitted: false,
      isValid: null,
      validityReason: null,
      importanceLevel: null,
    })
    const onProceed = vi.fn()

    renderWithQueryClient(<Stage4_Evidence recordId={record.recordId} onProceed={onProceed} />)

    await waitFor(() => {
      expect(screen.getByText('050-1234-5678')).toBeInTheDocument()
    })

    const checkbox = screen.getByRole('checkbox')
    await userEvent.click(checkbox)
    expect(checkbox).toBeChecked()

    await userEvent.click(screen.getByRole('button', { name: '제출하고 계속하기' }))

    await waitFor(() => {
      expect(onProceed).toHaveBeenCalledTimes(1)
    })
    expect(mockDb.records.get(record.recordId)!.evidence.find((e) => e.evidenceId === evidence.evidenceId)!.isSubmitted).toBe(
      true,
    )
  })

  it('shows the empty-evidence fallback and still allows proceeding', async () => {
    const { record } = setup()
    const onProceed = vi.fn()

    renderWithQueryClient(<Stage4_Evidence recordId={record.recordId} onProceed={onProceed} />)

    await waitFor(() => {
      expect(screen.getByText('저장한 증거가 없습니다. 그래도 신고를 진행할 수 있어요.')).toBeInTheDocument()
    })
    expect(screen.queryByRole('checkbox')).not.toBeInTheDocument()

    await userEvent.click(screen.getByRole('button', { name: '제출하고 계속하기' }))

    await waitFor(() => {
      expect(onProceed).toHaveBeenCalledTimes(1)
    })
  })
})
