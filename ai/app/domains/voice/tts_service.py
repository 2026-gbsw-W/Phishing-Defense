from elevenlabs.client import ElevenLabs
from core.config import settings

_client = ElevenLabs(api_key=settings.ELEVENLABS_API_KEY)

MOCK_TTS = False  # 개발 중엔 True, 최종 데모 리허설 때만 False로 바꿔서 테스트


def synthesize_speech(text: str, output_path: str) -> str:
    if MOCK_TTS:
        # 실제 API 호출 없이 빈 파일만 만들어서 흐름 테스트
        with open(output_path, "wb") as f:
            f.write(b"")
        print(f"[MOCK TTS] 실제 호출 안 함. 텍스트: {text[:50]}...")
        return output_path

    audio = _client.text_to_speech.convert(
        voice_id="21m00Tcm4TlvDq8ikWAM",
        text=text,
        model_id="eleven_multilingual_v2",
    )
    with open(output_path, "wb") as f:
        for chunk in audio:
            f.write(chunk)
    return output_path