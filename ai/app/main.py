from fastapi import FastAPI, HTTPException
from fastapi import UploadFile, File
from fastapi.responses import FileResponse
from domains.voice.stt_service import transcribe_audio
from domains.voice.tts_service import (
    synthesize_speech,
    VOICE_MAP
)
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
from fastapi import WebSocket, WebSocketDisconnect
from domains.voice.tts_service import VOICE_MAP


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

llm = ChatOllama(
    model=os.getenv("OLLAMA_MODEL", "llama3.1:8b"),
    temperature=1.0,
    base_url=os.getenv("OLLAMA_BASE_URL", "http://localhost:11434"),
)

# session_id -> 대화 기록
# session_id -> 분석 리포트
# session_id -> 수집 증거
session_histories: dict[str, list] = {}
session_reports: dict[str, dict] = {}
session_evidences: dict[str, list] = {}
session_hints: dict[str, int] = {}




class ChatRequest(BaseModel):
    message: str
    session_id: str | None = None 
    scenario_type: str = "prosecutor" 

class EvidenceRequest(BaseModel):
    session_id: str
    message: str
    speaker: str = "AI(사기꾼)"

class EndChatRequest(BaseModel):
    session_id: str

class HintRequest(BaseModel):
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
  "dangerous_messages": [
    "위험 신호로 판단되는 실제 대화 내용"
  ],
  "evidence_feedback": "사용자가 저장한 증거에 대한 평가",
  "good_points": "사용자가 잘 대응한 점을 한국어 문장으로",
  "mistakes": "사용자가 취약했던 부분을 한국어 문장으로",
  "improvement_tips": "개선 방법을 한국어 문장으로"
}}

# 대화 기록
{conversation}

# 사용자가 수집한 증거
{evidence}
"""

HINT_PROMPT_TEMPLATE = """
당신은 보이스피싱 대응 훈련 AI 코치입니다.
사용자는 현재 AI 사기꾼과 대화 중이며 대응에 어려움을 느끼고 있습니다.
사용자가 스스로 판단할 수 있도록 단계별 힌트를 제공합니다.

규칙:
- 정답을 바로 알려주지 않습니다.
- 의심해야 하는 부분을 알려줍니다.
- 사용자가 다음 행동을 생각할 수 있도록 유도합니다.
- 짧고 이해하기 쉬운 한국어로 답변합니다.

