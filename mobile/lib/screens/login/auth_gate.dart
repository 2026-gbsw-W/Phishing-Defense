import 'package:flutter/material.dart';

import '../../services/session_store.dart';
import '../../theme/app_colors.dart';
import '../scenario_selection/scenario_selection_screen.dart';
import 'login_screen.dart';

/// 앱 시작 시 저장된 로그인 세션이 있는지 확인해서 로그인 화면을 건너뛸지 정한다.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SessionStore.load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.alarm),
            ),
          );
        }

        return snapshot.data != null
            ? const ScenarioSelectionScreen()
            : const LoginScreen();
      },
    );
  }
}
