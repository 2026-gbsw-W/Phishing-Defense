import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // 디자인 시스템 규칙: 본문/제목은 Noto Sans KR. IBM Plex Mono는 한글 문장에
  // 쓰면 자간이 벌어져 보이므로 전역 테마에는 넣지 않고, 순수 숫자·영문
  // 표기(스테이지 번호, XP, 타이머 등)에만 [AppTheme.mono]로 개별 적용한다.
  static TextTheme _textTheme(TextTheme base) {
    return GoogleFonts.notoSansKrTextTheme(base);
  }

  /// 숫자/영문 라벨 전용(예: "01", "Lv.5", "12:34"). 한글 문장에는 쓰지 않는다.
  static TextStyle mono(TextStyle? base) =>
      GoogleFonts.ibmPlexMono(textStyle: base, fontWeight: FontWeight.w600);

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.alarm,
      secondary: AppColors.safe,
      error: AppColors.alarm,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
    );

    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _textTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.alarm,
          foregroundColor: AppColors.onAlarm,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}
