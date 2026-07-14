from faster_whisper import WhisperModel

_model = None


def _get_model() -> WhisperModel:
    global _model
    if _model is None:
        _model = WhisperModel("base", device="cpu", compute_type="int8")
    return _model


def transcribe_audio(file_path: str) -> str:
    print("STT 파일:", file_path)

    segments, info = _get_model().transcribe(
        file_path,
        language="ko",
        beam_size=5
    )

    print(
        "감지 언어:",
        info.language,
        "확률:",
        info.language_probability
    )

    texts = []

    for segment in segments:
        print("segment:", segment.text)
        texts.append(segment.text)

    result = " ".join(texts)

    print("최종 STT:", result)

    return result.strip()