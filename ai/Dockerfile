# Python 3.11 — faster-whisper / pydantic 호환 버전
FROM python:3.11-slim

WORKDIR /app

# 시스템 의존성 (faster-whisper용 ffmpeg, ctranslate2용 빌드 도구)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# app/ 내부를 바로 /app 에 복사 → 로컬과 동일한 import 경로 유지
COPY app/ .

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
