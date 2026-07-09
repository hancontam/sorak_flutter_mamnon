import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();

    if (!context.mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final menus = [
      _HomeMenu('Academic Years', '/academic-years', Icons.calendar_month),
      _HomeMenu('Classes', '/classes', Icons.class_),
      _HomeMenu('Teachers', '/teachers', Icons.badge),
      _HomeMenu('Students', '/students', Icons.child_care),
      _HomeMenu('Accounts', '/accounts', Icons.manage_accounts),
      _HomeMenu('Class Transfer', '/class-transfers', Icons.swap_horiz),
      _HomeMenu('Outgoing Transfer', '/outgoing-transfers', Icons.logout),
      _HomeMenu('Incoming Transfer', '/incoming-transfers', Icons.login),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sorak Mam Non'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.power_settings_new),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Welcome, ${user?.fullName ?? 'Guest'}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text('Role: ${user?.role ?? '-'}'),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: menus.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (context, index) {
              final menu = menus[index];
              return Card(
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, menu.route),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(menu.icon, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          menu.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HomeMenu {
  const _HomeMenu(this.title, this.route, this.icon);

  final String title;
  final String route;
  final IconData icon;
}
