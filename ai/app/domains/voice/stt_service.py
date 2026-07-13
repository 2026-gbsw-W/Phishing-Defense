from faster_whisper import WhisperModel

_model = None


def _get_model() -> WhisperModel:
    global _model
    if _model is None:
        _model = WhisperModel("base", device="cpu", compute_type="int8")
    return _model


def transcribe_audio(file_path: str) -> str:
    segments, _ = _get_model().transcribe(file_path, language="ko")
    text = " ".join(segment.text for segment in segments)
    return text.strip()