import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/sorak_toggle_group.dart';
import '../providers/auth_provider.dart';

enum LoginMode { parent, staff }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _staffEmailController = TextEditingController();
  final _staffPasswordController = TextEditingController();
  final _parentCardController = TextEditingController();
  final _parentPasswordController = TextEditingController();

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
        content: Text(authProvider.errorMessage ?? 'Đăng nhập thất bại'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final isParent = _mode == LoginMode.parent;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                const SizedBox(height: AppSpacing.lg),
                _LoginHeader(isParent: isParent),
                const SizedBox(height: AppSpacing.lg),
                SorakToggleGroup<LoginMode>(
                  options: const [
                    SorakToggleOption(
                      value: LoginMode.parent,
                      label: 'Phụ huynh',
                      icon: LucideIcons.users,
                    ),
                    SorakToggleOption(
                      value: LoginMode.staff,
                      label: 'Cán bộ',
                      icon: LucideIcons.badgeCheck,
                    ),
                  ],
                  selected: _mode,
                  enabled: !isLoading,
                  onChanged: (value) {
                    setState(() {
                      _mode = value;
                      _showPassword = false;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        if (isParent)
                          _LoginField(
                            key: const ValueKey('parent_card_field'),
                            controller: _parentCardController,
                            label: 'Mã thẻ học sinh',
                            icon: LucideIcons.idCard,
                            keyboardType: TextInputType.text,
                          )
                        else
                          _LoginField(
                            key: const ValueKey('staff_email_field'),
                            controller: _staffEmailController,
                            label: 'Email',
                            icon: LucideIcons.mail,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        const SizedBox(height: AppSpacing.sm),
                        _LoginField(
                          key: ValueKey(
                            isParent
                                ? 'parent_password_field'
                                : 'staff_password_field',
                          ),
                          controller: isParent
                              ? _parentPasswordController
                              : _staffPasswordController,
                          label: 'Mật khẩu',
                          icon: LucideIcons.lock,
                          obscureText: !_showPassword,
                          suffixIcon: IconButton(
                            tooltip: _showPassword
                                ? 'Ẩn mật khẩu'
                                : 'Hiện mật khẩu',
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                            icon: Icon(
                              _showPassword
                                  ? LucideIcons.eyeOff
                                  : LucideIcons.eye,
                              size: 20,
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
                                    color: AppColors.primaryForeground,
                                  ),
                                )
                              : const Icon(LucideIcons.logIn, size: 18),
                          label: const Text('Đăng nhập'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isParent) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Quên mật khẩu? Vui lòng liên hệ giáo viên chủ nhiệm để được hỗ trợ.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({required this.isParent});

  final bool isParent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
          ),
          child: const Icon(
            LucideIcons.school,
            color: AppColors.primaryForeground,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Sorak Mầm non',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.foreground,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          isParent
              ? 'Theo dõi hồ sơ và báo cáo của trẻ.'
              : 'Quản lý lớp học, hồ sơ và đánh giá sức khỏe.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.mutedForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LoginField extends StatelessWidget {
  const _LoginField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
