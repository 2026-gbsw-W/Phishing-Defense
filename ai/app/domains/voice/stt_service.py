from faster_whisper import WhisperModel

_model = WhisperModel("base", device="cpu", compute_type="int8")


def transcribe_audio(file_path: str) -> str:
    segments, info = _model.transcribe(file_path, language="ko")
    text = " ".join(segment.text for segment in segments)
    return text.strip()