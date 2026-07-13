import type { HttpHandler } from 'msw'
import { authHandlers } from './handlers/auth'

export const handlers: HttpHandler[] = [...authHandlers]
