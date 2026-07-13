-- docs(PRD/구현 가이드)에 명시적 스키마가 없어, IA상의 기능 설명(일일미션/출석/피싱 도감)을
-- 근거로 합리적으로 설계한 테이블이다.

-- Daily Missions
CREATE TABLE daily_missions (
  mission_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,

  mission_type VARCHAR(50) NOT NULL COMMENT 'fixed, dynamic, bonus',
  mission_description VARCHAR(255) NOT NULL,
  recommendation_reason VARCHAR(255),

  is_completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMP NULL,
  reward_xp INT DEFAULT 0,

  created_date DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  KEY idx_daily_missions_user_date (user_id, created_date),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Attendance (출석 체크. PRD 원문의 `checked_in_at DATE UNIQUE`는 전체 사용자 기준 유니크로
-- 해석되어 오류로 보이므로, (user_id, checked_in_at) 조합 유니크로 수정했다.)
CREATE TABLE attendance (
  attendance_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,

  checked_in_at DATE NOT NULL,
  consecutive_days INT DEFAULT 1,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  UNIQUE KEY uk_attendance_user_date (user_id, checked_in_at),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Phishing Index (피싱 도감: 사용자가 플레이하여 "수집"한 피싱 유형/스테이지를 기록)
CREATE TABLE phishing_index (
  phishing_index_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  chapter_id INT NOT NULL,
  scenario_id BIGINT NOT NULL,

  collected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  UNIQUE KEY uk_phishing_index_user_scenario (user_id, scenario_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (chapter_id) REFERENCES chapters(chapter_id),
  FOREIGN KEY (scenario_id) REFERENCES scenarios(scenario_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
