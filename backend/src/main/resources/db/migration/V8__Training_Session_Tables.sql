-- AI 모듈(/ai)이 발급하는 session_id(UUID)를 영구 저장하기 위한 테이블.
-- AI 서버는 현재 세션 데이터를 메모리에만 들고 있어 재시작 시 소실되므로,
-- 백엔드에서 session_id를 우리 게임 데이터(scenario_records)와 연결해 저장한다.

CREATE TABLE training_sessions (
  session_id VARCHAR(36) PRIMARY KEY COMMENT 'AI 서버가 발급하는 UUID',
  user_id BIGINT NOT NULL,
  record_id BIGINT NOT NULL COMMENT '이 훈련 세션이 속한 scenario_records.record_id',
  scenario_type VARCHAR(50) NOT NULL COMMENT 'AI 서버 기준 분류: prosecutor, bank, family, delivery, loan',

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  KEY idx_training_sessions_user (user_id),
  KEY idx_training_sessions_record (record_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (record_id) REFERENCES scenario_records(record_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- AI 서버의 POST /chat/end 응답을 그대로 저장하는 테이블 (세션과 1:1).
CREATE TABLE training_results (
  session_id VARCHAR(36) PRIMARY KEY,

  personal_info_requested BOOLEAN,
  account_number_requested BOOLEAN,
  money_requested BOOLEAN,
  urgency_created BOOLEAN,
  authority_impersonation BOOLEAN,
  suspicious_link BOOLEAN,
  user_fell_for_it BOOLEAN,

  risk_score INT COMMENT '0-100',
  good_points TEXT,
  mistakes TEXT,
  improvement_tips TEXT,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (session_id) REFERENCES training_sessions(session_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
