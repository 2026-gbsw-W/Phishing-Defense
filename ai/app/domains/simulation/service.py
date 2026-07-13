from langchain_openai import ChatOpenAI
from app.core.config import settings

llm = ChatOpenAI(
    base_url=settings.OLLAMA_BASE_URL,
    api_key="ollama",              # Ollama는 실제 키 검증 안 함, 아무 문자열이나 OK
    model=settings.OLLAMA_MODEL,
)