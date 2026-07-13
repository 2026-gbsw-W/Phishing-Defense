from elevenlabs.client import ElevenLabs
from core.config import settings
import os

_client = ElevenLabs(
    api_key=settings.ELEVENLABS_API_KEY
)

MOCK_TTS = False


def synthesize_speech(text: str, output_path: str) -> str:

    # 개발용 테스트 모드
    if MOCK_TTS:
        with open(output_path, "wb") as f:
            f.write(b"")

        print(f"[MOCK TTS] 생성 안 함: {text[:50]}...")
        return output_path


    try:
        # ElevenLabs 실제 음성 생성
        audio = _client.text_to_speech.convert(
            voice_id="21m00Tcm4TlvDq8ikWAM",
            text=text,
            model_id="eleven_multilingual_v2",
            output_format="mp3_44100_128"
        )

        # mp3 저장
        with open(output_path, "wb") as f:
            for chunk in audio:
                f.write(chunk)


        # 파일 생성 확인
        if not os.path.exists(output_path):
            raise Exception("음성 파일 생성 실패")

        file_size = os.path.getsize(output_path)

        if file_size == 0:
            raise Exception("생성된 음성 파일이 비어있음")


        print(f"[TTS SUCCESS] {output_path} ({file_size} bytes)")

        return output_path


    except Exception as e:
        print(f"[TTS ERROR] {e}")
        raise e