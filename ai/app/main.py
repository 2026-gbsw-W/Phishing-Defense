from fastapi import FastAPI, HTTPException
from fastapi import UploadFile, File
from fastapi.responses import FileResponse
from domains.voice.stt_service import transcribe_audio
from domains.voice.tts_service import synthesize_speech
import shutil
import os
from pydantic import BaseModel
from langchain_ollama import ChatOllama
from langchain_core.messages import SystemMessage, HumanMessage, AIMessage
from domains.simulation import prompts
import uuid
import json
from urllib.parse import quote
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

llm = ChatOllama(
    model="llama3.1:8b",
    temperature=1.0,
)

# 세션ID -> 메시지 리스트 (서버 재시작하면 초기화됨, DB 저장은 나중에)
session_histories: dict[str, list] = {}
session_reports: dict[str, dict] = {}




class ChatRequest(BaseModel):
    message: str
    session_id: str | None = None       # 없으면 새 세션으로 간주
    scenario_type: str = "prosecutor"   # 새 세션일 때만 사용됨

class EndChatRequest(BaseModel):
    session_id: str


@app.get("/")
def home():
    return {"status": "AI Agent running"}


@app.get("/scenarios")
def list_scenarios():
    return {"available_scenarios": list(prompts.SCENARIO_PROMPTS.keys())}


@app.post("/chat")
def chat(req: ChatRequest):
    session_id = req.session_id or str(uuid.uuid4())

    if session_id not in session_histories:
        system_prompt = prompts.SCENARIO_PROMPTS.get(req.scenario_type)
        if system_prompt is None:
            raise HTTPException(
                status_code=400,
                detail=f"알 수 없는 시나리오입니다: {req.scenario_type}. 사용 가능: {list(prompts.SCENARIO_PROMPTS.keys())}"
            )
        session_histories[session_id] = [SystemMessage(content=system_prompt)]

    history = session_histories[session_id]
    # 세션ID -> 메시지 리스트

    history.append(HumanMessage(content=req.message))

    response = llm.invoke(history)

    history.append(AIMessage(content=response.content))

    return {
        "session_id": session_id,
        "answer": response.content
    }

ANALYSIS_PROMPT_TEMPLATE = """
당신은 보이스피싱 훈련 시뮬레이션의 대화 분석가입니다.
아래는 사용자와 AI 사기꾼 사이의 대화 기록입니다. 이 대화를 분석하여 반드시 아래 JSON 형식으로만 답변하세요. JSON 외의 다른 설명은 절대 추가하지 마세요.

{{
  "personal_info_requested": true/false,
  "account_number_requested": true/false,
  "money_requested": true/false,
  "urgency_created": true/false,
  "authority_impersonation": true/false,
  "suspicious_link": true/false,
  "user_fell_for_it": true/false,
  "risk_score": 0~100 사이 숫자,
  "good_points": "사용자가 잘 대응한 점을 한국어 문장으로",
  "mistakes": "사용자가 취약했던 부분을 한국어 문장으로",
  "improvement_tips": "개선 방법을 한국어 문장으로"
}}

# 대화 기록
{conversation}
"""

def format_conversation(history: list) -> str:
    lines = []
    for msg in history:
        if isinstance(msg, SystemMessage):
            continue  # 시스템 프롬프트는 분석 대상 아님
        role = "사용자" if isinstance(msg, HumanMessage) else "AI(사기꾼)"
        lines.append(f"{role}: {msg.content}")
    return "\n".join(lines)

@app.post("/chat/end")
def end_chat(req: EndChatRequest):

    if req.session_id not in session_histories:
        raise HTTPException(
            status_code=404,
            detail="세션을 찾을 수 없습니다."
        )

    history = session_histories[req.session_id]

    conversation_text = format_conversation(history)

    prompt = ANALYSIS_PROMPT_TEMPLATE.format(
        conversation=conversation_text
    )

    response = llm.invoke(
        [HumanMessage(content=prompt)]
    )

    raw = response.content.strip()


    if raw.startswith("```"):
        raw = raw.strip("`").replace(
            "json\n",
            "",
            1
        ).strip()

    try:
        result = json.loads(raw)

    except json.JSONDecodeError:
        raise HTTPException(
            status_code=500,
            detail=f"분석 결과 파싱 실패: {raw}"
        )


    result["created_at"] = datetime.now().isoformat()

    session_reports[req.session_id] = result


    return {
        "session_id": req.session_id,
        "report": result
    }

@app.get("/report/{session_id}")
def get_report(session_id: str):

    if session_id not in session_reports:
        raise HTTPException(
            status_code=404,
            detail="생성된 리포트가 없습니다."
        )

    return {
        "session_id": session_id,
        "report": session_reports[session_id]
    }

@app.post("/voice-chat")
def voice_chat(
    session_id: str | None = None,
    scenario_type: str = "prosecutor",
    audio_file: UploadFile = File(...),
):
    temp_input_path = f"temp_{uuid.uuid4()}.mp3"
    with open(temp_input_path, "wb") as f:
        shutil.copyfileobj(audio_file.file, f)

    user_text = transcribe_audio(temp_input_path)
    os.remove(temp_input_path)

    chat_result = chat(ChatRequest(
        message=user_text,
        session_id=session_id,
        scenario_type=scenario_type,
    ))

    output_path = f"response_{uuid.uuid4()}.mp3"
    synthesize_speech(chat_result["answer"], output_path)

    return FileResponse(
            output_path,
            media_type="audio/mpeg",
            headers={
                "X-Session-Id": chat_result["session_id"],
                "X-User-Text": quote(user_text),
                "X-AI-Text": quote(chat_result["answer"]),
            }
        )