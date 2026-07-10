import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_options.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/account.dart';
import '../providers/account_provider.dart';

enum _AccountsTab { staff, parent }

enum _AccountFilter { all, unassigned, assigned, active, inactive }

class AccountListScreen extends StatefulWidget {
  const AccountListScreen({super.key});

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  _AccountsTab _tab = _AccountsTab.staff;
  _AccountFilter _filter = _AccountFilter.all;
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadAccountManagement();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, provider, _) {
        final items = _filteredItems(provider);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Quản lý tài khoản'),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: provider.isAccountsLoading
                    ? null
                    : provider.loadAccountManagement,
                icon: const Icon(Icons.refresh_outlined),
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
                SegmentedButton<_AccountsTab>(
                  segments: const [
                    ButtonSegment(
                      value: _AccountsTab.staff,
                      label: Text('Tài khoản cán bộ'),
                      icon: Icon(Icons.badge_outlined),
                    ),
                    ButtonSegment(
                      value: _AccountsTab.parent,
                      label: Text('Tài khoản phụ huynh'),
                      icon: Icon(Icons.family_restroom_outlined),
                    ),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (value) {
                    setState(() {
                      _tab = value.first;
                      _filter = _AccountFilter.all;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_outlined),
                    hintText: 'Tìm theo họ tên, email, mã thẻ',
                  ),
                  onChanged: (value) => setState(() => _search = value),
                ),
                const SizedBox(height: AppSpacing.sm),
                _FilterChips(
                  selected: _filter,
                  showAssignedFilters: _tab == _AccountsTab.staff,
                  onSelected: (value) => setState(() => _filter = value),
                ),
                if (provider.accountsErrorMessage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    provider.accountsErrorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ],
                if (provider.isAccountsLoading) ...[
                  const SizedBox(height: AppSpacing.lg),
                  const Center(child: CircularProgressIndicator()),
                ] else if (items.isEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: Text(
                      _tab == _AccountsTab.staff
                          ? 'Chưa có cán bộ phù hợp'
                          : 'Chưa có phụ huynh phù hợp',
                      style: const TextStyle(color: AppColors.textGray),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: AppSpacing.sm),
                  for (final item in items) ...[
                    _AccountCard(
                      account: item,
                      tab: _tab,
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
    final source = _tab == _AccountsTab.staff
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
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: 'Vai trò'),
                    items: RoleOptions.staff
                        .map(
                          (option) => DropdownMenuItem(
                            value: option.value,
                            child: Text(option.label),
                          ),
                        )
                        .toList(),
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
                final ok = account.hasAccount
                    ? await provider.changeStaffRole(
                        teacherId: account.teacherId == 0
                            ? account.id
                            : account.teacherId,
                        role: roleController.value,
                      )
                    : await provider.assignStaffAccount(
                        teacherId: account.teacherId == 0
                            ? account.id
                            : account.teacherId,
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
      text: _tab == _AccountsTab.parent ? account.cardNumber : '',
    );

    final success = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            _tab == _AccountsTab.parent
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
    final success = _tab == _AccountsTab.staff
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

class _FilterChips extends StatelessWidget {
  const _FilterChips({
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
      const _FilterItem(_AccountFilter.all, 'Tất cả'),
      if (showAssignedFilters) ...[
        const _FilterItem(_AccountFilter.unassigned, 'Chưa cấp'),
        const _FilterItem(_AccountFilter.assigned, 'Đã cấp'),
      ],
      const _FilterItem(_AccountFilter.active, 'Active'),
      const _FilterItem(_AccountFilter.inactive, 'Inactive'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in filters) ...[
            FilterChip(
              label: Text(filter.label),
              selected: selected == filter.value,
              onSelected: (_) => onSelected(filter.value),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _FilterItem {
  const _FilterItem(this.value, this.label);

  final _AccountFilter value;
  final String label;
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.tab,
    required this.onAssignRole,
    required this.onResetPassword,
    required this.onToggleActive,
  });

  final Account account;
  final _AccountsTab tab;
  final VoidCallback onAssignRole;
  final VoidCallback? onResetPassword;
  final VoidCallback? onToggleActive;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    account.fullName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _StatusPill(
                  label: account.hasAccount
                      ? (account.isActive ? 'Active' : 'Inactive')
                      : 'Chưa cấp',
                  color: account.hasAccount && account.isActive
                      ? AppColors.success
                      : AppColors.textGray,
                ),
                PopupMenuButton<String>(
                  tooltip: 'Thao tác',
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
                      if (tab == _AccountsTab.staff)
                        PopupMenuItem(
                          value: 'role',
                          child: Text(
                            account.hasAccount
                                ? 'Đổi vai trò'
                                : 'Cấp tài khoản',
                          ),
                        ),
                      if (account.hasAccount)
                        PopupMenuItem(
                          value: 'password',
                          child: Text(
                            tab == _AccountsTab.parent
                                ? 'Đổi mật khẩu PH'
                                : 'Đặt lại mật khẩu',
                          ),
                        ),
                      if (account.hasAccount)
                        PopupMenuItem(
                          value: 'active',
                          child: Text(
                            account.isActive
                                ? (tab == _AccountsTab.parent
                                      ? 'Khóa tài khoản PH'
                                      : 'Khóa tài khoản')
                                : (tab == _AccountsTab.parent
                                      ? 'Mở khóa tài khoản PH'
                                      : 'Mở khóa tài khoản'),
                          ),
                        ),
                    ];
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            if (tab == _AccountsTab.staff) ...[
              Text(
                'Vai trò: ${account.hasAccount ? RoleOptions.labelOf(account.role) : 'Chưa cấp'}',
              ),
              Text(
                'Chức vụ: ${account.position.isEmpty ? '-' : account.position}',
              ),
              Text(
                'Trạng thái CB: ${account.workStatus.isEmpty ? '-' : account.workStatus}',
              ),
              Text('Email: ${account.email.isEmpty ? '-' : account.email}'),
            ] else ...[
              Text(
                'Mã thẻ: ${account.cardNumber.isEmpty ? '-' : account.cardNumber}',
              ),
              Text(
                'Lớp: ${account.className.isEmpty ? '-' : account.className}',
              ),
              Text(
                'Trạng thái HS: ${account.studentStatus.isEmpty ? '-' : account.studentStatus}',
              ),
              Text('SĐT PH: ${account.phone.isEmpty ? '-' : account.phone}'),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color == AppColors.success ? Colors.green.shade800 : color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
