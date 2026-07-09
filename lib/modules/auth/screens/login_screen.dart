import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/auth_provider.dart';

enum LoginMode { parent, staff }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _staffEmailController = TextEditingController(
    text: 'admin@sorak.edu.vn',
  );
  final _staffPasswordController = TextEditingController(text: '123456');
  final _parentCardController = TextEditingController(text: 'NBA2024.001');
  final _parentPasswordController = TextEditingController(text: '123456');

  LoginMode _mode = LoginMode.parent;
  bool _showPassword = false;

  @override
  void dispose() {
    _staffEmailController.dispose();
    _staffPasswordController.dispose();
    _parentCardController.dispose();
    _parentPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final authProvider = context.read<AuthProvider>();
    final success = switch (_mode) {
      LoginMode.staff => await authProvider.loginStaff(
        email: _staffEmailController.text.trim(),
        password: _staffPasswordController.text.trim(),
      ),
      LoginMode.parent => await authProvider.loginParent(
        studentCardNumber: _parentCardController.text.trim(),
        password: _parentPasswordController.text.trim(),
      ),
    };

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(authProvider.errorMessage ?? 'Login failed'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final isParent = _mode == LoginMode.parent;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Sorak Mam Non',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isParent
                  ? 'Parent portal for child health and growth.'
                  : 'Staff access for school management.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textGray),
            ),
            const SizedBox(height: AppSpacing.lg),
            SegmentedButton<LoginMode>(
              segments: const [
                ButtonSegment<LoginMode>(
                  value: LoginMode.parent,
                  icon: Icon(Icons.family_restroom_outlined),
                  label: Text('Phụ huynh'),
                ),
                ButtonSegment<LoginMode>(
                  value: LoginMode.staff,
                  icon: Icon(Icons.badge_outlined),
                  label: Text('Cán bộ'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: isLoading
                  ? null
                  : (values) {
                      setState(() {
                        _mode = values.first;
                        _showPassword = false;
                      });
                    },
            ),
            const SizedBox(height: AppSpacing.lg),
            if (isParent)
              _LoginField(
                key: const ValueKey('parent_card_field'),
                controller: _parentCardController,
                label: 'Mã thẻ học sinh',
                keyboardType: TextInputType.text,
              )
            else
              _LoginField(
                key: const ValueKey('staff_email_field'),
                controller: _staffEmailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
            const SizedBox(height: AppSpacing.sm),
            _LoginField(
              key: ValueKey(
                isParent ? 'parent_password_field' : 'staff_password_field',
              ),
              controller: isParent
                  ? _parentPasswordController
                  : _staffPasswordController,
              label: 'Password',
              obscureText: !_showPassword,
              suffixIcon: IconButton(
                tooltip: _showPassword ? 'Hide password' : 'Show password',
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
                icon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              key: const ValueKey('login_button'),
              onPressed: isLoading ? null : _login,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.login),
              label: const Text('Login'),
            ),
            if (isParent) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Quên mật khẩu? Liên hệ giáo viên chủ nhiệm để đặt lại.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textGray),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  const _LoginField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(labelText: label, suffixIcon: suffixIcon),
    );
  }
}
