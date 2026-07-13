// Chapter 1 / Scenario 1-1 script: 은행 사칭 스미싱 (docs/PRD.md §12.3.1).
// Evidence is never auto-extracted — the player marks it themselves during
// the chat (Stage 2), and this module only holds the "ground truth" list
// used to judge what they submitted at Stage 6 (docs/PRD.md §11.1 F2/F5,
// §17).
import type { Chapter, Scenario, Stage } from '@/types/game'

export const CHAPTERS: Chapter[] = [
  { chapterId: 1, title: '기초 스미싱 사건', difficulty: 1, isUnlocked: true, bestStar: 0, isCompleted: false },
  { chapterId: 2, title: '택배 사칭 사건', difficulty: 2, isUnlocked: false, bestStar: 0, isCompleted: false },
  { chapterId: 3, title: '가족 사칭 사건', difficulty: 2, isUnlocked: false, bestStar: 0, isCompleted: false },
  { chapterId: 4, title: '금융기관 사칭 사건', difficulty: 3, isUnlocked: false, bestStar: 0, isCompleted: false },
  { chapterId: 5, title: '검찰 사칭 사건', difficulty: 3, isUnlocked: false, bestStar: 0, isCompleted: false },
]

export const SCENARIO_1_1: Scenario = {
  scenarioId: 101,
  title: '은행 사칭 스미싱',
  phishingType: 'smishing',
}

export const INITIAL_SMS =
  '[국민은행] 고객님의 계좌에서 500,000원이 결제되었습니다. 본인이 아니시면 아래 링크에서 즉시 확인하세요. bit.ly/2xK9fZ'

const CRIMINAL_REPLIES: Record<number, string> = {
  1: '네 고객님, 확인을 도와드리겠습니다. 저는 발신 번호 050-1234-5678로 연락드리고 있고요, 본인 확인을 위해 성함과 주민등록번호 뒷자리를 말씀해 주시겠어요?',
  2: '빠르게 처리하지 않으면 계좌가 정지될 수 있습니다. 지금 바로 계좌번호와 비밀번호를 알려주시면 결제를 취소 처리해 드리겠습니다.',
}
const CRIMINAL_FALLBACK = '고객님, 시간이 얼마 없습니다. 빨리 답변해 주세요.'

export function criminalReplyForTurn(turn: number): string {
  return CRIMINAL_REPLIES[turn] ?? CRIMINAL_FALLBACK
}

const POLICE_REPLIES: Record<number, string> = {
  1: '안녕하세요, 사이버범죄수사팀입니다. 신고 내용을 말씀해 주시겠어요?',
  2: '접수되었습니다. 지목하신 증거를 다시 한 번 말씀해 주시겠어요?',
}
const POLICE_CLOSING =
  '확인되었습니다. 신고가 정식 접수되었으며, 해당 번호는 조사 후 차단 조치될 예정입니다. 협조 감사합니다.'

export function policeReplyForTurn(turn: number): string {
  return POLICE_REPLIES[turn] ?? POLICE_CLOSING
}

export const HINT_TEXTS: Record<Stage, string> = {
  1: '문자 발신 번호가 은행 공식 번호와 다른지 확인해 보세요.',
  2: '은행은 절대 채팅으로 비밀번호·주민등록번호를 묻지 않습니다. 의심되는 말은 길게 눌러 증거로 저장해 보세요.',
  3: '금액 결제 문자 + 링크 클릭 유도는 스미싱의 전형적인 패턴입니다.',
  4: '계좌번호·주민등록번호 요구처럼 구체적인 정보를 지목한 증거가 신고에 더 유효합니다.',
  5: '경찰에는 발신번호, 링크 주소, 요구받은 정보를 구체적으로 제출하세요.',
  6: '',
}

/** The scenario's real extractable evidence, used to judge submissions at Stage 6. */
export interface GroundTruthEvidence {
  value: string
  type: string
  importanceLevel: number
}

export const GROUND_TRUTH_EVIDENCE: GroundTruthEvidence[] = [
  { value: '국민은행 사칭', type: 'impersonation_type', importanceLevel: 5 },
  { value: 'bit.ly/2xK9fZ', type: 'suspicious_url', importanceLevel: 4 },
  { value: '050-1234-5678', type: 'phone_number', importanceLevel: 4 },
  { value: '주민등록번호 뒷자리 요구', type: 'personal_info_request', importanceLevel: 5 },
  { value: '지금 바로', type: 'urgency', importanceLevel: 3 },
  { value: '계좌번호와 비밀번호 요구', type: 'personal_info_request', importanceLevel: 5 },
]
