import { http, HttpResponse } from 'msw'
import { mockDb, userIdFromToken } from '../db'
import { criminalReplyForTurn, policeReplyForTurn, AUTO_EVIDENCE_BY_TURN, HINT_TEXTS } from '../scenarioData'
import type { Stage } from '@/types/game'

const BASE = '*/api/v1'

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

    record.chatHistory.push({ turn, sender: 'user', message, timestamp: now })

    const isPolice = stage === 5
    const aiReply = isPolice ? policeReplyForTurn(turn) : criminalReplyForTurn(turn)
    record.chatHistory.push({ turn, sender: 'ai', message: aiReply, timestamp: now })

    record.currentTurn = turn
    if (isPolice) record.policeTurnsCompleted = turn

    const extractedEvidence = AUTO_EVIDENCE_BY_TURN[turn] ?? []
    const stageComplete = isPolice ? turn >= 2 : turn >= 2

    return HttpResponse.json(
      {
        ai_response: aiReply,
        turn,
        extracted_evidence: extractedEvidence,
        hints_remaining: record.hintsRemaining,
        stage_complete: stageComplete,
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
      record.chatHistory.map((m) => ({ turn: m.turn, sender: m.sender, message: m.message, timestamp: m.timestamp })),
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

    return HttpResponse.json({ hint_text: HINT_TEXTS[record.stage], hints_remaining: record.hintsRemaining })
  }),
]
