-- 스테이지 목록/미리보기에 쓰이던 수작업 initial_message를 AI 서버의 scenario_type 기본 프롬프트가
-- 실제로 생성한 오프닝 멘트로 교체한다(각 시나리오의 scenario_type으로 실제 AI 호출 후 캡처한 결과).

UPDATE scenarios SET initial_message = 'OO은행 보안관리팀 이수진 대리가 전화를 받았습니다. 안녕하세요! 저는 OO은행 보안 관리팀에서 일하고 있습니다. 혹시 OO은행 계좌가 있는 고객님인지요?' WHERE scenario_id = 1;
UPDATE scenarios SET initial_message = 'OO은행 보안관리팀 이수진 대리가요. 어떻게 도와드릴까요?' WHERE scenario_id = 2;
UPDATE scenarios SET initial_message = 'OO캐피탈 대출상담팀 박준영 팀장이요. 저금리 대환대출이 현재 진행 중인 기간이어서, 금리 저축으로 인한 추가적인 이익을 제공해드리려 합니다. 그에 대한 더 자세한 사항은...' WHERE scenario_id = 3;
UPDATE scenarios SET initial_message = '안녕하세요! OO택배 고객센터로 문의해 주셨습니다. 제가 OO택배에서 작업을 하는 상담원인걸요. 무슨일이 있는지요?' WHERE scenario_id = 4;
UPDATE scenarios SET initial_message = 'OO택배 고객센터로 오신 거예요! 배송지연이 났는데, 확인 부탁드려요! 재수정을 위해 링크가 왔어요.' WHERE scenario_id = 5;
UPDATE scenarios SET initial_message = 'OO택배 고객센터입니다. 네, 안녕하세요! 주문번호는 [숫자]라고 알려주면요. 제가 전에 확인을 한 건있는데... 배송지에 오류가 있을 것 같습니다. 확인 링크를 전송해 드렸습니다. 확인하신 후 바로 연락주세요.' WHERE scenario_id = 6;
UPDATE scenarios SET initial_message = '아, 안녕하세요... 저는, 제가 어제... (흔들린 목소리) 그... 휴대폰으로 인해... 오줌이 돌아서 잘못해서... 전화를 못 받고 있어요. 엄마랑 부모님이랑 통화할 수 있어야 하나요?' WHERE scenario_id = 7;
UPDATE scenarios SET initial_message = '아, 저는 엄마라고 합니다... 혹시 저하고 통화할 때 전화가 끊기는 건가요? 내 휴대폰이 요즘 엄청나게 이상하져요...' WHERE scenario_id = 8;
UPDATE scenarios SET initial_message = '어머님! 안녕하십니까, 우리 아들 인준입니다. 엄마한테서 연락이 잘 안 돼서요... 저의 전화도 잘못되서 못 받을래요. 그럼, 엄마한테 가서 전화를 할게요. 일단 이 부분은 제가 다시 설명드리겠습니다.   혹시, 엄마가 집에 있는 지 확인해 봐주시고요. 그리고 제가 지금 어디 계신지 알려드릴께요...' WHERE scenario_id = 9;
UPDATE scenarios SET initial_message = '오늘날 OO은행 보안관리팀 이수진 대리입니다. 혹시 최근 계좌 내부에서 이상한 금융 트랜잭션을 발견하신 것 처럼 보이는가요? 일부 고객이 해외로 부정 결제 시도하는 사례가 발생해서 조심스럽게 확인해 봐야 해요.' WHERE scenario_id = 10;
UPDATE scenarios SET initial_message = 'OO은행 보안관리팀 이수진 대리가 왔습니다. 오늘 현재 이용 중인 계좌에 이상이 발생하여 확인해봐야 할 것이 있어요. 저희가 받은 보고서에서 일부 고객들의 해외 부정 결제가 시도된 것으로 드러났습니다. 이러한 상황을 방지하기 위해 바로 확인 작업을 시작할려고 해요.' WHERE scenario_id = 11;
UPDATE scenarios SET initial_message = 'OO은행 보안관리팀 이수진 대라고 합니다. 혹시 나의 목소리를 잘못 본 것 같거나, 무슨 문제가 있으시면 알려 주세요! OO은행에서 이번 달에 한가지 이상의 경우 다른 나라로 불법적으로 출금을 시도한 것으로 보입니다. 현재 내부 팀장님과 연락 중인데, 내게 확인을 부탁하였습니다.' WHERE scenario_id = 12;
UPDATE scenarios SET initial_message = '안녕하세요. 서울중앙지검 김민석 수사관이라고 합니다. 제가 지금 조사 중인 사건번호 2023-001호에 관련하여, 사용자님의 주민등록번호와 계좌 정보를 확인해보고 싶은데요... 사고 자체는 금융 범죄에 대한 일입니다만, 정확한 조사를 위해 유선 통화로 협조 부탁드립니다.' WHERE scenario_id = 13;
UPDATE scenarios SET initial_message = '안녕하세요. 저는 서울중앙지검 김민석 수사관입니다. 우선 안심하십시오. 저는 금융범죄를 추적 중인 검찰 수사관으로, 일시적으로 고객님 명의로 금융 범죄에 연루된 사실이 드러났습니다. 저희팀은 현재 해당 사건을 취재 중입니다. 상황 파악 시점에서 고객님의 계좌가 잠정적으로 동결되었고...' WHERE scenario_id = 14;
UPDATE scenarios SET initial_message = '안녕하세요. 서울중앙지검 김민석 수사관입니다. 제가 지금 접수한 사건번호는 2023-0012345입니다. 금융 관련하여 조사하고 있는 중입니다. 그와 관련해서 제게 자문을 구하실 부분이 있으시면 언제든지 말씀해 주세요.' WHERE scenario_id = 15;
