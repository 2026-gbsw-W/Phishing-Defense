from elevenlabs.client import ElevenLabs
from core.config import settings

_client = ElevenLabs(
    api_key=settings.ELEVENLABS_API_KEY
)


VOICE_MAP = {
    "prosecutor": {
        "voice_id": "21m00Tcm4TlvDq8ikWAM",
        "description": "권위적인 검찰 사칭 목소리"
    },

    "bank": {
        "voice_id": "EXAVITQu4vr4xnSDxMaL",
        "description": "차분한 금융기관 직원 목소리"
    },

    "family": {
        "voice_id": "MF3mGyEYCl7XYWbV9V6O",
        "description": "불안한 가족 사칭 목소리"
    }
}


def synthesize_speech(
    text: str,
    output_path: str,
    scenario_type: str = "prosecutor"
) -> str:

    voice_config = VOICE_MAP.get(
        scenario_type,
        VOICE_MAP["prosecutor"]
    )

    voice_id = voice_config["voice_id"]

    try:
        audio = _client.text_to_speech.convert(
            voice_id=voice_id,
            text=text,
            model_id="eleven_multilingual_v2",
            output_format="mp3_44100_128"
        )

        with open(output_path, "wb") as f:
            for chunk in audio:
                f.write(chunk)

        return output_path

    except Exception as e:
        print("TTS 오류:", e)
        raise