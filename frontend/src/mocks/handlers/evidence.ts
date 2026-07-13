import { http, HttpResponse } from 'msw'
import { mockDb, userIdFromToken } from '../db'

const BASE = '*/api/v1'

// Stage 4 (docs/PRD.md §14.2.3, §11.1 F2): lists and submits the evidence the
// user already self-collected during Stage 2 chat (evidence/mark handler in
// chat.ts). This module never creates evidence, only reads/marks it.
export const evidenceHandlers = [
  http.get(`${BASE}/scenarios/:recordId/evidence`, ({ request, params }) => {
    if (!userIdFromToken(request.headers.get('Authorization'))) {
      return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })
    }
    const record = mockDb.records.get(Number(params.recordId))
    if (!record) return HttpResponse.json({ message: 'not found' }, { status: 404 })

    return HttpResponse.json(
      record.evidence.map((e) => ({
        evidence_id: e.evidenceId,
        type: e.type,
        value: e.value,
        turn: e.turn,
      })),
    )
  }),

  http.post(`${BASE}/scenarios/:recordId/evidence/submit`, async ({ request, params }) => {
    if (!userIdFromToken(request.headers.get('Authorization'))) {
      return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })
    }
    const record = mockDb.records.get(Number(params.recordId))
    if (!record) return HttpResponse.json({ message: 'not found' }, { status: 404 })

    const { evidence_ids: evidenceIds } = (await request.json()) as { evidence_ids: number[] }

    let submittedCount = 0
    for (const id of evidenceIds) {
      const entry = record.evidence.find((e) => e.evidenceId === id)
      if (entry) {
        entry.isSubmitted = true
        submittedCount += 1
      }
    }

    return HttpResponse.json({ submitted_count: submittedCount })
  }),
]
