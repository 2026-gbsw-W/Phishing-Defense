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

  // Stage 3 judgment (docs/PRD.md §14.2.3, §11.1 F3). Ground truth for the
  // MVP's single scenario (SCENARIO_1_1) is always "this is phishing" — no
  // per-scenario lookup table needed since there's only one scenario.
  http.post(`${BASE}/scenarios/:recordId/judgment`, async ({ request, params }) => {
    if (!requireUser(request)) return HttpResponse.json({ message: 'unauthorized' }, { status: 401 })
    const record = mockDb.records.get(Number(params.recordId))
    if (!record) return HttpResponse.json({ message: 'not found' }, { status: 404 })

    const { is_phishing: isPhishing } = (await request.json()) as { is_phishing: boolean }

    if (isPhishing === true) {
      record.judgmentCorrect = true
      record.judgmentTurn = record.currentTurn
      record.stage = 4
      return HttpResponse.json({
        is_correct: true,
        feedback: '정확합니다! 결제 문자와 링크 클릭 유도는 전형적인 스미싱 수법이에요. 다음 단계로 이동합니다.',
        wrong_attempts: record.wrongJudgmentAttempts,
        stage_progression: record.stage,
      })
    }

    // isPhishing === false (wrong)
    if (record.wrongJudgmentAttempts < 1) {
      record.wrongJudgmentAttempts += 1
      return HttpResponse.json({
        is_correct: false,
        feedback: '다시 한 번 생각해보세요. 대화 중 나눈 정보나 링크에 수상한 점은 없었나요?',
        wrong_attempts: record.wrongJudgmentAttempts,
        stage_progression: record.stage,
      })
    }

    record.wrongJudgmentAttempts += 1
    record.judgmentCorrect = false
    record.judgmentTurn = record.currentTurn
    record.stage = 4
    return HttpResponse.json({
      is_correct: false,
      feedback:
        '정답 공개: 이 문자는 사실 피싱이었습니다. 출처 불명의 링크와 계좌번호·비밀번호 요구는 은행이 절대 하지 않는 행동이에요.',
      wrong_attempts: record.wrongJudgmentAttempts,
      stage_progression: record.stage,
    })
  }),
]
