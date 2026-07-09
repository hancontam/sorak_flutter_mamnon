import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../modules/auth/providers/auth_provider.dart';
import '../../modules/classes/screens/class_list_screen.dart';
import '../../modules/health/screens/growth_who_screen.dart';
import '../../modules/health/screens/health_screen.dart';
import '../../modules/home/screens/home_screen.dart';
import '../../modules/parent/screens/parent_portal_screen.dart';
import '../../modules/students/screens/student_list_screen.dart';
import '../../modules/transfers/screens/transfers_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

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

  void _selectDestinationByLabel(
    List<_ShellDestination> destinations,
    String label,
  ) {
    final index = destinations.indexWhere(
      (destination) => destination.label == label,
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
          label: 'Child',
          icon: Icons.child_care_outlined,
          selectedIcon: Icons.child_care,
          screen: ParentPortalScreen(),
        ),
        _ShellDestination(
          label: 'Growth',
          icon: Icons.trending_up_outlined,
          selectedIcon: Icons.trending_up,
          screen: GrowthWhoScreen(),
        ),
        _ShellDestination(
          label: 'Health',
          icon: Icons.favorite_outline,
          selectedIcon: Icons.favorite,
          screen: ParentPortalScreen(),
        ),
      ];
    }

    if (role == 'TEACHER') {
      return [
        _homeDestination(),
        const _ShellDestination(
          label: 'Classes',
          icon: Icons.class_outlined,
          selectedIcon: Icons.class_,
          screen: ClassListScreen(),
        ),
        const _ShellDestination(
          label: 'Students',
          icon: Icons.child_care_outlined,
          selectedIcon: Icons.child_care,
          screen: StudentListScreen(),
        ),
        const _ShellDestination(
          label: 'Transfers',
          icon: Icons.swap_horiz_outlined,
          selectedIcon: Icons.swap_horiz,
          screen: TransfersScreen(),
        ),
        const _ShellDestination(
          label: 'Health',
          icon: Icons.favorite_outline,
          selectedIcon: Icons.favorite,
          screen: HealthScreen(),
        ),
      ];
    }

    return [
      _homeDestination(),
      const _ShellDestination(
        label: 'Students',
        icon: Icons.child_care_outlined,
        selectedIcon: Icons.child_care,
        screen: StudentListScreen(),
      ),
      const _ShellDestination(
        label: 'Classes',
        icon: Icons.class_outlined,
        selectedIcon: Icons.class_,
        screen: ClassListScreen(),
      ),
      const _ShellDestination(
        label: 'Transfers',
        icon: Icons.swap_horiz_outlined,
        selectedIcon: Icons.swap_horiz,
        screen: TransfersScreen(),
      ),
      const _ShellDestination(
        label: 'Health',
        icon: Icons.favorite_outline,
        selectedIcon: Icons.favorite,
        screen: HealthScreen(),
      ),
    ];
  }

  _ShellDestination _homeDestination() {
    return _ShellDestination(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      screen: Builder(
        builder: (context) {
          final role = _normalizedRole(context);
          final destinations = _destinationsForRole(role);

          return HomeScreen(
            showAppBar: false,
            onOpenStudents: () =>
                _selectDestinationByLabel(destinations, 'Students'),
            onOpenClasses: () =>
                _selectDestinationByLabel(destinations, 'Classes'),
            onOpenTransfers: () =>
                _selectDestinationByLabel(destinations, 'Transfers'),
            onOpenHealth: () =>
                _selectDestinationByLabel(destinations, 'Health'),
          );
        },
      ),
    );
  }

  String _normalizedRole(BuildContext context) {
    return context.watch<AuthProvider>().currentUser?.role.toUpperCase() ??
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
          selectedDestination.label == 'Home'
              ? 'Sorak Mam Non'
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
          IconButton(
            key: const ValueKey('app_logout_button'),
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.power_settings_new),
          ),
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
      body: selectedDestination.screen,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: _selectTab,
        destinations: [
          for (final destination in destinations)
            NavigationDestination(
              key: ValueKey('nav_${destination.label.toLowerCase()}'),
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
            ),
        ],
      ),
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
          title: const Text('Logout'),
          onTap: onLogout,
        ),
      ],
    );
  }

  List<_DrawerItem> _drawerItems() {
    if (role == 'PRINCIPAL') {
      return [
        _DrawerItem(
          label: 'Academic Years',
          icon: Icons.calendar_month_outlined,
          selectedIcon: Icons.calendar_month,
          onTap: onOpenAcademicYears,
        ),
        _DrawerItem(
          label: 'Accounts',
          icon: Icons.manage_accounts_outlined,
          selectedIcon: Icons.manage_accounts,
          onTap: onOpenAccounts,
        ),
        _DrawerItem(
          label: 'Teachers',
          icon: Icons.badge_outlined,
          selectedIcon: Icons.badge,
          onTap: onOpenTeachers,
        ),
        _DrawerItem(
          label: 'Growth',
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
          label: 'Growth',
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
      label: 'Profile',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      onTap: onOpenProfile,
    );
  }

  _DrawerItem _commonSettingsItem() {
    return _DrawerItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      onTap: onOpenSettings,
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'PRINCIPAL':
        return 'Principal';
      case 'TEACHER':
        return 'Teacher';
      case 'PARENT':
        return 'Parent';
      default:
        return role;
    }
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.screen,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget screen;
}

class _DrawerItem {
  const _DrawerItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.onTap,
  });

  final String label;
  String get key => label.toLowerCase().replaceAll(' ', '_');
  final IconData icon;
  final IconData selectedIcon;
  final VoidCallback onTap;
}
