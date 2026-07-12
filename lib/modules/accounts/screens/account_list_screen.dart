import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_options.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/ui_labels.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/sorak_avatar.dart';
import '../../../core/widgets/sorak_status_badge.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';

enum AccountView { student, staff }

/// Account-status filter aligned with web StaffTab/StudentTab selects.
enum _AccountStatusFilter { all, active, inactive }

class AccountListScreen extends StatefulWidget {
  const AccountListScreen({super.key, this.initialView = AccountView.staff});

  /// Fixed by route: staff vs student accounts (no in-screen toggle).
  final AccountView initialView;

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  // Match web defaults: staff work status "Đang làm việc", student "Đang học".
  String _workStatusFilter = TeacherWorkStatusOptions.working;
  String _studentStatusFilter = StudentStatusOptions.studying;
  _AccountStatusFilter _accountStatusFilter = _AccountStatusFilter.all;
  final _searchController = TextEditingController();
  String _search = '';

  AccountView get _view => widget.initialView;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadAccountManagement();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, provider, _) {
        final items = _filteredItems(provider);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _view == AccountView.staff
                  ? 'Tài khoản cán bộ'
                  : 'Tài khoản học sinh',
            ),
            actions: [
              IconButton(
                tooltip: 'Làm mới',
                onPressed: provider.isAccountsLoading
                    ? null
                    : provider.loadAccountManagement,
                icon: const Icon(LucideIcons.refreshCcw, size: 20),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: provider.loadAccountManagement,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              children: [
                AppSearchBar(
                  controller: _searchController,
                  hintText: _view == AccountView.staff
                      ? 'Tìm tên / email'
                      : 'Tìm tên / mã thẻ',
                  onChanged: (value) => setState(() => _search = value),
                  onClear: () {
                    _searchController.clear();
                    setState(() => _search = '');
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                if (_view == AccountView.staff)
                  _FilterDropdown(
                    key: const ValueKey('staff_work_status_filter'),
                    label: 'Trạng thái cán bộ',
                    value: _workStatusFilter,
                    options: const [
                      AppOption(value: '', label: 'Tất cả trạng thái'),
                      ...TeacherWorkStatusOptions.all,
                    ],
                    onChanged: (value) {
                      setState(() => _workStatusFilter = value ?? '');
                    },
                  )
                else
                  _FilterDropdown(
                    key: const ValueKey('student_status_filter'),
                    label: 'Trạng thái học sinh',
                    value: _studentStatusFilter,
                    options: const [
                      AppOption(value: '', label: 'Tất cả trạng thái'),
                      ...StudentStatusOptions.all,
                    ],
                    onChanged: (value) {
                      setState(() => _studentStatusFilter = value ?? '');
                    },
                  ),
                const SizedBox(height: AppSpacing.sm),
                _FilterDropdown(
                  key: const ValueKey('account_status_filter'),
                  label: 'Trạng thái tài khoản',
                  value: _accountStatusFilter.name,
                  options: const [
                    AppOption(value: 'all', label: 'Tất cả tài khoản'),
                    AppOption(value: 'active', label: 'Đang mở'),
                    AppOption(value: 'inactive', label: 'Đã khóa'),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _accountStatusFilter = switch (value) {
                        'active' => _AccountStatusFilter.active,
                        'inactive' => _AccountStatusFilter.inactive,
                        _ => _AccountStatusFilter.all,
                      };
                    });
                  },
                ),
                if (provider.accountsErrorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  ErrorView(
                    message: provider.accountsErrorMessage!,
                    onRetry: provider.loadAccountManagement,
                  ),
                ] else if (provider.isAccountsLoading) ...[
                  const SizedBox(height: AppSpacing.lg),
                  const LoadingView(),
                ] else if (items.isEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  EmptyView(
                    title: _view == AccountView.staff
                        ? 'Chưa có tài khoản cán bộ phù hợp'
                        : 'Chưa có tài khoản học sinh phù hợp',
                    message: _view == AccountView.staff
                        ? 'Giáo viên mới tạo sẽ xuất hiện tại đây để cấp tài khoản.'
                        : 'Tài khoản học sinh dùng cho phụ huynh đăng nhập bằng mã trẻ.',
                  ),
                ] else ...[
                  const SizedBox(height: AppSpacing.sm),
                  for (final item in items) ...[
                    _AccountCard(
                      account: item,
                      view: _view,
                      onAssignRole: () => _openRoleDialog(context, item),
                      onResetPassword: item.hasAccount
                          ? () => _openPasswordDialog(context, item)
                          : null,
                      onToggleActive: item.hasAccount
                          ? () => _toggleActive(context, item)
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  List<Account> _filteredItems(AccountProvider provider) {
    final source = _view == AccountView.staff
        ? provider.staffAccounts
        : provider.parentAccounts;
    final keyword = _search.trim().toLowerCase();

    return source.where((item) {
      final matchesSearch =
          keyword.isEmpty ||
          item.fullName.toLowerCase().contains(keyword) ||
          item.email.toLowerCase().contains(keyword) ||
          item.cardNumber.toLowerCase().contains(keyword);

      if (!matchesSearch) {
        return false;
      }

      if (_view == AccountView.staff) {
        if (_workStatusFilter.isNotEmpty &&
            item.workStatus != _workStatusFilter) {
          return false;
        }
      } else if (_studentStatusFilter.isNotEmpty &&
          item.studentStatus != _studentStatusFilter) {
        return false;
      }

      return switch (_accountStatusFilter) {
        _AccountStatusFilter.active => item.hasAccount && item.isActive,
        _AccountStatusFilter.inactive => item.hasAccount && !item.isActive,
        _AccountStatusFilter.all => true,
      };
    }).toList();
  }

  Future<void> _openRoleDialog(BuildContext context, Account account) async {
    var selectedRole = account.hasAccount && account.role != 'none'
        ? account.role
        : RoleOptions.teacher;
    final passwordController = TextEditingController(
      text: account.hasAccount ? '' : _defaultStaffPassword(account.fullName),
    );
    var passwordVisible = false;

    final success = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final viewInsets = MediaQuery.viewInsetsOf(dialogContext);
            return AlertDialog(
              scrollable: true,
              insetPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: viewInsets.bottom > 0 ? AppSpacing.sm : AppSpacing.lg,
              ),
              title: Text(account.hasAccount ? 'Đổi vai trò' : 'Cấp tài khoản'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        account.fullName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Vai trò'),
                      items: const [
                        DropdownMenuItem(
                          value: RoleOptions.principal,
                          child: Text(
                            'BGH - Ban Giám hiệu',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: RoleOptions.teacher,
                          child: Text(
                            'GV - Giáo viên',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedRole = value);
                        }
                      },
                    ),
                    if (!account.hasAccount) ...[
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu khởi tạo',
                          helperText: 'Tối thiểu 6 ký tự',
                          suffixIcon: IconButton(
                            tooltip: passwordVisible
                                ? 'Ẩn mật khẩu'
                                : 'Hiện mật khẩu',
                            onPressed: () {
                              setDialogState(
                                () => passwordVisible = !passwordVisible,
                              );
                            },
                            icon: Icon(
                              passwordVisible
                                  ? LucideIcons.eyeOff
                                  : LucideIcons.eye,
                              size: 20,
                            ),
                          ),
                        ),
                        obscureText: !passwordVisible,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (!account.hasAccount &&
                        passwordController.text.trim().length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mật khẩu tối thiểu 6 ký tự'),
                        ),
                      );
                      return;
                    }

                    final provider = context.read<AccountProvider>();
                    final teacherId = account.teacherId == 0
                        ? account.id
                        : account.teacherId;
                    final ok = account.hasAccount
                        ? await provider.changeStaffRole(
                            teacherId: teacherId,
                            role: selectedRole,
                          )
                        : await provider.assignStaffAccount(
                            teacherId: teacherId,
                            role: selectedRole,
                            password: passwordController.text.trim(),
                          );
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext, ok);
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );

    // showDialog completes when pop starts, while the closing animation still
    // renders the text field. Dispose after that Material transition finishes.
    Future<void>.delayed(kThemeAnimationDuration, () {
      passwordController.dispose();
    });
    _showActionResult(success);
  }

  Future<void> _openPasswordDialog(
    BuildContext context,
    Account account,
  ) async {
    final passwordController = TextEditingController(
      text: _view == AccountView.student ? account.cardNumber : '',
    );
    var passwordVisible = false;

    final success = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: Text(
              _view == AccountView.student
                  ? 'Đổi mật khẩu PH'
                  : 'Đặt lại mật khẩu',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(account.fullName),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới',
                    helperText: 'Tối thiểu 6 ký tự',
                    suffixIcon: IconButton(
                      tooltip: passwordVisible
                          ? 'Ẩn mật khẩu'
                          : 'Hiện mật khẩu',
                      onPressed: () {
                        setDialogState(
                          () => passwordVisible = !passwordVisible,
                        );
                      },
                      icon: Icon(
                        passwordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                        size: 20,
                      ),
                    ),
                  ),
                  obscureText: !passwordVisible,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () async {
                  if (passwordController.text.trim().length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mật khẩu tối thiểu 6 ký tự'),
                      ),
                    );
                    return;
                  }
                  final ok = await context
                      .read<AccountProvider>()
                      .changePassword(
                        accountId: account.accountId,
                        password: passwordController.text.trim(),
                      );
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext, ok);
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          ),
        );
      },
    );

    Future<void>.delayed(kThemeAnimationDuration, () {
      passwordController.dispose();
    });
    _showActionResult(success);
  }

  Future<void> _toggleActive(BuildContext context, Account account) async {
    final provider = context.read<AccountProvider>();
    final success = _view == AccountView.staff
        ? await provider.setStaffActive(
            accountId: account.accountId,
            isActive: !account.isActive,
          )
        : await provider.setParentActive(
            studentId: account.studentId,
            isActive: !account.isActive,
          );
    _showActionResult(success);
  }

  void _showActionResult(bool? success) {
    if (!mounted || success == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Đã cập nhật tài khoản' : 'Chưa thể cập nhật'),
      ),
    );
  }

  String _defaultStaffPassword(String fullName) {
    final ascii = fullName
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('đ', 'd');
    return '$ascii@123';
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<AppOption<String>> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final values = options.map((option) => option.value).toSet();
    final effectiveValue = values.contains(value) ? value : '';

    return DropdownButtonFormField<String>(
      key: ValueKey('$label-$effectiveValue'),
      initialValue: effectiveValue,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, isDense: true),
      selectedItemBuilder: (context) {
        return [
          for (final option in options)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ];
      },
      items: [
        for (final option in options)
          DropdownMenuItem<String>(
            value: option.value,
            child: Text(option.label),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.view,
    required this.onAssignRole,
    required this.onResetPassword,
    required this.onToggleActive,
  });

  final Account account;
  final AccountView view;
  final VoidCallback onAssignRole;
  final VoidCallback? onResetPassword;
  final VoidCallback? onToggleActive;

  @override
  Widget build(BuildContext context) {
    if (view == AccountView.student) {
      return _StudentAccountCard(
        account: account,
        onResetPassword: onResetPassword,
        onToggleActive: onToggleActive,
      );
    }

    final accountStatus = !account.hasAccount
        ? (label: 'Chưa cấp', tone: SorakStatusTone.pending)
        : account.isActive
        ? (label: 'Đang mở', tone: SorakStatusTone.success)
        : (label: 'Đã khóa', tone: SorakStatusTone.error);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SorakAvatar(
                  seed: account.accountId == 0 ? account.id : account.accountId,
                  fallbackLabel: account.fullName,
                  size: 44,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.fullName,
                        softWrap: true,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs / 2),
                      Text(
                        account.email.isEmpty ? '-' : account.email,
                        softWrap: true,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _CompactStatusBadge(
                        label: accountStatus.label,
                        tone: accountStatus.tone,
                      ),
                    ],
                  ),
                ),
                _AccountActionMenu(
                  view: view,
                  account: account,
                  onAssignRole: onAssignRole,
                  onResetPassword: onResetPassword,
                  onToggleActive: onToggleActive,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _InfoLine(
              label: 'Vai trò',
              value: account.hasAccount
                  ? UiLabels.role(account.role)
                  : 'Chưa cấp tài khoản',
            ),
            _InfoLine(
              label: 'Chức vụ',
              value: account.position.isEmpty ? '-' : account.position,
            ),
            _InfoLine(
              label: 'Trạng thái công tác',
              value: account.workStatus.isEmpty
                  ? '-'
                  : UiLabels.workStatus(account.workStatus),
            ),
          ],
        ),
      ),
    );
  }
}

