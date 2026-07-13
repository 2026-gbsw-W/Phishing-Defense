import { useQuery } from '@tanstack/react-query'
import { gameService } from '@/services/gameService'

export function useScenarioStatus(recordId: number | null) {
  return useQuery({
    queryKey: ['scenario-status', recordId],
    queryFn: () => gameService.getStatus(recordId as number),
    enabled: recordId !== null,
  })
}
