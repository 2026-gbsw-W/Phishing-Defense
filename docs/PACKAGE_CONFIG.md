# Phishing Defense - 패키지 & 환경 설정
**개발 환경 즉시 구성 가이드**

---

## 1. Frontend 패키지 (package.json)

```json
{
  "name": "phishing-defense-frontend",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "lint": "eslint src --ext ts,tsx --report-unused-disable-directives --max-warnings 0",
    "type-check": "tsc --noEmit",
    "test": "vitest",
    "test:coverage": "vitest --coverage"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.14.0",
    "axios": "^1.4.0",
    "zustand": "^4.3.9",
    "@tanstack/react-query": "^4.32.0",
    "framer-motion": "^10.16.4",
    "recharts": "^2.7.3",
    "react-hot-toast": "^2.4.1",
    "lucide-react": "^0.263.1",
    "clsx": "^1.2.1",
    "classnames": "^2.3.2"
  },
  "devDependencies": {
    "@types/react": "^18.2.16",
    "@types/react-dom": "^18.2.6",
    "@types/node": "^20.3.1",
    "@typescript-eslint/eslint-plugin": "^5.62.0",
    "@typescript-eslint/parser": "^5.62.0",
    "@vitejs/plugin-react": "^4.0.3",
    "@vitest/ui": "^0.34.6",
    "autoprefixer": "^10.4.14",
    "eslint": "^8.45.0",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-refresh": "^0.4.3",
    "postcss": "^8.4.24",
    "tailwindcss": "^3.3.2",
    "typescript": "^5.1.6",
    "vite": "^4.4.9",
    "vitest": "^0.34.6"
  }
}
```

