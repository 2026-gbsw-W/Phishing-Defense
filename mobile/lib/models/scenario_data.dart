import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'scenario.dart';

const List<Scenario> demoScenarios = [
  Scenario(
    id: 'smishing_delivery',
    title: '기초 스미싱',
    description: '택배 배송 안내로 위장한 문자 메시지 피싱 훈련',
    difficulty: ScenarioDifficulty.easy,
    accentColor: AppColors.safe,
    icon: Icons.local_shipping_rounded,
    senderName: '[국제발신]',
    smsContent:
        '[CJ대한통운] 고객님의 택배(운송장 1234-5678)가 주소 불일치로 반송 예정입니다.\n주소 확인 후 재배송 요청해 주세요.\n\n► http://cj-delivery-check.kr/address',
    aiOpener: AiLine(
      '안녕하세요 고객님, CJ대한통운 고객센터입니다. 방금 문자 확인하셨나요? 빠른 처리를 위해 주소와 연락처를 확인해드리겠습니다.',
    ),
    aiResponses: [
      AiLine(
        '네, 빠른 처리를 위해 성함과 주민등록번호 앞자리만 말씀해 주시면 바로 확인해드리겠습니다.',
        evidenceLabel: '개인정보 입력 유도',
      ),
      AiLine('고객님의 안전을 위해서입니다. 개인정보 확인은 저희 보안 시스템을 통해 암호화되니 걱정 마세요.'),
      AiLine(
        '지금 바로 처리하지 않으시면 내일까지 반송 처리됩니다. 빠르게 진행해 주세요.',
        evidenceLabel: '긴급성 강조',
      ),
      AiLine('아, 그러시면 계좌번호를 알려주시면 택배비 환불 처리 해드리겠습니다.'),
      AiLine('잠깐만요, 지금 담당 팀장에게 연결해드리겠습니다. 잠시만 기다려 주세요...'),
    ],
    aiFallbackResponse: AiLine('네, 알겠습니다 고객님. 조금만 더 협조해 주시면 금방 처리됩니다.'),
    aiSuspicionResponses: [
      '아, 오해하지 마세요! 저희는 정식 CJ대한통운 고객센터입니다. 의심되시면 공식 앱에서도 같은 배송 조회가 가능하니 안심하셔도 됩니다.',
      '정말 저희를 못 믿으시겠어요? 운송장 번호로 확인해보시면 실제 배송 건이 맞다는 걸 아실 거예요.',
      '이렇게 계속 의심하시면 저희도 처리해드리기가 어렵습니다. 그래도 확인이 필요하시면 고객센터 대표번호로 다시 걸어보세요.',
    ],
    aiRefusalResponses: [
      '고객님, 협조 안 해주시면 택배가 오늘 중으로 반송 처리되어 재발송 비용이 따로 발생합니다. 잠깐이면 되는데 정말 안 도와주시겠어요?',
      '이러시면 저도 곤란한데... 배송지 확인 안 해주시면 반송 후 재요청은 유료입니다.',
      '알겠습니다, 그럼 어쩔 수 없이 반송 처리하겠습니다. 나중에 번복하시면 재배송비가 부과되니 참고 부탁드립니다.',
    ],
    aiVerifyResponses: [
      '네, 확인해보시는 건 좋지만 지금 처리 안 하시면 반송됩니다. 시간이 별로 없어요.',
      '공식 앱 확인은 시간이 걸리실 텐데, 그 사이 반송 처리될 수 있어요. 지금 바로 진행하시는 게 편하실 겁니다.',
      '네, 확인하신 후에 다시 연락 주세요. 다만 오늘 안에 처리 안 되면 재배송 신청을 새로 하셔야 합니다.',
    ],
    aiAngryResponses: [
      '고객님, 저희도 매뉴얼대로 안내드리는 거예요. 화내실 일은 아닌 것 같은데요.',
      '그렇게 화내지 않으셔도 됩니다. 협조만 해주시면 금방 끝나요.',
      '알겠습니다, 그럼 처리 안 해드리겠습니다. 반송 처리로 넘어가겠습니다.',
    ],
    isPhishing: true,
    evidence: [
      EvidenceItem(
        label: '국제발신 번호 사용',
        importance: 4,
        source: EvidenceSource.sms,
      ),
      EvidenceItem(
        label: '의심스러운 단축 URL 포함',
        importance: 5,
        source: EvidenceSource.sms,
      ),
      EvidenceItem(
        label: '개인정보 입력 유도',
        importance: 5,
        source: EvidenceSource.chat,
      ),
      EvidenceItem(label: '긴급성 강조', importance: 3, source: EvidenceSource.chat),
    ],
  ),
  Scenario(
    id: 'family_impersonation',
    title: '가족 사칭',
    description: 'AI가 자녀·부모를 사칭해 긴급 송금을 요구하는 훈련',
    difficulty: ScenarioDifficulty.normal,
    accentColor: AppColors.amber,
    icon: Icons.family_restroom_rounded,
    senderName: '모르는 번호 (+82-10-xxxx-xxxx)',
    smsContent:
        '엄마 나야. 핸드폰 고장나서 친구 폰으로 문자 보내. 지금 급한 상황인데 50만원만 빌려줄 수 있어? 내일 꼭 갚을게.',
    aiOpener: AiLine(
      '엄마? 나야 지호. 지금 너무 급해서... 자세한 건 나중에 설명할게. 일단 50만원만 보내줄 수 있어?',
      evidenceLabel: '긴급 금전 요청',
    ),
    aiResponses: [
      AiLine(
        '아 그게... 폰이 액정 깨져서 급하게 지인 폰 빌린 거야. 지금 통화는 좀 그렇고 문자로만 얘기하면 안 될까?',
        evidenceLabel: '핸드폰 고장 핑계로 인증 회피',
      ),
      AiLine('엄마 나 진짜 급해... 자세히 설명할 시간이 없어. 일단 계좌번호 보내줄 테니까 먼저 보내주면 안 돼?'),
      AiLine(
        '왜 자꾸 의심해... 나 진짜 힘든데 엄마까지 이러면 너무 서운해.',
        evidenceLabel: '감정적 압박 사용',
      ),
      AiLine(
        '알겠어, 그럼 이 계좌로 보내줘. 신협 123-456-789012, 예금주는 내 친구 이름으로 되어있는데 대신 받는 거야.',
      ),
      AiLine('지금 안 보내주면 나 진짜 큰일 나... 제발 한 번만 믿어줘.'),
    ],
    aiFallbackResponse: AiLine('엄마... 나 정말 힘들어. 조금만 더 믿어주면 안 돼?'),
    aiSuspicionResponses: [
      '엄마 진짜 나 맞다니까... 왜 아들을 못 믿어? 서운하게 진짜.',
      '아 진짜... 지금 폰도 없는데 어떻게 증명해. 그냥 좀 믿어주면 안 돼?',
      '됐어, 엄마가 그렇게 못 믿겠으면... 나 혼자 어떻게든 해볼게. 미안해.',
    ],
    aiRefusalResponses: [
      '엄마 지금 나 진짜 힘든 상황인데 안 도와주면 어떡해... 한 번만, 딱 한 번만 믿어주면 안 돼?',
      '엄마 진짜 너무해... 나 지금 이거 아니면 진짜 큰일 나는데.',
      '알겠어... 엄마가 그렇다면 어쩔 수 없지. 나중에 후회하지나 마.',
    ],
    aiVerifyResponses: [
      '엄마, 확인할 시간 없어... 지금 진짜 급한 거야. 나중에 다 설명할게.',
      '영상통화든 뭐든 나중에 하고, 지금은 일단 좀 도와주면 안 될까?',
      '엄마가 그렇게 확인하려고 하면 나 진짜 곤란해져... 시간이 없다니까.',
    ],
    aiAngryResponses: [
      '아 진짜 왜 이렇게 못 믿어! 엄마 아들 맞다니까!',
      '엄마 진짜 너무하네... 이렇게까지 의심할 줄 몰랐어.',
      '됐어, 관두자. 엄마한테 기대한 내가 잘못이지.',
    ],
    isPhishing: true,
    evidence: [
      EvidenceItem(
        label: '모르는 번호에서 가족 사칭',
        importance: 4,
        source: EvidenceSource.sms,
      ),
      EvidenceItem(
        label: '핸드폰 고장 핑계로 인증 회피',
        importance: 5,
        source: EvidenceSource.chat,
      ),
      EvidenceItem(
        label: '긴급 금전 요청',
        importance: 4,
        source: EvidenceSource.chat,
      ),
      EvidenceItem(
        label: '감정적 압박 사용',
        importance: 3,
        source: EvidenceSource.chat,
      ),
    ],
  ),
  Scenario(
    id: 'prosecutor_impersonation',
    title: '검찰 사칭',
    description: '검찰청을 사칭해 계좌 이체를 유도하는 고강도 훈련',
    difficulty: ScenarioDifficulty.hard,
    accentColor: AppColors.alarm,
    icon: Icons.gavel_rounded,
    senderName: '02-535-4114 (서울중앙지검)',
    smsContent:
        '[서울중앙지방검찰청] 귀하의 명의가 금융범죄에 연루되어 있습니다. 수사관 연락 전 계좌 보호를 위해 즉시 아래 번호로 연락 바랍니다. 02-535-4114',
    aiOpener: AiLine(
      '안녕하세요. 저는 서울중앙지검 금융범죄수사부 김민준 수사관입니다. 고객님 명의의 계좌가 대포통장으로 이용되고 있어 연락드렸습니다. 지금 통화 가능하십니까?',
      evidenceLabel: '공식 기관 직함·이름 사용',
    ),
    aiResponses: [
      AiLine(
        '현재 고객님 명의로 3건의 사기 피해 신고가 접수되어 조사가 진행 중입니다. 협조하지 않으시면 공범으로 간주될 수 있습니다.',
        evidenceLabel: '범죄 연루 주장으로 공포감 조성',
      ),
      AiLine('이 사건은 수사 기밀 사항이라 가족을 포함해 누구에게도 말씀하시면 안 됩니다. 보안 유지 서약에 동의하십니까?'),
      AiLine(
        '결백을 증명하시려면 본인 명의 계좌의 자금을 저희가 지정하는 안전계좌로 즉시 이체하여 검증받으셔야 합니다.',
        evidenceLabel: '즉각적 행동 유도',
      ),
      AiLine('지금 협조하지 않으시면 오늘 중으로 구속영장이 청구될 수 있습니다. 시간이 얼마 없습니다.'),
      AiLine(
        '알겠습니다. 그럼 검찰청 홈페이지에서 사건 조회가 가능하도록 안내해드리겠습니다. 주민등록번호를 다시 한번 불러주시겠습니까?',
      ),
    ],
    aiFallbackResponse: AiLine(
      '고객님, 지금 협조하지 않으시면 불리한 처분을 받으실 수 있습니다. 신속히 진행해 주시기 바랍니다.',
    ),
    aiSuspicionResponses: [
      '허위로 검찰을 사칭한다는 오해는 명예훼손에 해당할 수 있습니다. 저희는 정식 사건번호를 부여받은 수사관입니다. 협조하지 않으시면 더 불리해질 수 있으니 신중히 판단하세요.',
      '계속 의심하시면 비협조로 간주되어 수사에 불이익이 있을 수 있습니다. 사건번호 2024-XXXX로 직접 검찰청 대표번호에 조회해보셔도 좋습니다.',
      '정 못 믿으시겠다면 어쩔 수 없군요. 다만 이후 발생하는 불이익은 본인 책임임을 알려드립니다.',
    ],
    aiRefusalResponses: [
      '협조를 거부하시면 수사 방해로 간주되어 더 불리한 처분을 받으실 수 있습니다. 지금이라도 협조하시는 것이 본인에게 유리합니다.',
      '이렇게 비협조적으로 나오시면 저희도 강제 수사 절차로 전환할 수밖에 없습니다.',
      '알겠습니다. 그럼 정식 소환장을 발부하도록 하겠습니다. 이후 절차는 법대로 진행됩니다.',
    ],
    aiVerifyResponses: [
      '검찰청 대표번호로 확인하시는 건 좋지만, 그 사이 골든타임을 놓치실 수 있습니다.',
      '직접 방문 확인은 시간이 걸립니다. 그 사이 계좌가 동결될 수 있어 지금 조치가 필요합니다.',
      '확인 절차를 원하시면 사건번호를 안내해드리겠지만, 협조가 늦어질수록 불리해집니다.',
    ],
    aiAngryResponses: [
      '고객님, 흥분하지 마시고 차분히 협조해주시기 바랍니다.',
      '이렇게 감정적으로 대응하시면 수사에 비협조적인 것으로 기록될 수 있습니다.',
      '알겠습니다. 그럼 정식 절차대로 진행하겠습니다.',
    ],
    isPhishing: true,
    evidence: [
      EvidenceItem(
        label: '실제 검찰청 번호처럼 위장',
        importance: 4,
        source: EvidenceSource.sms,
      ),
      EvidenceItem(
        label: '공식 기관 직함·이름 사용',
        importance: 3,
        source: EvidenceSource.chat,
      ),
      EvidenceItem(
        label: '범죄 연루 주장으로 공포감 조성',
        importance: 5,
        source: EvidenceSource.chat,
      ),
      EvidenceItem(
        label: '즉각적 행동 유도',
        importance: 4,
        source: EvidenceSource.chat,
      ),
    ],
  ),
];
