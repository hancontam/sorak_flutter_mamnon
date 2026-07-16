import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_spacing.dart';
import 'health_roster_dashboard.dart';

/// Màn nhập đánh giá sức khỏe theo lớp (roster).
class HealthScreen extends StatefulWidget {
  const HealthScreen({
    super.key,
    this.showAppBar = true,
  });

  /// Khi false chỉ render body (layout nhúng).
  final bool showAppBar;

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final GlobalKey<HealthRosterDashboardState> _dashboardKey =
      GlobalKey<HealthRosterDashboardState>();

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomPadding =
        AppSpacing.md +
        media.padding.bottom +
        kBottomNavigationBarHeight +
        AppSpacing.sm;

    final body = SafeArea(
      top: false,
      bottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          bottomPadding,
        ),
        children: [
          HealthRosterDashboard(key: _dashboardKey),
        ],
      ),
    );

    if (!widget.showAppBar) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sức khỏe'),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: () => _dashboardKey.currentState?.reload(),
            icon: const Icon(LucideIcons.refreshCcw, size: 20),
          ),
        ],
      ),
      body: body,
    );
  }
}
