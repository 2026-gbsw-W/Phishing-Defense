import 'package:flutter/material.dart';

import '../../services/auth_api.dart';
import '../../services/session_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth_text_field.dart';
import '../scenario_selection/scenario_selection_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();

  bool _obscurePassword = true;
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final nickname = _nicknameController.text.trim();

    if (email.isEmpty || password.isEmpty || nickname.isEmpty) {
      setState(() => _errorText = '이메일, 비밀번호, 닉네임을 모두 입력해주세요.');
      return;
    }
    if (password.length < 8) {
      setState(() => _errorText = '비밀번호는 8자 이상이어야 합니다.');
      return;
    }
    if (nickname.length < 2) {
      setState(() => _errorText = '닉네임은 2자 이상이어야 합니다.');
      return;
    }

    setState(() {
      _errorText = null;
      _submitting = true;
    });

    try {
      final session = await AuthApi.signup(
        email: email,
        password: password,
        nickname: nickname,
      );
      await SessionStore.save(session);
      await SessionStore.saveLastEmail(email);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ScenarioSelectionScreen()),
        (_) => false,
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
      appBar: AppBar(title: const Text('회원가입')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  '피싱 디펜스와 함께 훈련을 시작해보세요.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                AuthTextField(
                  controller: _emailController,
                  label: '이메일',
                  hint: 'name@example.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _nicknameController,
                  label: '닉네임',
                  hint: '2~50자, 한글/영문/숫자',
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _passwordController,
                  label: '비밀번호',
                  hint: '8자 이상 입력하세요',
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
                  Text(
                    _errorText!,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.alarm,
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
                        : const Text('회원가입'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
