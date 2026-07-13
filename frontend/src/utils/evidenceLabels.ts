// Short Korean labels for the evidence types the backend's rule-based
// extractor actually tags (confirmed against a live run: url_click, urgency,
// personal_info, plus a few more plausible ones from docs/PRD.md §17 kept as
// a safety net). Falls back to the raw type string for anything unlisted, so
// an unrecognized type from the backend never crashes the UI.
export const EVIDENCE_TYPE_LABELS: Record<string, string> = {
  url_click: '의심 링크 클릭 유도',
  urgency: '긴급성 유도',
  personal_info: '개인정보/금융정보 요구',
  phone_number: '전화번호',
  account_number: '계좌번호',
  impersonation: '기관 사칭',
  name: '이름',
  email: '이메일',
  amount_mentioned: '금액',
  suspicious_url: '의심 URL',
  transaction_request: '송금 요구',
  etc: '기타',
}

export function evidenceTypeLabel(type: string): string {
  return EVIDENCE_TYPE_LABELS[type] ?? type
}
