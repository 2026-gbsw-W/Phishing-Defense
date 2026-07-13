import 'dart:convert';

import 'package:http/http.dart' as http;

/// 백엔드 서버 주소. iOS 시뮬레이터 기준 localhost로 접근 가능하다.
/// 실기기/Android 에뮬레이터에서 테스트할 때는 값을 바꿔야 한다.
const String kApiBaseUrl = 'http://localhost:8080';

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.email,
    required this.nickname,
    required this.level,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      userId: json['userId'] as int,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      level: json['level'] as int,
    );
  }

  final String accessToken;
  final String refreshToken;
  final int userId;
  final String email;
  final String nickname;
  final int level;
}

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthApi {
  AuthApi._();

  static Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('$kApiBaseUrl/api/v1/auth/login'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return AuthSession.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    }

    if (response.statusCode == 401 || response.statusCode == 400) {
      throw AuthException('이메일 또는 비밀번호가 올바르지 않습니다.');
    }

    throw AuthException('로그인에 실패했습니다. 잠시 후 다시 시도해주세요.');
  }

  static Future<AuthSession> signup({
    required String email,
    required String password,
    required String nickname,
  }) async {
    final response = await http
        .post(
          Uri.parse('$kApiBaseUrl/api/v1/auth/signup'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
            'nickname': nickname,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201 || response.statusCode == 200) {
      return AuthSession.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    }

    if (response.statusCode == 409) {
      throw AuthException('이미 가입된 이메일 또는 닉네임입니다.');
    }

    if (response.statusCode == 400) {
      throw AuthException('입력값을 다시 확인해주세요.');
    }

    throw AuthException('회원가입에 실패했습니다. 잠시 후 다시 시도해주세요.');
  }

  static Future<AuthSession> refresh({required String refreshToken}) async {
    final response = await http
        .post(
          Uri.parse('$kApiBaseUrl/api/v1/auth/refresh'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refreshToken}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return AuthSession.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    }

    throw AuthException('세션이 만료되었습니다. 다시 로그인해주세요.');
  }
}
