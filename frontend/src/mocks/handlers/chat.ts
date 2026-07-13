import { http, HttpResponse } from 'msw'
import { mockDb, userIdFromToken } from '../db'
import { criminalReplyForTurn, policeReplyForTurn, HINT_TEXTS } from '../scenarioData'
import type { EvidenceType, Stage } from '@/types/game'

const BASE = '*/api/v1'

// Ports docs/PRD.md §17.2 guess_type() — a lightweight heuristic to suggest
// an evidence type for a user-marked chat excerpt. Never authoritative;
// the user/report logic may override it later.
function guessEvidenceType(value: string): EvidenceType {
  if (/\d{3}-\d{4}-\d{4}/.test(value)) return 'phone_number'
  if (['지금', '바로', '급함'].some((kw) => value.includes(kw))) return 'urgency'
  return 'etc'
}

export const chatHandlers = [
  http.post(`${BASE}/chat/:recordId/send`, async ({ request, params }) => {
    if (!userIdFromToken(request.headers.get('Authorization'))) {
      return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })
    }
    const record = mockDb.records.get(Number(params.recordId))
    if (!record) return HttpResponse.json({ message: 'not found' }, { status: 404 })

    const { message, stage } = (await request.json()) as { message: string; stage: Stage }
    const turn = record.currentTurn + 1
    const now = new Date().toISOString()

    record.chatHistory.push({ turn, sender: 'user', message, timestamp: now, stage })

    const isPolice = stage === 5
    const aiReply = isPolice ? policeReplyForTurn(turn) : criminalReplyForTurn(turn)
    record.chatHistory.push({ turn, sender: 'ai', message: aiReply, timestamp: now, stage })

    record.currentTurn = turn
    if (isPolice) record.policeTurnsCompleted = turn
    // Keep record.stage in sync with the stage the client is actually chatting
    // in — nothing else advances it during Stage 2/5 chat, which otherwise
    // leaves the hint handler's HINT_TEXTS[record.stage] lookup stuck on stage
    // 1 for the whole run. Math.max guards against ever regressing it backward.
    record.stage = Math.max(record.stage, stage) as Stage

    return HttpResponse.json(
      {
        ai_response: aiReply,
        turn,
        hint_available: record.hintsRemaining > 0,
      },
      { status: 201 },
    )
  }),

  http.get(`${BASE}/chat/:recordId/history`, ({ request, params }) => {
    if (!userIdFromToken(request.headers.get('Authorization'))) {
      return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })
    }
    const record = mockDb.records.get(Number(params.recordId))
    if (!record) return HttpResponse.json({ message: 'not found' }, { status: 404 })

    return HttpResponse.json(
      record.chatHistory.map((m) => ({
        turn: m.turn,
        sender: m.sender,
        message: m.message,
        timestamp: m.timestamp,
        stage: m.stage,
      })),
    )
  }),

  http.post(`${BASE}/chat/:recordId/hint`, ({ request, params }) => {
    if (!userIdFromToken(request.headers.get('Authorization'))) {
      return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })
    }
    const record = mockDb.records.get(Number(params.recordId))
    if (!record) return HttpResponse.json({ message: 'not found' }, { status: 404 })
    if (record.hintsRemaining <= 0) {
      return HttpResponse.json({ message: '남은 힌트가 없습니다.' }, { status: 400 })
    }

    record.hintsUsed += 1
    record.hintsRemaining -= 1

    return HttpResponse.json({ hint_text: HINT_TEXTS[record.stage], remaining_hints: record.hintsRemaining })
  }),

  http.post(`${BASE}/chat/:recordId/evidence/mark`, async ({ request, params }) => {
    if (!userIdFromToken(request.headers.get('Authorization'))) {
      return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })
    }
    const record = mockDb.records.get(Number(params.recordId))
    if (!record) return HttpResponse.json({ message: 'not found' }, { status: 404 })

    const { turn, evidence_value: evidenceValue } = (await request.json()) as { turn: number; evidence_value: string }
    const typeGuess = guessEvidenceType(evidenceValue)

    const evidence = mockDb.addEvidence(record, {
      evidenceId: mockDb.nextEvidenceId(),
      type: typeGuess,
      value: evidenceValue,
      turn,
      isSubmitted: false,
      isValid: null,
      validityReason: null,
      importanceLevel: null,
    })

    return HttpResponse.json(
      { evidence_id: evidence.evidenceId, evidence_type_guess: typeGuess, saved: true },
      { status: 201 },
    )
  }),
]
