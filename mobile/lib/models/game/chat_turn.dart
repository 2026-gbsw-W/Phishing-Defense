class ExtractedEvidenceItem {
  const ExtractedEvidenceItem({required this.type, required this.value});

  factory ExtractedEvidenceItem.fromJson(Map<String, dynamic> json) {
    return ExtractedEvidenceItem(
      type: json['type'] as String,
      value: json['value'] as String,
    );
  }

  final String type;
  final String value;
}

class ChatSendResult {
  const ChatSendResult({
    required this.aiResponse,
    required this.turn,
    required this.extractedEvidence,
    required this.hintAvailable,
  });

  factory ChatSendResult.fromJson(Map<String, dynamic> json) {
    return ChatSendResult(
      aiResponse: json['aiResponse'] as String,
      turn: json['turn'] as int,
      extractedEvidence: (json['extractedEvidence'] as List<dynamic>? ?? [])
          .map((e) => ExtractedEvidenceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      hintAvailable: json['hintAvailable'] as bool? ?? false,
    );
  }

  final String aiResponse;
  final int turn;
  final List<ExtractedEvidenceItem> extractedEvidence;
  final bool hintAvailable;
}

class ChatHistoryEntry {
  const ChatHistoryEntry({
    required this.turn,
    required this.sender,
    required this.message,
  });

  factory ChatHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ChatHistoryEntry(
      turn: json['turn'] as int,
      sender: json['sender'] as String,
      message: json['message'] as String,
    );
  }

  final int turn;
  final String sender;
  final String message;

  bool get isUser => sender == 'user';
}

class ChatHintResult {
  const ChatHintResult({required this.hintText, required this.remainingHints});

  factory ChatHintResult.fromJson(Map<String, dynamic> json) {
    return ChatHintResult(
      hintText: json['hintText'] as String,
      remainingHints: json['remainingHints'] as int,
    );
  }

  final String hintText;
  final int remainingHints;
}