/// Student card: same layout as staff (avatar + body), only web fields.
/// Mã thẻ, họ tên, trạng thái HS, trạng thái TK.
class _StudentAccountCard extends StatelessWidget {
  const _StudentAccountCard({
    required this.account,
    required this.onResetPassword,
    required this.onToggleActive,
  });

  final Account account;
  final VoidCallback? onResetPassword;
  final VoidCallback? onToggleActive;

  @override
  Widget build(BuildContext context) {
    final cardNumber = account.cardNumber.isEmpty ? '-' : account.cardNumber;
    final studentStatus = account.studentStatus.isEmpty
        ? 'Đang học'
        : UiLabels.status(account.studentStatus);
    final accountStatus = !account.hasAccount
        ? (label: 'Chưa cấp', tone: SorakStatusTone.pending)
        : account.isActive
        ? (label: 'Đang mở', tone: SorakStatusTone.success)
        : (label: 'Đã khóa', tone: SorakStatusTone.error);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SorakAvatar(
                  seed: account.accountId == 0 ? account.id : account.accountId,
                  fallbackLabel: account.fullName,
                  size: 44,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.fullName,
                        softWrap: true,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs / 2),
                      Text(
                        'Mã thẻ: $cardNumber',
                        softWrap: true,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _CompactStatusBadge(
                        label: accountStatus.label,
                        tone: accountStatus.tone,
                      ),
                    ],
                  ),
                ),
                _AccountActionMenu(
                  view: AccountView.student,
                  account: account,
                  onAssignRole: () {},
                  onResetPassword: onResetPassword,
                  onToggleActive: onToggleActive,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _InfoLine(label: 'Trạng thái HS', value: studentStatus),
          ],
        ),
      ),
    );
  }
}

