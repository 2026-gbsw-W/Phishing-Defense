import { create } from 'zustand'

interface GameState {
  recordId: number | null
  startedAt: number | null
  hintsUsedThisRun: number
  start: (recordId: number) => void
  incrementHint: () => void
  elapsedSeconds: () => number
  reset: () => void
}

export const useGameStore = create<GameState>((set, get) => ({
  recordId: null,
  startedAt: null,
  hintsUsedThisRun: 0,

  start: (recordId) => set({ recordId, startedAt: Date.now(), hintsUsedThisRun: 0 }),
  incrementHint: () => set((s) => ({ hintsUsedThisRun: s.hintsUsedThisRun + 1 })),
  elapsedSeconds: () => {
    const startedAt = get().startedAt
    return startedAt ? Math.floor((Date.now() - startedAt) / 1000) : 0
  },
  reset: () => set({ recordId: null, startedAt: null, hintsUsedThisRun: 0 }),
}))
