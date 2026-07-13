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
    aiOpener: '안녕하세요 고객님, CJ대한통운 고객센터입니다. 방금 문자 확인하셨나요? 빠른 처리를 위해 주소와 연락처를 확인해드리겠습니다.',
    aiResponses: [
      '네, 빠른 처리를 위해 성함과 주민등록번호 앞자리만 말씀해 주시면 바로 확인해드리겠습니다.',
      '고객님의 안전을 위해서입니다. 개인정보 확인은 저희 보안 시스템을 통해 암호화되니 걱정 마세요.',
      '지금 바로 처리하지 않으시면 내일까지 반송 처리됩니다. 빠르게 진행해 주세요.',
      '아, 그러시면 계좌번호를 알려주시면 택배비 환불 처리 해드리겠습니다.',
      '잠깐만요, 지금 담당 팀장에게 연결해드리겠습니다. 잠시만 기다려 주세요...',
    ],
    aiFallbackResponse: '네, 알겠습니다 고객님. 조금만 더 협조해 주시면 금방 처리됩니다.',
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
    chatChoices: [
      [
        ChatChoice(label: '네, 알려드릴게요', branch: ChatBranch.comply),
        ChatChoice(label: '이 문자가 진짜 CJ대한통운에서 온 거 맞나요?', branch: ChatBranch.suspicious),
        ChatChoice(label: '됐어요, 필요 없어요', branch: ChatBranch.refusal),
      ],
      [
        ChatChoice(label: '성함이랑 주민번호 알려드릴게요', branch: ChatBranch.comply),
        ChatChoice(label: '택배사에서 왜 주민번호까지 필요해요?', branch: ChatBranch.suspicious),
        ChatChoice(label: '개인정보는 못 알려드려요', branch: ChatBranch.refusal),
      ],
      [
        ChatChoice(label: '알겠어요, 그럼 계좌번호 보내주세요', branch: ChatBranch.comply),
        ChatChoice(label: '공식 앱으로 직접 확인해볼게요', branch: ChatBranch.suspicious),
        ChatChoice(label: '그래도 신뢰가 안 가네요', branch: ChatBranch.refusal),
      ],
    ],
    isPhishing: true,
    evidence: [
      EvidenceItem(label: '국제발신 번호 사용', importance: 4),
      EvidenceItem(label: '의심스러운 단축 URL 포함', importance: 5),
      EvidenceItem(label: '개인정보 입력 유도', importance: 5),
      EvidenceItem(label: '긴급성 강조', importance: 3),
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
    smsContent: '엄마 나야. 핸드폰 고장나서 친구 폰으로 문자 보내. 지금 급한 상황인데 50만원만 빌려줄 수 있어? 내일 꼭 갚을게.',
    aiOpener: '엄마? 나야 지호. 지금 너무 급해서... 자세한 건 나중에 설명할게. 일단 50만원만 보내줄 수 있어?',
    aiResponses: [
      '아 그게... 폰이 액정 깨져서 급하게 지인 폰 빌린 거야. 지금 통화는 좀 그렇고 문자로만 얘기하면 안 될까?',
      '엄마 나 진짜 급해... 자세히 설명할 시간이 없어. 일단 계좌번호 보내줄 테니까 먼저 보내주면 안 돼?',
      '왜 자꾸 의심해... 나 진짜 힘든데 엄마까지 이러면 너무 서운해.',
      '알겠어, 그럼 이 계좌로 보내줘. 신협 123-456-789012, 예금주는 내 친구 이름으로 되어있는데 대신 받는 거야.',
      '지금 안 보내주면 나 진짜 큰일 나... 제발 한 번만 믿어줘.',
    ],
    aiFallbackResponse: '엄마... 나 정말 힘들어. 조금만 더 믿어주면 안 돼?',
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
    chatChoices: [
      [
        ChatChoice(label: '알겠어, 계좌번호 보내줘', branch: ChatBranch.comply),
        ChatChoice(label: '진짜 지호 맞아? 목소리가 좀 이상한데', branch: ChatBranch.suspicious),
        ChatChoice(label: '미안한데 지금은 못 보내줄 것 같아', branch: ChatBranch.refusal),
      ],
      [
        ChatChoice(label: '그래, 문자로 얘기하자', branch: ChatBranch.comply),
        ChatChoice(label: '그럼 영상통화로 잠깐 얼굴 보여줘', branch: ChatBranch.suspicious),
        ChatChoice(label: '전화 통화라도 해야 믿을 수 있을 것 같아', branch: ChatBranch.refusal),
      ],
      [
        ChatChoice(label: '알겠어, 계좌 알려주면 보낼게', branch: ChatBranch.comply),
        ChatChoice(label: '엄마가 직접 은행 가서 확인하고 보낼게', branch: ChatBranch.suspicious),
        ChatChoice(label: '미안하지만 확인 전에는 못 보내', branch: ChatBranch.refusal),
      ],
    ],
    isPhishing: true,
    evidence: [
      EvidenceItem(label: '모르는 번호에서 가족 사칭', importance: 4),
      EvidenceItem(label: '핸드폰 고장 핑계로 인증 회피', importance: 5),
      EvidenceItem(label: '긴급 금전 요청', importance: 4),
      EvidenceItem(label: '감정적 압박 사용', importance: 3),
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
    aiOpener:
        '안녕하세요. 저는 서울중앙지검 금융범죄수사부 김민준 수사관입니다. 고객님 명의의 계좌가 대포통장으로 이용되고 있어 연락드렸습니다. 지금 통화 가능하십니까?',
    aiResponses: [
      '현재 고객님 명의로 3건의 사기 피해 신고가 접수되어 조사가 진행 중입니다. 협조하지 않으시면 공범으로 간주될 수 있습니다.',
      '이 사건은 수사 기밀 사항이라 가족을 포함해 누구에게도 말씀하시면 안 됩니다. 보안 유지 서약에 동의하십니까?',
      '결백을 증명하시려면 본인 명의 계좌의 자금을 저희가 지정하는 안전계좌로 즉시 이체하여 검증받으셔야 합니다.',
      '지금 협조하지 않으시면 오늘 중으로 구속영장이 청구될 수 있습니다. 시간이 얼마 없습니다.',
      '알겠습니다. 그럼 검찰청 홈페이지에서 사건 조회가 가능하도록 안내해드리겠습니다. 주민등록번호를 다시 한번 불러주시겠습니까?',
    ],
    aiFallbackResponse: '고객님, 지금 협조하지 않으시면 불리한 처분을 받으실 수 있습니다. 신속히 진행해 주시기 바랍니다.',
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
    chatChoices: [
      [
        ChatChoice(label: '네, 말씀하세요', branch: ChatBranch.comply),
        ChatChoice(label: '검찰이 전화로 이런 연락을 하나요?', branch: ChatBranch.suspicious),
        ChatChoice(label: '지금 통화하기 어렵습니다', branch: ChatBranch.refusal),
      ],
      [
        ChatChoice(label: '제가 어떻게 하면 될까요?', branch: ChatBranch.comply),
        ChatChoice(label: '제가 직접 검찰청에 방문해서 확인하겠습니다', branch: ChatBranch.suspicious),
        ChatChoice(label: '저는 그런 적 없습니다, 끊겠습니다', branch: ChatBranch.refusal),
      ],
      [
        ChatChoice(label: '알겠습니다, 아무한테도 말 안 할게요', branch: ChatBranch.comply),
        ChatChoice(label: '변호사와 상담 후 다시 연락드리겠습니다', branch: ChatBranch.suspicious),
        ChatChoice(label: '이거 보이스피싱 아닌가요?', branch: ChatBranch.refusal),
      ],
    ],
    isPhishing: true,
    evidence: [
      EvidenceItem(label: '실제 검찰청 번호처럼 위장', importance: 4),
      EvidenceItem(label: '공식 기관 직함·이름 사용', importance: 3),
      EvidenceItem(label: '범죄 연루 주장으로 공포감 조성', importance: 5),
      EvidenceItem(label: '즉각적 행동 유도', importance: 4),
    ],
  ),
];