/// Compact text badge using Claude semantic success/warning/error tokens.
class _CompactStatusBadge extends StatelessWidget {
  const _CompactStatusBadge({required this.label, required this.tone});

  final String label;
  final SorakStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = switch (tone) {
      SorakStatusTone.success => (
        text: AppColors.statusSuccessText,
        background: AppColors.statusSuccessBackground,
        border: AppColors.statusSuccessBorder,
      ),
      SorakStatusTone.pending => (
        text: AppColors.statusWarningText,
        background: AppColors.statusWarningBackground,
        border: AppColors.statusWarningBorder,
      ),
      SorakStatusTone.error => (
        text: AppColors.statusErrorText,
        background: AppColors.statusErrorBackground,
        border: AppColors.statusErrorBorder,
      ),
      SorakStatusTone.neutral => (
        text: AppColors.statusNeutralText,
        background: AppColors.statusNeutralBackground,
        border: AppColors.statusNeutralBorder,
      ),
    };

    return Semantics(
      label: 'Trạng thái tài khoản: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: scheme.background,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: scheme.border),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: scheme.text,
            fontWeight: FontWeight.w700,
            fontSize: 11,
            height: 1.15,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _AccountActionMenu extends StatelessWidget {
  const _AccountActionMenu({
    required this.view,
    required this.account,
    required this.onAssignRole,
    required this.onResetPassword,
    required this.onToggleActive,
  });

  final AccountView view;
  final Account account;
  final VoidCallback onAssignRole;
  final VoidCallback? onResetPassword;
  final VoidCallback? onToggleActive;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Thao tác',
      icon: const Icon(LucideIcons.ellipsisVertical, size: 20),
      onSelected: (value) {
        switch (value) {
          case 'role':
            onAssignRole();
          case 'password':
            onResetPassword?.call();
          case 'active':
            onToggleActive?.call();
        }
      },
      itemBuilder: (context) {
        return [
          if (view == AccountView.staff)
            PopupMenuItem(
              value: 'role',
              child: Text(account.hasAccount ? 'Đổi vai trò' : 'Cấp tài khoản'),
            ),
          if (account.hasAccount)
            PopupMenuItem(
              value: 'password',
              child: Text(
                view == AccountView.student
                    ? 'Đổi mật khẩu PH'
                    : 'Đặt lại mật khẩu',
              ),
            ),
          if (account.hasAccount)
            PopupMenuItem(
              value: 'active',
              child: Text(
                view == AccountView.student
                    ? (account.isActive
                          ? 'Khóa tài khoản PH'
                          : 'Mở khóa tài khoản PH')
                    : (account.isActive
                          ? 'Khóa tài khoản'
                          : 'Mở khóa tài khoản'),
              ),
            ),
        ];
      },
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs / 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              softWrap: true,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
