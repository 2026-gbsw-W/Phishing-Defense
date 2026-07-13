import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/game/chapter.dart';
import '../models/game/chat_turn.dart';
import '../models/game/evidence_confirm_result.dart';
import '../models/game/evidence_item.dart';
import '../models/game/judgment_result.dart';
import '../models/game/report_claim_result.dart';
import '../models/game/scenario_report.dart';
import '../models/game/scenario_start.dart';
import '../models/game/stage.dart';
import 'auth_api.dart';
import 'session_store.dart';

class GameApiException implements Exception {
  GameApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GameApi {
  GameApi._();

  static Future<Map<String, String>> _authHeaders() async {
    final session = await SessionStore.load();
    if (session == null) {
      throw GameApiException('로그인이 필요합니다.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${session.accessToken}',
    };
  }

  static Future<http.Response> _get(String path) async {
    final response = await http
        .get(Uri.parse('$kApiBaseUrl$path'), headers: await _authHeaders())
        .timeout(const Duration(seconds: 10));
    _checkStatus(response);
    return response;
  }

  static Future<http.Response> _post(String path, [Object? body]) async {
    final response = await http
        .post(
          Uri.parse('$kApiBaseUrl$path'),
          headers: await _authHeaders(),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));
    _checkStatus(response);
    return response;
  }

  static void _checkStatus(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    if (response.statusCode == 401) {
      throw GameApiException('로그인이 만료되었습니다. 다시 로그인해주세요.');
    }
    if (response.statusCode == 409) {
      throw GameApiException('이미 처리된 요청입니다.');
    }
    throw GameApiException('요청에 실패했습니다. 잠시 후 다시 시도해주세요.');
  }

  static dynamic _decode(http.Response response) =>
      jsonDecode(utf8.decode(response.bodyBytes));

  static Future<List<Chapter>> getChapters() async {
    final response = await _get('/api/v1/chapters');
    final list = _decode(response) as List<dynamic>;
    return list
        .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Stage>> getStages(int chapterId) async {
    final response = await _get('/api/v1/chapters/$chapterId/stages');
    final list = _decode(response) as List<dynamic>;
    return list.map((e) => Stage.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<ScenarioStart> startScenario(int stageId) async {
    final response = await _post('/api/v1/scenarios/$stageId/start');
    return ScenarioStart.fromJson(_decode(response) as Map<String, dynamic>);
  }

  static Future<ChatSendResult> sendChat(int recordId, String message) async {
    final response = await _post('/api/v1/chat/$recordId/send', {
      'message': message,
    });
    return ChatSendResult.fromJson(_decode(response) as Map<String, dynamic>);
  }

  static Future<List<ChatHistoryEntry>> getChatHistory(int recordId) async {
    final response = await _get('/api/v1/chat/$recordId/history');
    final list = _decode(response) as List<dynamic>;
    return list
        .map((e) => ChatHistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<ChatHintResult> getHint(int recordId) async {
    final response = await _post('/api/v1/chat/$recordId/hint');
    return ChatHintResult.fromJson(_decode(response) as Map<String, dynamic>);
  }

  static Future<JudgmentResult> submitJudgment(
    int recordId,
    bool isPhishing,
  ) async {
    final response = await _post('/api/v1/scenarios/$recordId/judgment', {
      'isPhishing': isPhishing,
    });
    return JudgmentResult.fromJson(_decode(response) as Map<String, dynamic>);
  }

  static Future<List<EvidenceItem>> getEvidence(int recordId) async {
    final response = await _get('/api/v1/scenarios/$recordId/evidence');
    final list = _decode(response) as List<dynamic>;
    return list
        .map((e) => EvidenceItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<EvidenceConfirmResult> confirmEvidence(
    int recordId,
    List<int> selectedEvidenceIds,
  ) async {
    final response = await _post(
      '/api/v1/scenarios/$recordId/evidence/confirm',
      {'selectedEvidenceIds': selectedEvidenceIds},
    );
    return EvidenceConfirmResult.fromJson(
      _decode(response) as Map<String, dynamic>,
    );
  }

  static Future<ScenarioReport> getReport(int recordId) async {
    final response = await _get('/api/v1/scenarios/$recordId/report');
    return ScenarioReport.fromJson(_decode(response) as Map<String, dynamic>);
  }

  static Future<ReportClaimResult> claimReport(int recordId) async {
    final response = await _post('/api/v1/scenarios/$recordId/report/claim');
    return ReportClaimResult.fromJson(
      _decode(response) as Map<String, dynamic>,
    );
  }
}
