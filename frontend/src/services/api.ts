import axios, { type InternalAxiosRequestConfig } from 'axios'
import { ApiError } from '@/types/api'

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  headers: { 'Content-Type': 'application/json' },
})

let authToken: string | null = null
let refreshToken: string | null = null
let onTokensRefreshed: ((accessToken: string, refreshToken: string) => void) | null = null
let onRefreshFailed: (() => void) | null = null

export function setAuthToken(token: string | null) {
  authToken = token
}

export function setRefreshToken(token: string | null) {
  refreshToken = token
}

/** Wired up once by authStore so a successful/failed silent refresh can
 * persist the new tokens (or clear the session) without api.ts depending
 * on the store directly (that would be a circular import). */
export function setTokenRefreshHandlers(handlers: {
  onRefreshed: (accessToken: string, refreshToken: string) => void
  onFailed: () => void
}) {
  onTokensRefreshed = handlers.onRefreshed
  onRefreshFailed = handlers.onFailed
}

apiClient.interceptors.request.use((config) => {
  if (authToken) {
    config.headers.Authorization = `Bearer ${authToken}`
  }
  return config
})

interface RetriableConfig extends InternalAxiosRequestConfig {
  _retriedAfterRefresh?: boolean
}

interface RefreshWireResponse {
  accessToken: string
  refreshToken: string
}

apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const status = error.response?.status
    // Spring Security here has no custom AuthenticationEntryPoint, so an
    // expired/invalid/missing JWT comes back as 403, not 401 — confirmed
    // empirically by the mobile client. Treat both as "needs a refresh".
    const isAuthFailure = status === 401 || status === 403
    const original = error.config as RetriableConfig | undefined

    if (isAuthFailure && refreshToken && original && !original._retriedAfterRefresh) {
      original._retriedAfterRefresh = true
      try {
        const { data } = await axios.post<RefreshWireResponse>(
          `${import.meta.env.VITE_API_BASE_URL}/api/v1/auth/refresh`,
          { refreshToken },
        )
        authToken = data.accessToken
        refreshToken = data.refreshToken
        onTokensRefreshed?.(data.accessToken, data.refreshToken)
        original.headers.Authorization = `Bearer ${authToken}`
        return apiClient(original)
      } catch (refreshErr) {
        onRefreshFailed?.()
        return Promise.reject(refreshErr)
      }
    }

    if (error.response) {
      return Promise.reject(new ApiError(error.response.status, error.response.data))
    }
    return Promise.reject(error)
  },
)
