import 'package:flutter/material.dart';

import '../../services/auth_api.dart';
import '../../services/session_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth_text_field.dart';
import '../scenario_selection/scenario_selection_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _submitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _fillRememberedEmail();
  }

  Future<void> _fillRememberedEmail() async {
    final lastEmail = await SessionStore.loadLastEmail();
    if (mounted && lastEmail != null) {
      _emailController.text = lastEmail;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorText = '이메일과 비밀번호를 입력해주세요.');
      return;
    }

    setState(() {
      _errorText = null;
      _submitting = true;
    });

    try {
      final session = await AuthApi.login(email: email, password: password);
      await SessionStore.save(session);
      await SessionStore.saveLastEmail(email);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ScenarioSelectionScreen()),
      );
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
    } catch (_) {
      setState(() => _errorText = '서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.alarm.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: AppColors.alarm,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('피싱 디펜스', style: textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    '로그인하고 훈련을 이어가세요.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AuthTextField(
                    controller: _emailController,
                    label: '이메일',
                    hint: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _passwordController,
                    label: '비밀번호',
                    hint: '비밀번호를 입력하세요',
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _errorText!,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.alarm,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onAlarm,
                              ),
                            )
                          : const Text('로그인'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _submitting
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                          },
                    child: Text(
                      '계정이 없으신가요? 회원가입',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
