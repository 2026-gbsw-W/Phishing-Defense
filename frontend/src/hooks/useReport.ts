import { useQuery } from '@tanstack/react-query'
import { reportService } from '@/services/reportService'

export function useReport(recordId: number) {
  return useQuery({ queryKey: ['report', recordId], queryFn: () => reportService.getReport(recordId) })
}
