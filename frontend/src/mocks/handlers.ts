import type { HttpHandler } from 'msw'
import { authHandlers } from './handlers/auth'
import { gameHandlers } from './handlers/game'
import { chatHandlers } from './handlers/chat'
import { evidenceHandlers } from './handlers/evidence'
import { reportHandlers } from './handlers/report'

export const handlers: HttpHandler[] = [
  ...authHandlers,
  ...gameHandlers,
  ...chatHandlers,
  ...evidenceHandlers,
  ...reportHandlers,
]
