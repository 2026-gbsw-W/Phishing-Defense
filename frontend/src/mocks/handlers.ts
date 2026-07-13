import type { HttpHandler } from 'msw'
import { authHandlers } from './handlers/auth'
import { userHandlers } from './handlers/user'

// Only auth + profile are mocked — the real game flow (chapters, scenarios,
// chat, evidence, judgment, report) talks to the actual Spring backend + AI
// service now (docs/PRD.md §14), not MSW.
export const handlers: HttpHandler[] = [...authHandlers, ...userHandlers]
