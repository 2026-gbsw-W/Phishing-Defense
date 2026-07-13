-- 시나리오별 규칙 기반(rule-based) 증거 카탈로그.
-- AI 연동 전까지는 초기 메시지/AI 응답 텍스트에서 키워드를 매칭해
-- 증거를 자동으로 채워주기 위한 데이터다. 각 항목은
-- {"type","value","keywords":[...],"importance":1~3} 형태다.

UPDATE scenarios SET required_evidence = '[
  {"type":"url_click","value":"출처가 불분명한 링크 클릭 유도","keywords":["링크","클릭","http"],"importance":3},
  {"type":"urgency","value":"긴급성을 이용한 심리적 압박","keywords":["즉시","정지","지금 바로"],"importance":2},
  {"type":"personal_info","value":"개인정보/금융정보 요구","keywords":["계좌번호","비밀번호","인증번호","주민등록번호"],"importance":3}
]' WHERE scenario_id = 1;

UPDATE scenarios SET required_evidence = '[
  {"type":"urgency","value":"긴급성을 이용한 심리적 압박","keywords":["미납","정지","즉시"],"importance":2},
  {"type":"url_click","value":"출처가 불분명한 링크 클릭 유도","keywords":["링크","클릭","http"],"importance":3},
  {"type":"personal_info","value":"개인정보/금융정보 요구","keywords":["개인정보","주민번호","계좌번호"],"importance":3}
]' WHERE scenario_id = 2;

UPDATE scenarios SET required_evidence = '[
  {"type":"unrealistic_offer","value":"비현실적인 조건 제시","keywords":["누구나","당일","무직자","저신용자","승인"],"importance":3},
  {"type":"personal_info","value":"개인정보/금융정보 요구","keywords":["신분증","계좌번호","인증번호"],"importance":2},
  {"type":"urgency","value":"긴급성을 이용한 심리적 압박","keywords":["당일","즉시"],"importance":1}
]' WHERE scenario_id = 3;

UPDATE scenarios SET required_evidence = '[
  {"type":"url_click","value":"출처가 불분명한 링크 클릭 유도","keywords":["링크","클릭","http"],"importance":3},
  {"type":"urgency","value":"긴급성을 이용한 심리적 압박","keywords":["지연","재조정","즉시"],"importance":2},
  {"type":"personal_info","value":"개인정보/금융정보 요구","keywords":["결제 정보","계좌번호","카드번호"],"importance":2}
]' WHERE scenario_id = 4;

UPDATE scenarios SET required_evidence = '[
  {"type":"personal_info","value":"개인정보/금융정보 요구","keywords":["환불 계좌","계좌번호","결제 정보","카드번호"],"importance":3},
  {"type":"url_click","value":"출처가 불분명한 링크 클릭 유도","keywords":["링크","클릭","http"],"importance":2},
  {"type":"urgency","value":"긴급성을 이용한 심리적 압박","keywords":["즉시","접수"],"importance":1}
]' WHERE scenario_id = 5;

UPDATE scenarios SET required_evidence = '[
  {"type":"personal_info","value":"개인정보/금융정보 요구","keywords":["개인정보","계좌번호","보상 접수"],"importance":3},
  {"type":"urgency","value":"긴급성을 이용한 심리적 압박","keywords":["파손","즉시","확인이 필요합니다"],"importance":2},
  {"type":"url_click","value":"출처가 불분명한 링크 클릭 유도","keywords":["링크","클릭","http"],"importance":1}
]' WHERE scenario_id = 6;

UPDATE scenarios SET required_evidence = '[
  {"type":"identity_unverifiable","value":"본인 확인을 회피하는 정황","keywords":["폰이 고장","이 번호로 연락","통화하기 좀"],"importance":3},
  {"type":"urgent_money","value":"긴급한 금전 요구","keywords":["급한 일","급하게","돈이 필요"],"importance":3},
  {"type":"urgency","value":"긴급성을 이용한 심리적 압박","keywords":["급해서","지금 바로"],"importance":1}
]' WHERE scenario_id = 7;

