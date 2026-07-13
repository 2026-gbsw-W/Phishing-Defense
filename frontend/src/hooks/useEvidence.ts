import { useQuery } from '@tanstack/react-query'
import { evidenceService } from '@/services/evidenceService'

export function useEvidenceList(recordId: number) {
  return useQuery({ queryKey: ['evidence', recordId], queryFn: () => evidenceService.getEvidence(recordId) })
}
