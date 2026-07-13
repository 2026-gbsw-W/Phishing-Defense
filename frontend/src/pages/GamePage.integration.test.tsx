import { describe, it, expect } from 'vitest'
import { render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter, Routes, Route } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { mockDb, tokenForUser } from '@mocks/db'
import { setAuthToken } from '@services/api'
import { gameService } from '@services/gameService'
import { useAuthStore } from '@stores/authStore'
import { policeReplyForTurn } from '@mocks/scenarioData'
import { GamePage } from './GamePage'

// Capstone end-to-end test: plays the entire Chapter 1 / Scenario 101 run
// through the REAL GamePage router and all 6 real stage components against
// the real MSW mock server, proving the whole wired-together flow works —
// not just each stage in isolation (each stage already has its own
// unit/component tests; this test's only job is the wiring between them).
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

describe('GamePage integration — full Chapter 1 / Scenario 101 playthrough', () => {
  it(
    'plays SMS -> chat -> judgment -> evidence -> report -> result end to end, awarding XP and completing the record',
    async () => {
      // --- Setup: real signup-less user + real /scenarios/101/start flow ---
      const user = mockDb.createUser(`capstone${Math.random()}@test.com`, 'pw123456', '헌터')
      setAuthToken(tokenForUser(user.userId))
      // Seed the auth store the way a real login/hydrate would, so Stage 6's
      // claim -> useAuthStore.getState().updateXp(...) sync has a session to
      // update (mirrors Stage6_Result.test.tsx's claim-flow setup).
      useAuthStore.setState({
        session: {
          token: tokenForUser(user.userId),
          userId: user.userId,
          email: user.email,
          nickname: user.nickname,
          level: 1,
          currentXp: 0,
          totalXp: 0,
          bio: null,
          profileImageUrl: null,
        },
      })

      const { recordId } = await gameService.startScenario(101)

      renderGamePage(recordId)

      // --- Stage 1: SMS ---
      expect(await screen.findByText(/500,000원이 결제되었습니다/)).toBeInTheDocument()
      await userEvent.click(screen.getByRole('button', { name: '확인' }))

      // --- Stage 2: Chat ---
      const chatInput = await screen.findByLabelText('메시지 입력')
      await userEvent.type(chatInput, '누구세요?')
      await userEvent.click(screen.getByRole('button', { name: '전송' }))

      // Turn 1's scripted criminal reply contains the phone number
      // ('050-1234-5678') that matches a GROUND_TRUTH_EVIDENCE entry — mark
      // that message as evidence so Stage 4/6 have something valid to find.
      const criminalReplyText = await screen.findByText(/050-1234-5678/)
      const criminalBubble = criminalReplyText.closest('.stage2-chat-bubble') as HTMLElement
      await userEvent.click(within(criminalBubble).getByRole('button', { name: '증거로 저장' }))
      await waitFor(() => {
        expect(within(criminalBubble).getByRole('button', { name: '증거로 저장됨' })).toBeInTheDocument()
      })

      await userEvent.click(screen.getByRole('button', { name: '판단하러 가기' }))

      // --- Stage 3: Judgment ---
      // "피싱이 맞습니다" is the phishing choice — SCENARIO_1_1 IS phishing,
      // so this is the correct answer (docs/PRD.md; confirmed against the
      // /scenarios/:recordId/judgment mock handler's `isPhishing === true`
      // branch, which is the only branch that sets is_correct: true).
      await userEvent.click(await screen.findByRole('button', { name: '피싱이 맞습니다' }))
      await screen.findByText(/정확합니다/)
      await userEvent.click(screen.getByRole('button', { name: '다음으로' }))

      // --- Stage 4: Evidence ---
      const evidenceCheckbox = await screen.findByRole('checkbox')
      await userEvent.click(evidenceCheckbox)
      await userEvent.click(screen.getByRole('button', { name: '제출하고 계속하기' }))

      // --- Stage 5: Report ---
      // NOTE: record.currentTurn is a single counter shared across Stage 2's
      // criminal chat AND Stage 5's police chat (see chat.ts's `send` handler
      // and its comment on keeping record.stage in sync) — it is NOT reset
      // per stage. Since this test already sent one Stage 2 message before
      // reaching here, this first Stage 5 message lands on turn 2, not turn
      // 1, so the scripted reply is POLICE_REPLIES[2] rather than
      // POLICE_REPLIES[1]'s "사이버범죄수사팀" text. Rather than hardcode an
      // assumed turn number, compute the actually-expected reply from the
      // same scenario-data function the mock handler uses (captured BEFORE
      // sending, since the send bumps currentTurn), so this assertion stays
      // correct regardless of exactly how many turns preceded it.
      const recordBeforeStage5Send = mockDb.records.get(recordId)!
      const expectedPoliceReply = policeReplyForTurn(recordBeforeStage5Send.currentTurn + 1)

      const reportInput = await screen.findByLabelText('메시지 입력')
      await userEvent.type(reportInput, '신고합니다')
      await userEvent.click(screen.getByRole('button', { name: '전송' }))

      await screen.findByText(expectedPoliceReply)

      await waitFor(() => {
        expect(screen.getByRole('button', { name: '신고 완료' })).toBeEnabled()
      })
      await userEvent.click(screen.getByRole('button', { name: '신고 완료' }))

      // --- Stage 6: Result ---
      // Loose assertions on purpose — Task 21's own tests already verify the
      // scoring formulas in detail; this test's job is proving the flow
      // reaches Stage 6 with a rendered report at all.
      await waitFor(() => {
        expect(screen.getByText(/정확도/)).toBeInTheDocument()
      })
      expect(screen.getByLabelText(/별점/)).toBeInTheDocument()

      expect(useAuthStore.getState().session?.totalXp).toBe(0)
      await userEvent.click(screen.getByRole('button', { name: '보상 받기' }))
      await waitFor(() => {
        expect(screen.getByText(/XP 획득/)).toBeInTheDocument()
      })

      // --- Final assertions ---
      // 1. XP was synced into the global auth session after claiming.
      expect(useAuthStore.getState().session?.totalXp).toBeGreaterThan(0)

      // 2. The record's terminal state is correct via the real status
      // endpoint (exercises the Task 22 completion fix: is_completed is
      // (stage === 6 && claimed), which is only reachable by actually
      // claiming the reward through this real flow).
      const status = await gameService.getStatus(recordId)
      expect(status.isCompleted).toBe(true)
      expect(mockDb.records.get(recordId)!.claimed).toBe(true)
    },
    20000,
  )
})
