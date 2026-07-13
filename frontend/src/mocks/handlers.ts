import type { HttpHandler } from 'msw'
import { authHandlers } from './handlers/auth'
import { gameHandlers } from './handlers/game'

export const handlers: HttpHandler[] = [...authHandlers, ...gameHandlers]
