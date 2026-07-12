import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../modules/academic_years/providers/active_academic_year_provider.dart';
import '../../modules/academic_years/screens/academic_year_list_screen.dart';
import '../../modules/auth/providers/auth_provider.dart';
import '../../modules/class_transfers/providers/class_transfer_provider.dart';
import '../../modules/classes/providers/class_provider.dart';
import '../../modules/classes/screens/class_list_screen.dart';
import '../../modules/form_options/providers/form_options_provider.dart';
import '../../modules/health/providers/growth_who_provider.dart';
import '../../modules/health/providers/health_assessment_provider.dart';
import '../../modules/health/providers/nutrition_assessment_provider.dart';
import '../../modules/incoming_transfers/providers/incoming_transfer_provider.dart';
import '../../modules/outgoing_transfers/providers/outgoing_transfer_provider.dart';
import '../../modules/parent/screens/parent_portal_screen.dart';
import '../../modules/students/providers/student_provider.dart';
import '../../modules/students/screens/student_list_screen.dart';
import '../../modules/teachers/providers/teacher_provider.dart';
import '../../modules/teachers/screens/teacher_list_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/ui_labels.dart';
import 'academic_year_accordion.dart';
import 'sorak_avatar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  int _yearRevision = 0;
  int? _lastAcademicYearId;
  ActiveAcademicYearProvider? _academicYearProvider;
  bool _didRefreshRoleScopedOptions = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ActiveAcademicYearProvider>();
    if (!identical(provider, _academicYearProvider)) {
      _academicYearProvider?.removeListener(_onAcademicYearChanged);
      _academicYearProvider = provider..addListener(_onAcademicYearChanged);
      _lastAcademicYearId = provider.selectedYearId;
    }

    if (!_didRefreshRoleScopedOptions) {
      _didRefreshRoleScopedOptions = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_refreshOptionsForCurrentStaff());
      });
    }
  }

  @override
  void dispose() {
    _academicYearProvider?.removeListener(_onAcademicYearChanged);
    super.dispose();
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();

    if (!mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  Future<void> _refreshOptionsForCurrentStaff() async {
    if (!mounted || _currentRole() == 'PARENT') {
      return;
    }

    final selectedYearId = context
        .read<ActiveAcademicYearProvider>()
        .selectedYearId;
    final formOptions = context.read<FormOptionsProvider>();
    await formOptions.refreshOptions();
    if (!mounted || selectedYearId == null) {
      return;
    }
    await formOptions.applyGlobalAcademicYear(selectedYearId);
  }

  void _openDrawerRoute(String routeName) {
    Navigator.pop(context);
    Navigator.pushNamed(context, routeName);
  }

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  void _onAcademicYearChanged() {
    final academicYearId = _academicYearProvider?.selectedYearId;
    if (academicYearId == null || academicYearId == _lastAcademicYearId) {
      return;
    }
    _lastAcademicYearId = academicYearId;
    unawaited(_reloadSelectedDestination(academicYearId));
  }

  Future<void> _reloadSelectedDestination(int academicYearId) async {
    await context.read<FormOptionsProvider>().applyGlobalAcademicYear(
      academicYearId,
    );
    if (!mounted) {
      return;
    }

    final role = _currentRole();
    if (role == 'PARENT') {
      return;
    }

    await Future.wait([
      context.read<StudentProvider>().loadForAcademicYear(academicYearId),
      context.read<ClassProvider>().loadForAcademicYear(academicYearId),
      if (role == 'PRINCIPAL')
        context.read<TeacherProvider>().loadForAcademicYear(academicYearId),
      context.read<ClassTransferProvider>().loadForAcademicYear(academicYearId),
      context.read<OutgoingTransferProvider>().loadForAcademicYear(
        academicYearId,
      ),
      context.read<IncomingTransferProvider>().loadForAcademicYear(
        academicYearId,
      ),
      context.read<HealthAssessmentProvider>().loadForAcademicYear(
        academicYearId,
      ),
      context.read<NutritionAssessmentProvider>().loadForAcademicYear(
        academicYearId,
      ),
      context.read<GrowthWhoProvider>().load(
        role: role,
        academicYearId: academicYearId,
      ),
    ]);

    if (mounted) {
      setState(() => _yearRevision++);
    }
  }

  List<_ShellDestination> _destinationsForRole(String role) {
    if (role == 'TEACHER') {
      return const [
        _ShellDestination(
          key: 'students',
          label: 'Học sinh',
          icon: LucideIcons.users,
          screen: StudentListScreen(showAppBar: false),
        ),
        _ShellDestination(
          key: 'classes',
          label: 'Lớp học',
          icon: LucideIcons.school,
          screen: ClassListScreen(showAppBar: false),
        ),
      ];
    }

    if (role == 'PARENT') {
      return const [];
    }

    return const [
      _ShellDestination(
        key: 'academic_years',
        label: 'Năm học',
        icon: LucideIcons.calendarDays,
        screen: AcademicYearListScreen(showAppBar: false),
      ),
      _ShellDestination(
        key: 'students',
        label: 'Học sinh',
        icon: LucideIcons.users,
        screen: StudentListScreen(showAppBar: false),
      ),
      _ShellDestination(
        key: 'teachers',
        label: 'Cán bộ',
        icon: LucideIcons.badgeCheck,
        screen: TeacherListScreen(showAppBar: false),
      ),
      _ShellDestination(
        key: 'classes',
        label: 'Lớp học',
        icon: LucideIcons.school,
        screen: ClassListScreen(showAppBar: false),
      ),
    ];
  }

  String _normalizedRole(BuildContext context) {
    // Select role only — avoid full shell rebuild when profile reloads.
    return context.select<AuthProvider, String>(
      (provider) => provider.currentUser?.role.toUpperCase() ?? 'TEACHER',
    );
  }

  String _currentRole() {
    return context.read<AuthProvider>().currentUser?.role.toUpperCase() ??
        'TEACHER';
  }

  @override
  Widget build(BuildContext context) {
    final role = _normalizedRole(context);
    final destinations = _destinationsForRole(role);
    final hasBottomNav = destinations.isNotEmpty;
    final selectedIndex = hasBottomNav
        ? _selectedIndex.clamp(0, destinations.length - 1)
        : 0;
    final title = hasBottomNav
        ? destinations[selectedIndex].label
        : 'Báo cáo của trẻ';
    final body = hasBottomNav
        ? destinations[selectedIndex].screen
        : const ParentPortalScreen();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: Builder(
          builder: (context) {
            return IconButton(
              key: const ValueKey('open_drawer_button'),
              tooltip: 'Mở menu',
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(LucideIcons.menu, size: 22),
            );
          },
        ),
      ),
      drawer: _AppDrawer(
        role: role,
        onOpenStudentAccounts: () => _openDrawerRoute('/student-accounts'),
        onOpenStaffAccounts: () => _openDrawerRoute('/staff-accounts'),
        onOpenClassTransfers: () => _openDrawerRoute('/class-transfers'),
        onOpenIncomingTransfers: () => _openDrawerRoute('/incoming-transfers'),
        onOpenOutgoingTransfers: () => _openDrawerRoute('/outgoing-transfers'),
        onOpenHealth: () => _openDrawerRoute('/health'),
        onOpenHealthAssessments: () => _openDrawerRoute('/health-assessments'),
        onOpenProfile: () => _openDrawerRoute('/profile'),
        onOpenSettings: () => _openDrawerRoute('/settings'),
        onLogout: _logout,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (role != 'PARENT') const AcademicYearAccordion(),
            Expanded(
              child: KeyedSubtree(
                key: ValueKey(
                  '${hasBottomNav ? destinations[selectedIndex].key : 'parent'}_$_yearRevision',
                ),
                child: body,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: hasBottomNav
          ? DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: _selectTab,
                destinations: [
                  for (final destination in destinations)
                    NavigationDestination(
                      key: ValueKey('nav_${destination.key}'),
                      icon: _NavIcon(icon: destination.icon),
                      selectedIcon: _NavIcon(
                        icon: destination.icon,
                        selected: true,
                      ),
                      label: destination.label,
                    ),
                ],
              ),
            )
          : null,
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, this.selected = false});

  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: selected ? 1.08 : 1,
      child: Icon(icon, size: selected ? 24 : 22),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.role,
    required this.onOpenStudentAccounts,
    required this.onOpenStaffAccounts,
    required this.onOpenClassTransfers,
    required this.onOpenIncomingTransfers,
    required this.onOpenOutgoingTransfers,
    required this.onOpenHealth,
    required this.onOpenHealthAssessments,
    required this.onOpenProfile,
    required this.onOpenSettings,
    required this.onLogout,
  });

  final String role;
  final VoidCallback onOpenStudentAccounts;
  final VoidCallback onOpenStaffAccounts;
  final VoidCallback onOpenClassTransfers;
  final VoidCallback onOpenIncomingTransfers;
  final VoidCallback onOpenOutgoingTransfers;
  final VoidCallback onOpenHealth;
  final VoidCallback onOpenHealthAssessments;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenSettings;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final fullName = user?.fullName ?? 'Người dùng Sorak';
    final email = user?.email ?? '';
    final items = _drawerGroups();

    return Drawer(
      backgroundColor: AppColors.drawer,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  SorakAvatar(
                    seed: user?.id ?? role,
                    fallbackLabel: fullName,
                    size: 52,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          UiLabels.role(role),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        if (email.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.mutedForeground,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                children: [
                  for (final group in items) ...[
                    if (group.label != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.sm,
                          AppSpacing.md,
                          AppSpacing.xs,
                        ),
                        child: Text(
                          group.label!,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.mutedForeground,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    for (final item in group.items)
                      _DrawerTile(
                        key: ValueKey('drawer_${item.key}'),
                        item: item,
                      ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: Divider(),
                    ),
                  ],
                ],
              ),
            ),
            _DrawerTile(
              key: const ValueKey('drawer_logout'),
              item: _DrawerItem(
                key: 'logout',
                label: 'Đăng xuất',
                icon: LucideIcons.logOut,
                onTap: onLogout,
                destructive: true,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  List<_DrawerGroup> _drawerGroups() {
    final personal = _DrawerGroup(
      label: 'Cá nhân',
      items: [
        _DrawerItem(
          key: 'profile',
          label: 'Hồ sơ',
          icon: LucideIcons.user,
          onTap: onOpenProfile,
        ),
        _DrawerItem(
          key: 'settings',
          label: 'Cài đặt',
          icon: LucideIcons.settings,
          onTap: onOpenSettings,
        ),
      ],
    );

    if (role == 'PARENT') {
      return [personal];
    }

    final transfers = _DrawerGroup(
      label: 'Luân chuyển',
      items: [
        _DrawerItem(
          key: 'class_transfers',
          label: 'Chuyển lớp',
          icon: LucideIcons.arrowRightLeft,
          onTap: onOpenClassTransfers,
        ),
        _DrawerItem(
          key: 'incoming_transfers',
          label: 'Chuyển trường đến',
          icon: LucideIcons.logIn,
          onTap: onOpenIncomingTransfers,
        ),
        _DrawerItem(
          key: 'outgoing_transfers',
          label: 'Chuyển trường đi',
          icon: LucideIcons.logOut,
          onTap: onOpenOutgoingTransfers,
        ),
      ],
    );

    final health = _DrawerGroup(
      label: 'Sức khỏe',
      items: [
        _DrawerItem(
          key: 'health',
          label: 'Đánh giá sức khỏe',
          icon: LucideIcons.heartPulse,
          onTap: onOpenHealth,
        ),
        _DrawerItem(
          key: 'health_assessments',
          label: 'Xem đánh giá sức khỏe',
          icon: LucideIcons.clipboardList,
          onTap: onOpenHealthAssessments,
        ),
      ],
    );

    if (role == 'TEACHER') {
      return [transfers, health, personal];
    }

    final accounts = _DrawerGroup(
      label: 'Tài khoản',
      items: [
        _DrawerItem(
          key: 'student_accounts',
          label: 'Tài khoản học sinh',
          icon: LucideIcons.users,
          onTap: onOpenStudentAccounts,
        ),
        _DrawerItem(
          key: 'staff_accounts',
          label: 'Tài khoản cán bộ',
          icon: LucideIcons.badgeCheck,
          onTap: onOpenStaffAccounts,
        ),
      ],
    );

    return [accounts, transfers, health, personal];
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({super.key, required this.item});

  final _DrawerItem item;

  @override
  Widget build(BuildContext context) {
    final color = item.destructive
        ? AppColors.destructive
        : AppColors.secondaryForeground;

    final tile = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: ListTile(
        minTileHeight: 48,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
        leading: Icon(item.icon, size: 21, color: color),
        title: Text(
          item.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        onTap: item.onTap,
      ),
    );

    if (item.key == 'staff_accounts') {
      return KeyedSubtree(key: const ValueKey('drawer_accounts'), child: tile);
    }

    return tile;
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.key,
    required this.label,
    required this.icon,
    required this.screen,
  });

  final String key;
  final String label;
  final IconData icon;
  final Widget screen;
}

class _DrawerGroup {
  const _DrawerGroup({required this.items, this.label});

  final String? label;
  final List<_DrawerItem> items;
}

class _DrawerItem {
  const _DrawerItem({
    required this.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.destructive = false,
  });

  final String key;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool destructive;
}
