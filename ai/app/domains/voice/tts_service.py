import edge_tts
import asyncio


VOICE_MAP = {
    "prosecutor": "ko-KR-InJoonNeural",
    "bank": "ko-KR-SunHiNeural",
    "family": "ko-KR-SoonBokNeural",
    "loan": "ko-KR-InJoonNeural"
}


async def generate_voice(
    text: str,
    output_path: str,
    scenario_type: str
):

    voice = VOICE_MAP.get(
        scenario_type,
        VOICE_MAP["prosecutor"]
    )

    communicate = edge_tts.Communicate(
        text=text,
        voice=voice
    )

    await communicate.save(output_path)


def synthesize_speech(
    text: str,
    output_path: str,
    scenario_type: str = "prosecutor"
) -> str:

    try:
        asyncio.run(
            generate_voice(
                text,
                output_path,
                scenario_type
            )
        )

        return output_path

    except Exception as e:
        print("TTS 오류:", e)
        raise
