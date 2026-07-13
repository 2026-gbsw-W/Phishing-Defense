-- Chapter Progress
CREATE TABLE chapter_progress (
  progress_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  chapter_id INT NOT NULL,

  is_completed BOOLEAN DEFAULT FALSE,
  best_star INT DEFAULT 0,
  total_attempts INT DEFAULT 0,

  first_clear_at TIMESTAMP NULL,
  last_attempt_at TIMESTAMP NULL,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  UNIQUE KEY uk_chapter_progress_user_chapter (user_id, chapter_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (chapter_id) REFERENCES chapters(chapter_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Scenario Records (플레이 기록, "스테이지" 1회 플레이 단위)
CREATE TABLE scenario_records (
  record_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  chapter_id INT NOT NULL,
  scenario_id BIGINT NOT NULL,

  is_correct_judgment BOOLEAN,
  judgment_at_turn INT,

  hints_used INT DEFAULT 0,
  evidence_marked_count INT,
  evidence_submitted_count INT,
  evidence_valid_count INT,

  star_rating INT DEFAULT 0,
  total_score INT DEFAULT 0,
  accuracy_score INT,
  evidence_score INT,
  report_handling_score INT,
  hint_penalty INT,

  played_at TIMESTAMP NULL,
  duration_seconds INT,

  is_completed BOOLEAN DEFAULT FALSE,
  is_reported BOOLEAN DEFAULT FALSE,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  KEY idx_scenario_records_user (user_id),
  KEY idx_scenario_records_scenario (scenario_id),
  KEY idx_scenario_records_created_at (created_at),
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (chapter_id) REFERENCES chapters(chapter_id),
  FOREIGN KEY (scenario_id) REFERENCES scenarios(scenario_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Chat History
CREATE TABLE chat_history (
  chat_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  record_id BIGINT NOT NULL,

  turn INT,
  sender VARCHAR(20),
  message_text LONGTEXT,

  ai_model VARCHAR(50),
  model_version VARCHAR(50),
  tokens_used INT,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  KEY idx_chat_history_record (record_id),
  FOREIGN KEY (record_id) REFERENCES scenario_records(record_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Evidence
CREATE TABLE evidence (
  evidence_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  record_id BIGINT NOT NULL,

  evidence_type VARCHAR(50),
  evidence_value VARCHAR(255),
  message_turn INT,

  is_submitted_at_report BOOLEAN DEFAULT FALSE,
  is_valid_evidence BOOLEAN,
  validity_reason VARCHAR(255),
  importance_level INT DEFAULT 1,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  KEY idx_evidence_record (record_id),
  KEY idx_evidence_type (evidence_type),
  FOREIGN KEY (record_id) REFERENCES scenario_records(record_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Achievements (Master Data)
CREATE TABLE achievements (
  achievement_id INT PRIMARY KEY,
  category VARCHAR(50),
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255),
  icon_url VARCHAR(500),

  xp_reward INT DEFAULT 0,
  coin_reward INT DEFAULT 0,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User Achievements
CREATE TABLE user_achievements (
  user_achievement_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  achievement_id INT NOT NULL,

  unlocked_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  UNIQUE KEY uk_user_achievements_user_achievement (user_id, achievement_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (achievement_id) REFERENCES achievements(achievement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
