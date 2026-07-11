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
import '../../../core/widgets/sorak_toggle_group.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';

enum AccountView { student, staff }

enum _AccountFilter { all, unassigned, assigned, active, inactive }

class AccountListScreen extends StatefulWidget {
  const AccountListScreen({super.key, this.initialView = AccountView.staff});

  final AccountView initialView;

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  late AccountView _view = widget.initialView;
  _AccountFilter _filter = _AccountFilter.all;
  final _searchController = TextEditingController();
  String _search = '';

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
                SorakToggleGroup<AccountView>(
                  options: const [
                    SorakToggleOption(
                      value: AccountView.staff,
                      label: 'Cán bộ',
                      icon: LucideIcons.badgeCheck,
                    ),
                    SorakToggleOption(
                      value: AccountView.student,
                      label: 'Học sinh',
                      icon: LucideIcons.users,
                    ),
                  ],
                  selected: _view,
                  onChanged: (value) {
                    setState(() {
                      _view = value;
                      _filter = _AccountFilter.all;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppSearchBar(
                  controller: _searchController,
                  hintText: 'Tìm theo họ tên, email, mã thẻ',
                  onChanged: (value) => setState(() => _search = value),
                  onClear: () {
                    _searchController.clear();
                    setState(() => _search = '');
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                _AccountFilterToggle(
                  selected: _filter,
                  showAssignedFilters: _view == AccountView.staff,
                  onSelected: (value) => setState(() => _filter = value),
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

      return switch (_filter) {
        _AccountFilter.unassigned => !item.hasAccount,
        _AccountFilter.assigned => item.hasAccount,
        _AccountFilter.active => item.hasAccount && item.isActive,
        _AccountFilter.inactive => item.hasAccount && !item.isActive,
        _AccountFilter.all => true,
      };
    }).toList();
  }

  Future<void> _openRoleDialog(BuildContext context, Account account) async {
    final roleController = ValueNotifier<String>(
      account.hasAccount && account.role != 'none'
          ? account.role
          : RoleOptions.teacher,
    );
    final passwordController = TextEditingController(
      text: account.hasAccount ? '' : _defaultStaffPassword(account.fullName),
    );

    final success = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(account.hasAccount ? 'Đổi vai trò' : 'Cấp tài khoản'),
          content: ValueListenableBuilder<String>(
            valueListenable: roleController,
            builder: (context, role, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      account.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: 'Vai trò'),
                    items: const [
                      DropdownMenuItem(
                        value: RoleOptions.principal,
                        child: Text('BGH - Ban Giám hiệu'),
                      ),
                      DropdownMenuItem(
                        value: RoleOptions.teacher,
                        child: Text('GV - Giáo viên'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        roleController.value = value;
                      }
                    },
                  ),
                  if (!account.hasAccount) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Mật khẩu khởi tạo',
                        helperText: 'Tối thiểu 6 ký tự',
                      ),
                      obscureText: true,
                    ),
                  ],
                ],
              );
            },
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
                    const SnackBar(content: Text('Mật khẩu tối thiểu 6 ký tự')),
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
                        role: roleController.value,
                      )
                    : await provider.assignStaffAccount(
                        teacherId: teacherId,
                        role: roleController.value,
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

    roleController.dispose();
    passwordController.dispose();
    _showActionResult(success);
  }

  Future<void> _openPasswordDialog(
    BuildContext context,
    Account account,
  ) async {
    final passwordController = TextEditingController(
      text: _view == AccountView.student ? account.cardNumber : '',
    );

    final success = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            _view == AccountView.student
                ? 'Đổi mật khẩu phụ huynh'
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
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu mới',
                  helperText: 'Tối thiểu 6 ký tự',
                ),
                obscureText: true,
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
                    const SnackBar(content: Text('Mật khẩu tối thiểu 6 ký tự')),
                  );
                  return;
                }
                final ok = await context.read<AccountProvider>().changePassword(
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
        );
      },
    );

    passwordController.dispose();
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

class _AccountFilterToggle extends StatelessWidget {
  const _AccountFilterToggle({
    required this.selected,
    required this.showAssignedFilters,
    required this.onSelected,
  });

  final _AccountFilter selected;
  final bool showAssignedFilters;
  final ValueChanged<_AccountFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final filters = [
      const SorakToggleOption(value: _AccountFilter.all, label: 'Tất cả'),
      if (showAssignedFilters) ...[
        const SorakToggleOption(
          value: _AccountFilter.unassigned,
          label: 'Chưa cấp',
        ),
        const SorakToggleOption(
          value: _AccountFilter.assigned,
          label: 'Đã cấp',
        ),
      ],
      const SorakToggleOption(value: _AccountFilter.active, label: 'Đang mở'),
      const SorakToggleOption(value: _AccountFilter.inactive, label: 'Đã khóa'),
    ];

    return SorakToggleGroup<_AccountFilter>(
      options: filters,
      selected: selected,
      onChanged: onSelected,
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
    final statusLabel = account.hasAccount
        ? (account.isActive ? 'Active' : 'Inactive')
        : 'Chưa cấp tài khoản';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        view == AccountView.staff
                            ? (account.email.isEmpty ? '-' : account.email)
                            : 'Mã trẻ: ${account.cardNumber.isEmpty ? '-' : account.cardNumber}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(child: SorakStatusBadge(label: statusLabel)),
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
            if (view == AccountView.staff) ...[
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
            ] else ...[
              _InfoLine(
                label: 'Lớp',
                value: account.className.isEmpty ? '-' : account.className,
              ),
              _InfoLine(
                label: 'Trạng thái học sinh',
                value: account.studentStatus.isEmpty
                    ? '-'
                    : UiLabels.status(account.studentStatus),
              ),
              _InfoLine(
                label: 'Số điện thoại phụ huynh',
                value: account.phone.isEmpty ? '-' : account.phone,
              ),
            ],
          ],
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
                    ? 'Đổi mật khẩu phụ huynh'
                    : 'Đặt lại mật khẩu',
              ),
            ),
          if (account.hasAccount)
            PopupMenuItem(
              value: 'active',
              child: Text(
                account.isActive ? 'Khóa tài khoản' : 'Mở khóa tài khoản',
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
