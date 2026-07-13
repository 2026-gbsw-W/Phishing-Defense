import { http, HttpResponse } from 'msw'
import { mockDb, userIdFromToken } from '../db'
import { SCENARIO_1_1, INITIAL_SMS } from '../scenarioData'

const BASE = '*/api/v1'

function requireUser(request: Request) {
  return userIdFromToken(request.headers.get('Authorization'))
}

export const gameHandlers = [
  http.get(`${BASE}/chapters`, ({ request }) => {
    if (!requireUser(request)) return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })
    return HttpResponse.json(
      mockDb.chapters.map((c) => ({
        chapter_id: c.chapterId,
        title: c.title,
        difficulty: c.difficulty,
        is_unlocked: c.isUnlocked,
        best_star: c.bestStar,
        is_completed: c.isCompleted,
      })),
    )
  }),

  http.get(`${BASE}/chapters/:chapterId/scenarios`, ({ request }) => {
    if (!requireUser(request)) return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })
    return HttpResponse.json([
      { scenario_id: SCENARIO_1_1.scenarioId, title: SCENARIO_1_1.title, phishing_type: SCENARIO_1_1.phishingType },
    ])
  }),

  http.post(`${BASE}/scenarios/:scenarioId/start`, ({ request }) => {
    const userId = requireUser(request)
    if (!userId) return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })

    const record = mockDb.createRecord(userId, SCENARIO_1_1.scenarioId)
    record.chatHistory.push({ turn: 0, sender: 'ai', message: INITIAL_SMS, timestamp: new Date().toISOString() })

    return HttpResponse.json(
      { record_id: record.recordId, initial_message: INITIAL_SMS, timestamp: new Date().toISOString() },
      { status: 201 },
    )
  }),

  http.get(`${BASE}/scenarios/:recordId/status`, ({ request, params }) => {
    if (!requireUser(request)) return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })
    const record = mockDb.records.get(Number(params.recordId))
    if (!record) return HttpResponse.json({ message: 'not found' }, { status: 404 })

    return HttpResponse.json({
      record_id: record.recordId,
      scenario_id: record.scenarioId,
      stage: record.stage,
      current_turn: record.currentTurn,
      is_completed: record.stage === 6 && record.claimed,
      hints_remaining: record.hintsRemaining,
    })
  }),
]
