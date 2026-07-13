import 'package:shared_preferences/shared_preferences.dart';

import 'auth_api.dart';

/// 로그인 세션(토큰/유저 정보)을 기기에 저장하고 불러온다.
class SessionStore {
  SessionStore._();

  static const _keyAccessToken = 'auth.accessToken';
  static const _keyRefreshToken = 'auth.refreshToken';
  static const _keyUserId = 'auth.userId';
  static const _keyEmail = 'auth.email';
  static const _keyNickname = 'auth.nickname';
  static const _keyLevel = 'auth.level';
  static const _keyLastEmail = 'auth.lastEmail';

  static Future<void> save(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, session.accessToken);
    await prefs.setString(_keyRefreshToken, session.refreshToken);
    await prefs.setInt(_keyUserId, session.userId);
    await prefs.setString(_keyEmail, session.email);
    await prefs.setString(_keyNickname, session.nickname);
    await prefs.setInt(_keyLevel, session.level);
  }

  static Future<AuthSession?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_keyAccessToken);
    final refreshToken = prefs.getString(_keyRefreshToken);
    final email = prefs.getString(_keyEmail);
    final nickname = prefs.getString(_keyNickname);
    final userId = prefs.getInt(_keyUserId);
    final level = prefs.getInt(_keyLevel);

    if (accessToken == null ||
        refreshToken == null ||
        email == null ||
        nickname == null ||
        userId == null ||
        level == null) {
      return null;
    }

    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      email: email,
      nickname: nickname,
      level: level,
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyNickname);
    await prefs.remove(_keyLevel);
  }

  /// 로그인 화면에서 마지막으로 로그인에 성공한 이메일을 기억해 자동으로
  /// 채워준다. 로그아웃([clear])해도 지워지지 않는다.
  static Future<void> saveLastEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastEmail, email);
  }

  static Future<String?> loadLastEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastEmail);
  }
}
