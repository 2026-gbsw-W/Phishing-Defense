from dotenv import load_dotenv
import os

load_dotenv()

class Settings:
    OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
    ELEVENLABS_API_KEY = os.getenv("ELEVENLABS_API_KEY")
    WHISPER_MODEL_SIZE = "base"
    DATABASE_URL = os.getenv("DATABASE_URL")


settings = Settings()

if __name__ == "__main__":
    print(settings.OPENAI_API_KEY)
    print(settings.WHISPER_MODEL_SIZE)