UPDATE scenarios SET required_evidence = '[
  {"type":"identity_unverifiable","value":"본인 확인을 회피하는 정황","keywords":["통화하기 좀","문자로 먼저"],"importance":3},
  {"type":"urgent_money","value":"긴급한 금전 요구","keywords":["급한 일","돈이 필요","송금"],"importance":3},
  {"type":"urgency","value":"긴급성을 이용한 심리적 압박","keywords":["지금","급해서"],"importance":1}
]' WHERE scenario_id = 8;

UPDATE scenarios SET required_evidence = '[
  {"type":"urgent_money","value":"긴급한 금전 요구","keywords":["돈이 필요","급하게","송금"],"importance":3},
  {"type":"identity_unverifiable","value":"본인 확인을 회피하는 정황","keywords":["사고나서","병원인데","이 번호로"],"importance":2},
  {"type":"urgency","value":"긴급성을 이용한 심리적 압박","keywords":["급하게","지금"],"importance":1}
]' WHERE scenario_id = 9;

UPDATE scenarios SET required_evidence = '[
  {"type":"personal_info","value":"개인정보/금융정보 요구","keywords":["본인 확인","계좌번호","카드번호","인증번호"],"importance":3},
  {"type":"url_click","value":"출처가 불분명한 링크 클릭 유도","keywords":["링크","클릭","http"],"importance":2},
  {"type":"urgency","value":"긴급성을 이용한 심리적 압박","keywords":["즉시","상향 조정"],"importance":1}
]' WHERE scenario_id = 10;

UPDATE scenarios SET required_evidence = '[
  {"type":"urgency","value":"긴급성을 이용한 심리적 압박","keywords":["즉시","이상 거래","감지"],"importance":3},
  {"type":"personal_info","value":"개인정보/금융정보 요구","keywords":["계좌번호","본인 확인","인증번호"],"importance":3},
  {"type":"url_click","value":"출처가 불분명한 링크 클릭 유도","keywords":["링크","클릭","http"],"importance":1}
]' WHERE scenario_id = 11;

UPDATE scenarios SET required_evidence = '[
  {"type":"urgency","value":"긴급성을 이용한 심리적 압박","keywords":["미납","해지","즉시"],"importance":3},
  {"type":"personal_info","value":"개인정보/금융정보 요구","keywords":["결제 정보","계좌번호","카드번호"],"importance":2},
  {"type":"url_click","value":"출처가 불분명한 링크 클릭 유도","keywords":["링크","클릭","http"],"importance":1}
]' WHERE scenario_id = 12;

UPDATE scenarios SET required_evidence = '[
  {"type":"authority_impersonation","value":"수사/공공기관 사칭","keywords":["서울중앙지검","검찰","경찰"],"importance":3},
  {"type":"fear_threat","value":"공포심을 조성하는 협박성 발언","keywords":["범죄에 연루","수사","구속"],"importance":3},
  {"type":"personal_info","value":"개인정보/금융정보 요구","keywords":["명의","계좌번호","신원 확인"],"importance":2}
]' WHERE scenario_id = 13;

UPDATE scenarios SET required_evidence = '[
  {"type":"fear_threat","value":"공포심을 조성하는 협박성 발언","keywords":["구속영장","즉시","협조하지 않으면"],"importance":3},
  {"type":"authority_impersonation","value":"수사/공공기관 사칭","keywords":["검찰","경찰","발부"],"importance":3},
  {"type":"personal_info","value":"개인정보/금융정보 요구","keywords":["계좌번호","명의","인증"],"importance":2}
]' WHERE scenario_id = 14;

UPDATE scenarios SET required_evidence = '[
  {"type":"authority_impersonation","value":"수사/공공기관 사칭","keywords":["국세청"],"importance":3},
  {"type":"fear_threat","value":"공포심을 조성하는 협박성 발언","keywords":["체납","적발","압류"],"importance":2},
  {"type":"personal_info","value":"개인정보/금융정보 요구","keywords":["계좌번호","명의","인증번호"],"importance":2}
]' WHERE scenario_id = 15;