현재 대화:
{conversation}
"""

def format_conversation(history: list) -> str:
    lines = []
    for msg in history:
        if isinstance(msg, SystemMessage):
            continue 
        role = "사용자" if isinstance(msg, HumanMessage) else "AI(사기꾼)"
        lines.append(f"{role}: {msg.content}")
    return "\n".join(lines)

@app.post("/evidence")
def save_evidence(req: EvidenceRequest):

    if req.session_id not in session_histories:
        raise HTTPException(
            status_code=404,
            detail="세션을 찾을 수 없습니다."
        )

    if req.session_id not in session_evidences:
        session_evidences[req.session_id] = []


    evidence = {
        "evidence_id": str(uuid.uuid4()),
        "speaker": req.speaker,
        "message": req.message,
        "created_at": datetime.now().isoformat()
    }


    session_evidences[req.session_id].append(evidence)


    return {
        "message": "증거가 저장되었습니다.",
        "evidence": evidence
    }

@app.post("/hint")
def get_hint(req: HintRequest):

    if req.session_id not in session_histories:
        raise HTTPException(
            status_code=404,
            detail="세션을 찾을 수 없습니다."
        )

    history = session_histories[req.session_id]

    conversation_text = format_conversation(history)

    prompt = HINT_PROMPT_TEMPLATE.format(
        conversation=conversation_text
    )

    response = llm.invoke(
        [HumanMessage(content=prompt)]
    )

    session_hints[req.session_id] = (
        session_hints.get(req.session_id, 0) + 1
    )

    return {
        "session_id": req.session_id,
        "hint": response.content,
        "hint_count": session_hints[req.session_id]
    }

@app.post("/chat/end")
def end_chat(req: EndChatRequest):

    if req.session_id not in session_histories:
        raise HTTPException(
            status_code=404,
            detail="세션을 찾을 수 없습니다."
        )

    history = session_histories[req.session_id]

    conversation_text = format_conversation(history)

    evidence = session_evidences.get(
    req.session_id,
    []
)

    evidence_text = json.dumps(
        evidence,
        ensure_ascii=False
    )

    prompt = ANALYSIS_PROMPT_TEMPLATE.format(
        conversation=conversation_text,
        evidence=evidence_text
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
        "report": result,
        "evidences": session_evidences.get(req.session_id, [])
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
        "report": session_reports[session_id],
        "evidences": session_evidences.get(session_id, [])
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
    synthesize_speech(
        chat_result["answer"],
        output_path,
        scenario_type
    )
    return FileResponse(
            output_path,
            media_type="audio/mpeg",
            headers={
                "X-Session-Id": chat_result["session_id"],
                "X-User-Text": quote(user_text),
                "X-AI-Text": quote(chat_result["answer"]),
            }
        )

@app.websocket("/voice-call/{scenario_type}")
async def voice_call(
    websocket: WebSocket,
    scenario_type: str
):

    await websocket.accept()

    if scenario_type not in VOICE_MAP:
        await websocket.close(
            code=1008,
            reason="지원하지 않는 시나리오"
        )
        return

    # 세션 생성
    session_id = str(uuid.uuid4())

    session_hints[session_id] = 0
    session_evidences[session_id] = []

    try:
        # 1. AI 첫 멘트 생성

        first_response = chat(ChatRequest(
            message="전화가 연결되었습니다. 피싱 상황의 첫 멘트를 시작하세요.",
            session_id=session_id,
            scenario_type=scenario_type
        ))


        # 2. 첫 멘트 TTS 생성

        first_audio = f"response_{uuid.uuid4()}.mp3"

        try:
            synthesize_speech(
                first_response["answer"],
                first_audio,
                scenario_type
            )

            with open(first_audio, "rb") as f:
                voice = f.read()

        except Exception as e:
            print("첫 TTS 오류:", e)

            await websocket.send_json({
                "error": "첫 음성 생성 실패",
                "message": str(e)
            })
            return


        await websocket.send_json({
            "session_id": session_id,
            "ai_text": first_response["answer"]
        })

        await websocket.send_bytes(voice)

        if os.path.exists(first_audio):
            os.remove(first_audio)

        # 3. 사용자 음성 반복 처리

        while True:

            audio_data = await websocket.receive_bytes()


            # 음성 파일 저장
            input_path = f"temp_{uuid.uuid4()}.wav"

            with open(input_path, "wb") as f:
                f.write(audio_data)

            # STT
            user_text = transcribe_audio(input_path)

            if os.path.exists(input_path):
                os.remove(input_path)


            print("사용자:", user_text)

            # LLM 응답 생성
            result = chat(ChatRequest(
                message=user_text,
                session_id=session_id,
                scenario_type=scenario_type
            ))

            ai_text = result["answer"]

            # 4. AI 응답 TTS
            output_path = f"response_{uuid.uuid4()}.mp3"


            try:

                synthesize_speech(
                    ai_text,
                    output_path,
                    scenario_type
                )

                with open(output_path, "rb") as f:
                    voice = f.read()


            except Exception as e:

                print("TTS 오류:", e)

                await websocket.send_json({
                    "error": "음성 생성 실패",
                    "message": str(e)
                })

                continue

            # 텍스트 전달
            await websocket.send_json({
                "session_id": session_id,
                "user_text": user_text,
                "ai_text": ai_text
            })

            # 음성 전달
            await websocket.send_bytes(voice)


            if os.path.exists(output_path):
                os.remove(output_path)

    except WebSocketDisconnect:

        print("통화 종료")


        # 종료 후 리포트 생성
        if session_id in session_histories:

            try:

                end_chat(
                    EndChatRequest(
                        session_id=session_id
                    )
                )

                print(
                    f"리포트 생성 완료: {session_id}"
                )


            except Exception as e:

                print(
                    "리포트 생성 실패:",
                    e
                )


    except Exception as e:

        print(
            "WebSocket 오류:",
            e
        )

        try:
            await websocket.close()

        except:
            pass