### Frontend 설치 명령어
```bash
npm create vite@latest phishing-defense -- --template react-ts
cd phishing-defense
npm install

# 추가 패키지
npm install zustand @tanstack/react-query axios
npm install framer-motion recharts react-hot-toast lucide-react
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

---

## 2. Frontend 환경 설정

### .env.example
```
VITE_API_BASE_URL=http://localhost:8080
VITE_APP_NAME=Phishing Defense
VITE_VERSION=1.0.0
```

### .env.development
```
VITE_API_BASE_URL=http://localhost:8080
VITE_APP_NAME=Phishing Defense (Dev)
VITE_VERSION=1.0.0-dev
VITE_LOG_LEVEL=debug
```

### .env.production
```
VITE_API_BASE_URL=https://api.phishing-defense.com
VITE_APP_NAME=Phishing Defense
VITE_VERSION=1.0.0
VITE_LOG_LEVEL=info
```

### tsconfig.json
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,

    /* Bundler mode */
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",

    /* Linting */
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,

    /* Path aliases */
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@components/*": ["src/components/*"],
      "@pages/*": ["src/pages/*"],
      "@services/*": ["src/services/*"],
      "@stores/*": ["src/stores/*"],
      "@hooks/*": ["src/hooks/*"],
      "@types/*": ["src/types/*"],
      "@utils/*": ["src/utils/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

### vite.config.ts
```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@pages': path.resolve(__dirname, './src/pages'),
      '@services': path.resolve(__dirname, './src/services'),
      '@stores': path.resolve(__dirname, './src/stores'),
      '@hooks': path.resolve(__dirname, './src/hooks'),
      '@types': path.resolve(__dirname, './src/types'),
      '@utils': path.resolve(__dirname, './src/utils'),
    },
  },
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '/api'),
      },
    },
  },
  build: {
    outDir: 'dist',
    sourcemap: false,
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom', 'react-router-dom'],
          'query-vendor': ['@tanstack/react-query'],
          'ui-vendor': ['framer-motion', 'recharts'],
        },
      },
    },
  },
})
```

### tailwind.config.js
```javascript
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: '#3B82F6',
        secondary: '#8B5CF6',
        success: '#10B981',
        danger: '#EF4444',
        warning: '#F59E0B',
      },
      fontFamily: {
        sans: ['Pretendard', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
```

---

## 3. Backend 패키지 (pom.xml)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.1.0</version>
        <relativePath/>
    </parent>

    <groupId>com.phishing</groupId>
    <artifactId>phishing-defense</artifactId>
    <version>1.0.0</version>
    <packaging>jar</packaging>
    <name>Phishing Defense</name>
    <description>AI-based phishing defense training platform</description>

    <properties>
        <java.version>17</java.version>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <dependencies>
        <!-- Spring Boot Starters -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>

        <!-- Database -->
        <dependency>
            <groupId>com.mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>8.0.33</version>
        </dependency>

        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-core</artifactId>
            <version>9.20.0</version>
        </dependency>

        <!-- JWT -->
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-api</artifactId>
            <version>0.11.5</version>
        </dependency>

        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-impl</artifactId>
            <version>0.11.5</version>
            <scope>runtime</scope>
        </dependency>

        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-jackson</artifactId>
            <version>0.11.5</version>
            <scope>runtime</scope>
        </dependency>

        <!-- OpenAI API -->
        <dependency>
            <groupId>com.theokanning.openai-gpt3-java</groupId>
            <artifactId>service</artifactId>
            <version>0.14.0</version>
        </dependency>

        <!-- Lombok -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>

        <!-- Jackson (JSON) -->
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
        </dependency>

        <dependency>
            <groupId>com.fasterxml.jackson.datatype</groupId>
            <artifactId>jackson-datatype-jsr310</artifactId>
        </dependency>

        <!-- HTTP Client (for API calls) -->
        <dependency>
            <groupId>org.apache.httpcomponents.client5</groupId>
            <artifactId>httpclient5</artifactId>
            <version>5.2.1</version>
        </dependency>

        <!-- Utilities -->
        <dependency>
            <groupId>org.apache.commons</groupId>
            <artifactId>commons-lang3</artifactId>
        </dependency>

        <dependency>
            <groupId>commons-io</groupId>
            <artifactId>commons-io</artifactId>
            <version>2.11.0</version>
        </dependency>

        <!-- Testing -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-test</artifactId>
            <scope>test</scope>
        </dependency>

        <!-- Logging (Logback via Spring Boot) -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-logging</artifactId>
        </dependency>

        <!-- Redis (for future caching) -->
        <!-- Commented out for MVP
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis</artifactId>
        </dependency>
        -->

        <!-- NLP Libraries (Optional, for Phase 2) -->
        <!-- Commented out for MVP
        <dependency>
            <groupId>edu.stanford.nlp</groupId>
            <artifactId>stanford-corenlp</artifactId>
            <version>4.5.0</version>
        </dependency>

        <dependency>
            <groupId>edu.stanford.nlp</groupId>
            <artifactId>stanford-corenlp</artifactId>
            <version>4.5.0</version>
            <classifier>models-korean</classifier>
        </dependency>
        -->
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <excludes>
                        <exclude>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>

            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <configuration>
                    <source>17</source>
                    <target>17</target>
                    <encoding>UTF-8</encoding>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

---

## 4. Backend 환경 설정

### application.yml
```yaml
spring:
  application:
    name: phishing-defense

  datasource:
    url: jdbc:mysql://localhost:3306/phishing_defense?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
    username: root
    password: ${DB_PASSWORD:root}
    driver-class-name: com.mysql.cj.jdbc.Driver

  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQL8Dialect
        format_sql: true
        jdbc:
          batch_size: 20
          fetch_size: 50
    show-sql: false
    open-in-view: false

  jackson:
    serialization:
      write-dates-as-timestamps: false
      indent-output: true
    deserialization:
      fail-on-unknown-properties: false

logging:
  level:
    root: INFO
    com.phishing: DEBUG
    org.springframework.security: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} - %logger{36} - %msg%n"

# Server
server:
  servlet:
    context-path: /
  port: 8080
  compression:
    enabled: true
    min-response-size: 1024

# JWT
jwt:
  secret: ${JWT_SECRET:your-secret-key-change-in-production}
  expiration: 86400000  # 24 hours
  refresh-expiration: 604800000  # 7 days

# OpenAI
openai:
  api-key: ${OPENAI_API_KEY}
  model: gpt-4-turbo
  max-tokens: 500
  temperature: 0.7

# OAuth
oauth2:
  kakao:
    client-id: ${KAKAO_CLIENT_ID}
    client-secret: ${KAKAO_CLIENT_SECRET}
    token-uri: https://kauth.kakao.com/oauth/token
    user-info-uri: https://kapi.kakao.com/v2/user/me
    redirect-uri: ${KAKAO_REDIRECT_URI:http://localhost:3000/auth/kakao/callback}

  naver:
    client-id: ${NAVER_CLIENT_ID}
    client-secret: ${NAVER_CLIENT_SECRET}
    token-uri: https://nid.naver.com/oauth2.0/token
    user-info-uri: https://openapi.naver.com/v1/nid/me
    redirect-uri: ${NAVER_REDIRECT_URI:http://localhost:3000/auth/naver/callback}

# Actuator (for monitoring)
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  endpoint:
    health:
      show-details: when-authorized
```

### application-dev.yml
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/phishing_defense_dev?useSSL=false&serverTimezone=UTC
    username: root
    password: root

  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: true

logging:
  level:
    root: INFO
    com.phishing: DEBUG
    org.springframework.web: DEBUG
```

### application-prod.yml
```yaml
spring:
  datasource:
    url: ${DB_URL}
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
    hikari:
      maximum-pool-size: 10
      minimum-idle: 2

  jpa:
    hibernate:
      ddl-auto: validate

logging:
  level:
    root: WARN
    com.phishing: INFO
```

---

## 5. 데이터베이스 초기화 스크립트 (Flyway)

### V1__Initial_Schema.sql
```sql
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

-- 나머지 테이블들은 PRD.md의 Section 4에서 참조
```

---

## 6. Docker Compose (개발 환경)

### docker-compose.yml
```yaml
version: '3.9'

services:
  mysql:
    image: mysql:8.0
    container_name: phishing-defense-db
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: phishing_defense
      MYSQL_CHARSET: utf8mb4
      MYSQL_COLLATION: utf8mb4_unicode_ci
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: phishing-defense-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  mysql_data:
  redis_data:
```

### 실행
```bash
docker-compose up -d
```

---

## 7. GitHub Actions CI/CD (선택사항)

### .github/workflows/deploy.yml
```yaml
name: Deploy

on:
  push:
    branches: [main, develop]

jobs:
  test-and-build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'

    - name: Build Backend
      run: |
        cd backend
        mvn clean package -DskipTests

    - name: Set up Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'

    - name: Build Frontend
      run: |
        cd frontend
        npm ci
        npm run build

    - name: Run Tests
      run: |
        cd backend
        mvn test

  deploy:
    needs: test-and-build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest

    steps:
    - name: Deploy to AWS
      run: |
        echo "Deploying to production..."
        # AWS CLI commands here
```

---

## 8. 개발 환경 체크리스트

### 설치 확인
```bash
# Node.js & npm
node --version   # v18.0.0 이상
npm --version    # 9.0.0 이상

# Java & Maven
java -version    # 17 이상
mvn --version    # 3.9.0 이상

# MySQL
mysql --version  # 8.0 이상

# Git
git --version    # 2.40.0 이상
```

### 프로젝트 설정 완료 확인
```bash
# Frontend
cd frontend
npm install
npm run dev        # http://localhost:3000에서 실행 확인

# Backend
cd backend
mvn clean install
mvn spring-boot:run # http://localhost:8080에서 실행 확인

# Database
mysql -u root -p
> USE phishing_defense;
> SHOW TABLES;
```

---

## 9. IDE 플러그인 권장

### VS Code
```json
{
  "extensions": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-typescript-next",
    "ms-vscode.makefile-tools",
    "redhat.vscode-xml",
    "redhat.vscode-yaml",
    "eamodio.gitlens"
  ]
}
```

### IntelliJ IDEA
```
Plugins:
- Database Tools and SQL
- Spring Boot Assistant
- Kotlin
- EnvFile
- Rainbow Brackets
```

---

## 10. 버전 관리 전략

### Git Branching Model (Git Flow)
```
main (production)
  └─ release-1.0
develop (development)
  ├─ feature/ai-chat
  ├─ feature/evidence-extraction
  └─ bugfix/jwt-token

태그:
  └─ v1.0.0, v1.0.1, ...
```

### Commit Convention
```
feat: 새로운 기능
fix: 버그 수정
docs: 문서 수정
style: 코드 스타일 (포맷팅, 세미콜론 등)
refactor: 코드 리팩토링
test: 테스트 추가/수정
chore: 빌드 설정, 패키지 업데이트

예시:
feat: Add AI chat API endpoint
fix: Correct XP calculation formula
docs: Update README with setup instructions
```

---

## 11. 즉시 실행 가능한 명령어

### Frontend 초기 설정
```bash
# 프로젝트 생성
npm create vite@latest phishing-defense-frontend -- --template react-ts
cd phishing-defense-frontend

# 의존성 설치
npm install
npm install zustand @tanstack/react-query axios
npm install framer-motion recharts react-hot-toast lucide-react
npm install -D tailwindcss postcss autoprefixer

# Tailwind 설정
npx tailwindcss init -p

# 개발 서버 실행
npm run dev
```

### Backend 초기 설정
```bash
# Spring Boot 프로젝트 생성
mvn archetype:generate \
  -DgroupId=com.phishing \
  -DartifactId=phishing-defense-backend \
  -DarchetypeArtifactId=maven-archetype-webapp

# 또는 Spring Boot CLI 사용
spring boot new \
  --build maven \
  --language java \
  --package-name com.phishing \
  phishing-defense-backend

# 의존성 설치 및 빌드
cd phishing-defense-backend
mvn clean install

# 개발 서버 실행
mvn spring-boot:run
```

### 데이터베이스 초기화 (Docker)
```bash
docker-compose up -d

# MySQL 접속
mysql -h 127.0.0.1 -u root -proot phishing_defense

# 스키마 확인
SHOW TABLES;
```

---

## 최종 체크리스트

- [ ] Node.js 18+ 설치
- [ ] Java 17+ 설치
- [ ] MySQL 8.0 설치 또는 Docker 설정
- [ ] Frontend 프로젝트 생성 및 패키지 설치
- [ ] Backend 프로젝트 생성 및 pom.xml 설정
- [ ] .env 파일 생성
- [ ] application.yml 설정
- [ ] Flyway 마이그레이션 스크립트 준비
- [ ] Git 저장소 초기화
- [ ] IDE 플러그인 설치
- [ ] 로컬 개발 서버 정상 작동 확인

**모든 준비가 완료되면 개발을 즉시 시작할 수 있습니다! 🚀**
