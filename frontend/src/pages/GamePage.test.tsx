import { describe, it, expect } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter, Routes, Route } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { mockDb, tokenForUser } from '@mocks/db'
import { setAuthToken } from '@services/api'
import { gameService } from '@services/gameService'
import { GamePage } from './GamePage'

function renderGamePage(recordId: number) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  return render(
    <QueryClientProvider client={queryClient}>
      <MemoryRouter initialEntries={[`/game/${recordId}`]}>
        <Routes>
          <Route path="/game/:recordId" element={<GamePage />} />
        </Routes>
      </MemoryRouter>
    </QueryClientProvider>,
  )
}

// Goes through the real /scenarios/:scenarioId/start flow (rather than
// mockDb.createRecord directly) so record.chatHistory is seeded with the
// turn-0 initial SMS the way GamePage expects to find it.
async function setup() {
  const user = mockDb.createUser(`game${Math.random()}@test.com`, 'pw123456', '헌터')
  setAuthToken(tokenForUser(user.userId))
  const { recordId } = await gameService.startScenario(101)
  return { user, recordId }
}

describe('GamePage', () => {
  it('renders the Stage 1 SMS content on initial load', async () => {
    const { recordId } = await setup()
    renderGamePage(recordId)

    expect(await screen.findByText(/500,000원이 결제되었습니다/)).toBeInTheDocument()
    expect(screen.getByRole('button', { name: '확인' })).toBeInTheDocument()
  })

  it('transitions to the Stage 2 chat UI when the Stage 1 continue button is clicked', async () => {
    const { recordId } = await setup()
    renderGamePage(recordId)

    await screen.findByText(/500,000원이 결제되었습니다/)
    await userEvent.click(screen.getByRole('button', { name: '확인' }))

    await waitFor(() => {
      expect(screen.getByLabelText('메시지 입력')).toBeInTheDocument()
    })
  })
})
