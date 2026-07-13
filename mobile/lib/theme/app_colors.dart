import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF08060A);
  static const Color surface = Color(0xFF14101A);
  static const Color surfaceAlt = Color(0xFF1C1622);

  static const Color alarm = Color(0xFFFF453F);
  static const Color alarmDim = Color(0x1FFF453F);
  static const Color safe = Color(0xFF29C784);
  static const Color amber = Color(0xFFF5A623);

  /// 레드(alarm) 배경 위에 올라가는 텍스트 색. 흰색 대신 진한 브라운블랙을 쓴다.
  static const Color onAlarm = Color(0xFF2A0806);

  static const Color textPrimary = Color(0xFFF5F3F6);
  static const Color textSecondary = Color(0xFF9A92A3);

  static const Color border = Color(0x14FFFFFF);
}
