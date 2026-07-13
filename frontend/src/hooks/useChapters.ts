import { useQuery } from '@tanstack/react-query'
import { gameService } from '@/services/gameService'

export function useChapters() {
  return useQuery({ queryKey: ['chapters'], queryFn: gameService.getChapters })
}
