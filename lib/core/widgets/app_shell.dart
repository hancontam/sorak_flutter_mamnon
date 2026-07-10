import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../modules/academic_years/providers/active_academic_year_provider.dart';
import '../../modules/auth/providers/auth_provider.dart';
import '../../modules/class_transfers/providers/class_transfer_provider.dart';
import '../../modules/classes/screens/class_list_screen.dart';
import '../../modules/classes/providers/class_provider.dart';
import '../../modules/health/screens/growth_who_screen.dart';
import '../../modules/health/screens/health_screen.dart';
import '../../modules/health/providers/growth_who_provider.dart';
import '../../modules/health/providers/health_assessment_provider.dart';
import '../../modules/health/providers/nutrition_assessment_provider.dart';
import '../../modules/home/screens/home_screen.dart';
import '../../modules/incoming_transfers/providers/incoming_transfer_provider.dart';
import '../../modules/outgoing_transfers/providers/outgoing_transfer_provider.dart';
import '../../modules/parent/screens/parent_portal_screen.dart';
import '../../modules/students/providers/student_provider.dart';
import '../../modules/students/screens/student_list_screen.dart';
import '../../modules/teachers/providers/teacher_provider.dart';
import '../../modules/transfers/screens/transfers_screen.dart';
import '../../modules/form_options/providers/form_options_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ActiveAcademicYearProvider>();
    if (identical(provider, _academicYearProvider)) {
      return;
    }

    _academicYearProvider?.removeListener(_onAcademicYearChanged);
    _academicYearProvider = provider..addListener(_onAcademicYearChanged);
    _lastAcademicYearId = provider.selectedYearId;
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

  void _openDrawerRoute(String routeName) {
    Navigator.pop(context);
    Navigator.pushNamed(context, routeName);
  }

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
    final destination = _destinationsForRole(
      role,
    )[_selectedIndex.clamp(0, _destinationsForRole(role).length - 1)];

    switch (destination.key) {
      case 'home':
        await Future.wait([
          context.read<StudentProvider>().loadForAcademicYear(academicYearId),
          context.read<ClassProvider>().loadForAcademicYear(academicYearId),
          context.read<TeacherProvider>().loadForAcademicYear(academicYearId),
          context.read<ClassTransferProvider>().loadForAcademicYear(
            academicYearId,
          ),
        ]);
        break;
      case 'students':
        await context.read<StudentProvider>().loadForAcademicYear(
          academicYearId,
        );
        break;
      case 'classes':
        await context.read<ClassProvider>().loadForAcademicYear(academicYearId);
        break;
      case 'transfers':
        await Future.wait([
          context.read<ClassTransferProvider>().loadForAcademicYear(
            academicYearId,
          ),
          context.read<OutgoingTransferProvider>().loadForAcademicYear(
            academicYearId,
          ),
          context.read<IncomingTransferProvider>().loadForAcademicYear(
            academicYearId,
          ),
        ]);
        break;
      case 'health':
        await Future.wait([
          context.read<HealthAssessmentProvider>().loadForAcademicYear(
            academicYearId,
          ),
          context.read<NutritionAssessmentProvider>().loadForAcademicYear(
            academicYearId,
          ),
        ]);
        break;
      case 'growth':
        await context.read<GrowthWhoProvider>().load(
          role: role,
          academicYearId: academicYearId,
        );
        break;
      case 'child':
        await Future.wait([
          context.read<HealthAssessmentProvider>().loadForAcademicYear(
            academicYearId,
          ),
          context.read<NutritionAssessmentProvider>().loadForAcademicYear(
            academicYearId,
          ),
        ]);
        break;
    }

    if (mounted) {
      setState(() => _yearRevision++);
    }
  }

  void _selectDestinationByKey(
    List<_ShellDestination> destinations,
    String key,
  ) {
    final index = destinations.indexWhere(
      (destination) => destination.key == key,
    );
    if (index == -1) {
      return;
    }
    _selectTab(index);
  }

  List<_ShellDestination> _destinationsForRole(String role) {
    if (role == 'PARENT') {
      return const [
        _ShellDestination(
          key: 'child',
          label: 'Trẻ',
          icon: Icons.child_care_outlined,
          selectedIcon: Icons.child_care,
          screen: ParentPortalScreen(section: ParentPortalSection.child),
        ),
        _ShellDestination(
          key: 'growth',
          label: 'Tăng trưởng',
          icon: Icons.trending_up_outlined,
          selectedIcon: Icons.trending_up,
          screen: GrowthWhoScreen(),
        ),
        _ShellDestination(
          key: 'health',
          label: 'Sức khỏe',
          icon: Icons.favorite_outline,
          selectedIcon: Icons.favorite,
          screen: ParentPortalScreen(section: ParentPortalSection.health),
        ),
      ];
    }

    if (role == 'TEACHER') {
      return [
        _homeDestination(),
        const _ShellDestination(
          key: 'classes',
          label: 'Lớp học',
          icon: Icons.class_outlined,
          selectedIcon: Icons.class_,
          screen: ClassListScreen(),
        ),
        const _ShellDestination(
          key: 'students',
          label: 'Học sinh',
          icon: Icons.child_care_outlined,
          selectedIcon: Icons.child_care,
          screen: StudentListScreen(),
        ),
        const _ShellDestination(
          key: 'transfers',
          label: 'Chuyển lớp',
          icon: Icons.swap_horiz_outlined,
          selectedIcon: Icons.swap_horiz,
          screen: TransfersScreen(),
        ),
        const _ShellDestination(
          key: 'health',
          label: 'Sức khỏe',
          icon: Icons.favorite_outline,
          selectedIcon: Icons.favorite,
          screen: HealthScreen(),
        ),
      ];
    }

    return [
      _homeDestination(),
      const _ShellDestination(
        key: 'students',
        label: 'Học sinh',
        icon: Icons.child_care_outlined,
        selectedIcon: Icons.child_care,
        screen: StudentListScreen(),
      ),
      const _ShellDestination(
        key: 'classes',
        label: 'Lớp học',
        icon: Icons.class_outlined,
        selectedIcon: Icons.class_,
        screen: ClassListScreen(),
      ),
      const _ShellDestination(
        key: 'transfers',
        label: 'Chuyển lớp',
        icon: Icons.swap_horiz_outlined,
        selectedIcon: Icons.swap_horiz,
        screen: TransfersScreen(),
      ),
      const _ShellDestination(
        key: 'health',
        label: 'Sức khỏe',
        icon: Icons.favorite_outline,
        selectedIcon: Icons.favorite,
        screen: HealthScreen(),
      ),
    ];
  }

  _ShellDestination _homeDestination() {
    return _ShellDestination(
      key: 'home',
      label: 'Trang chủ',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      screen: Builder(
        builder: (context) {
          final role = _normalizedRole(context);
          final destinations = _destinationsForRole(role);

          return HomeScreen(
            showAppBar: false,
            onOpenStudents: () =>
                _selectDestinationByKey(destinations, 'students'),
            onOpenClasses: () =>
                _selectDestinationByKey(destinations, 'classes'),
            onOpenTransfers: () =>
                _selectDestinationByKey(destinations, 'transfers'),
            onOpenHealth: () => _selectDestinationByKey(destinations, 'health'),
          );
        },
      ),
    );
  }

  String _normalizedRole(BuildContext context) {
    return context.watch<AuthProvider>().currentUser?.role.toUpperCase() ??
        'TEACHER';
  }

  String _currentRole() {
    return context.read<AuthProvider>().currentUser?.role.toUpperCase() ??
        'TEACHER';
  }

  @override
  Widget build(BuildContext context) {
    final role = _normalizedRole(context);
    final destinations = _destinationsForRole(role);
    final selectedIndex = _selectedIndex.clamp(0, destinations.length - 1);
    final selectedDestination = destinations[selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedDestination.key == 'home'
              ? 'Sorak Mầm non'
              : selectedDestination.label,
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              key: const ValueKey('open_drawer_button'),
              tooltip: 'Menu',
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu),
            );
          },
        ),
        actions: [
          const _ActiveYearDropdown(),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      drawer: _AppDrawer(
        role: role,
        onOpenAcademicYears: () => _openDrawerRoute('/academic-years'),
        onOpenAccounts: () => _openDrawerRoute('/accounts'),
        onOpenTeachers: () => _openDrawerRoute('/teachers'),
        onOpenGrowth: () => _openDrawerRoute('/growth'),
        onOpenProfile: () => _openDrawerRoute('/profile'),
        onOpenSettings: () => _openDrawerRoute('/settings'),
        onLogout: _logout,
      ),
      body: KeyedSubtree(
        key: ValueKey('${selectedDestination.key}_$_yearRevision'),
        child: selectedDestination.screen,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: _selectTab,
        destinations: [
          for (final destination in destinations)
            NavigationDestination(
              key: ValueKey('nav_${destination.key}'),
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}

class _ActiveYearDropdown extends StatefulWidget {
  const _ActiveYearDropdown();

  @override
  State<_ActiveYearDropdown> createState() => _ActiveYearDropdownState();
}

class _ActiveYearDropdownState extends State<_ActiveYearDropdown> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<ActiveAcademicYearProvider>().loadYears();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveAcademicYearProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.years.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(right: AppSpacing.xs),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (provider.years.isEmpty) {
          return const SizedBox.shrink();
        }

        final values = provider.years.map((year) => year.id).toSet();
        final selectedValue = values.contains(provider.selectedYearId)
            ? provider.selectedYearId
            : null;

        return Container(
          constraints: const BoxConstraints(maxWidth: 148),
          margin: const EdgeInsets.only(right: AppSpacing.xs),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(999),
            color: AppColors.surface,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              key: const ValueKey('active_year_dropdown'),
              value: selectedValue,
              isDense: true,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 18),
              hint: const Text('Năm học'),
              onChanged: (value) async {
                if (value == null) {
                  return;
                }
                await provider.selectYear(value);
              },
              items: [
                for (final year in provider.years)
                  DropdownMenuItem<int>(
                    value: year.id,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (year.status.toLowerCase() == 'active') ...[
                          const Icon(
                            Icons.check_circle,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            year.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.role,
    required this.onOpenAcademicYears,
    required this.onOpenAccounts,
    required this.onOpenTeachers,
    required this.onOpenGrowth,
    required this.onOpenProfile,
    required this.onOpenSettings,
    required this.onLogout,
  });

  final String role;
  final VoidCallback onOpenAcademicYears;
  final VoidCallback onOpenAccounts;
  final VoidCallback onOpenTeachers;
  final VoidCallback onOpenGrowth;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenSettings;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final fullName = user?.fullName ?? 'Guest';
    final initial = fullName.isEmpty ? 'S' : fullName.characters.first;
    final items = _drawerItems();

    return NavigationDrawer(
      selectedIndex: null,
      onDestinationSelected: (index) => items[index].onTap(),
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                child: Text(initial.toUpperCase()),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _roleLabel(role),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        for (final item in items)
          NavigationDrawerDestination(
            key: ValueKey('drawer_${item.key}'),
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: Text(item.label),
            enabled: true,
          ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.power_settings_new),
          title: const Text('Đăng xuất'),
          onTap: onLogout,
        ),
      ],
    );
  }

  List<_DrawerItem> _drawerItems() {
    if (role == 'PRINCIPAL') {
      return [
        _DrawerItem(
          key: 'academic_years',
          label: 'Năm học',
          icon: Icons.calendar_month_outlined,
          selectedIcon: Icons.calendar_month,
          onTap: onOpenAcademicYears,
        ),
        _DrawerItem(
          key: 'accounts',
          label: 'Tài khoản',
          icon: Icons.manage_accounts_outlined,
          selectedIcon: Icons.manage_accounts,
          onTap: onOpenAccounts,
        ),
        _DrawerItem(
          key: 'teachers',
          label: 'Cán bộ',
          icon: Icons.badge_outlined,
          selectedIcon: Icons.badge,
          onTap: onOpenTeachers,
        ),
        _DrawerItem(
          key: 'growth',
          label: 'Tăng trưởng WHO',
          icon: Icons.trending_up_outlined,
          selectedIcon: Icons.trending_up,
          onTap: onOpenGrowth,
        ),
        _commonProfileItem(),
        _commonSettingsItem(),
      ];
    }

    if (role == 'TEACHER') {
      return [
        _DrawerItem(
          key: 'growth',
          label: 'Tăng trưởng WHO',
          icon: Icons.trending_up_outlined,
          selectedIcon: Icons.trending_up,
          onTap: onOpenGrowth,
        ),
        _commonProfileItem(),
        _commonSettingsItem(),
      ];
    }

    return [_commonProfileItem(), _commonSettingsItem()];
  }

  _DrawerItem _commonProfileItem() {
    return _DrawerItem(
      key: 'profile',
      label: 'Hồ sơ',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      onTap: onOpenProfile,
    );
  }

  _DrawerItem _commonSettingsItem() {
    return _DrawerItem(
      key: 'settings',
      label: 'Cài đặt',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      onTap: onOpenSettings,
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'PRINCIPAL':
        return 'Ban Giám Hiệu';
      case 'TEACHER':
        return 'Giáo viên';
      case 'PARENT':
        return 'Phụ huynh';
      default:
        return role;
    }
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.key,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.screen,
  });

  final String key;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget screen;
}

class _DrawerItem {
  const _DrawerItem({
    required this.key,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.onTap,
  });

  final String key;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final VoidCallback onTap;
}
