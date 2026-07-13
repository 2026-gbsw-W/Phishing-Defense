-- AI 모듈(/ai)의 POST /evidence 응답을 영구 저장하기 위한 테이블.
-- AI 서버도 자체 저장소를 갖지만, 우리 쪽에서도 세션과 함께 조회할 수 있도록 동일하게 저장한다.

CREATE TABLE training_evidence (
  evidence_id VARCHAR(36) PRIMARY KEY COMMENT 'AI 서버가 발급하는 UUID',
  session_id VARCHAR(36) NOT NULL,
  speaker VARCHAR(50) NOT NULL,
  message TEXT NOT NULL,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  KEY idx_training_evidence_session (session_id),
  FOREIGN KEY (session_id) REFERENCES training_sessions(session_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- AI 서버의 POST /chat/end 응답에 새로 추가된 분석 필드.
ALTER TABLE training_results
  ADD COLUMN dangerous_messages JSON AFTER risk_score,
  ADD COLUMN evidence_feedback TEXT AFTER dangerous_messages;
