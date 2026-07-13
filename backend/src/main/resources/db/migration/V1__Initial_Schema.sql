-- Users
CREATE TABLE users (
  user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  nickname VARCHAR(50) NOT NULL UNIQUE,
  provider VARCHAR(20),
  provider_id VARCHAR(255),
  level INT DEFAULT 1,
  current_xp INT DEFAULT 0,
  total_xp INT DEFAULT 0,
  coins INT DEFAULT 0,
  hints INT DEFAULT 3,
  profile_image_url VARCHAR(500),
  bio VARCHAR(255),
  is_active BOOLEAN DEFAULT TRUE,
  last_login_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_email (email),
  KEY idx_level (level),
  KEY idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Chapters (Master Data)
CREATE TABLE chapters (
  chapter_id INT PRIMARY KEY,
  title VARCHAR(100) NOT NULL,
  description VARCHAR(500),
  difficulty INT,
  scenario_count INT,
  order_index INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Scenarios (Master Data)
CREATE TABLE scenarios (
  scenario_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  chapter_id INT NOT NULL,
  title VARCHAR(100),
  context LONGTEXT,
  initial_message VARCHAR(500),
  phishing_type VARCHAR(50),
  is_phishing BOOLEAN,
  required_evidence JSON,
  difficulty INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY idx_chapter (chapter_id),
  FOREIGN KEY (chapter_id) REFERENCES chapters(chapter_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 나머지 테이블(chapter_progress, scenario_records, chat_history, evidence,
-- achievements, user_achievements, daily_missions, attendance, phishing_index)은
-- docs/PRD.md 13장을 참고해 후속 마이그레이션(V2__...)으로 추가한다.
