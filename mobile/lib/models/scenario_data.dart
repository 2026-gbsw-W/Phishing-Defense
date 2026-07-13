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
    phishingHints: [
      '국제발신 번호 사용',
      '의심스러운 단축 URL 포함',
      '개인정보 입력 유도',
      '긴급성 강조',
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
    phishingHints: [
      '모르는 번호에서 가족 사칭',
      '핸드폰 고장 핑계로 인증 회피',
      '긴급 금전 요청',
      '감정적 압박 사용',
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
    phishingHints: [
      '실제 검찰청 번호처럼 위장',
      '공식 기관 직함·이름 사용',
      '범죄 연루 주장으로 공포감 조성',
      '즉각적 행동 유도',
    ],
  ),
];
