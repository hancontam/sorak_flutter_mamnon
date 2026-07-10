import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../../class_transfers/providers/class_transfer_provider.dart';
import '../../classes/providers/class_provider.dart';
import '../../students/providers/student_provider.dart';
import '../../teachers/providers/teacher_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.showAppBar = true,
    this.onOpenStudents,
    this.onOpenClasses,
    this.onOpenTeachers,
    this.onOpenTransfers,
    this.onOpenHealth,
  });

  final bool showAppBar;
  final VoidCallback? onOpenStudents;
  final VoidCallback? onOpenClasses;
  final VoidCallback? onOpenTeachers;
  final VoidCallback? onOpenTransfers;
  final VoidCallback? onOpenHealth;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<StudentProvider>().loadItems();
      context.read<ClassProvider>().loadItems();
      final role = context.read<AuthProvider>().currentUser?.role.toUpperCase();
      if (role == 'PRINCIPAL') {
        context.read<TeacherProvider>().loadItems();
      }
      context.read<ClassTransferProvider>().loadItems();
    });
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();

    if (!context.mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final body = _HomeBody(
      onOpenStudents: widget.onOpenStudents,
      onOpenClasses: widget.onOpenClasses,
      onOpenTeachers: widget.onOpenTeachers,
      onOpenTransfers: widget.onOpenTransfers,
      onOpenHealth: widget.onOpenHealth,
    );

    if (!widget.showAppBar) {
      return body;
    }

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
      body: body,
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    this.onOpenStudents,
    this.onOpenClasses,
    this.onOpenTeachers,
    this.onOpenTransfers,
    this.onOpenHealth,
  });

  final VoidCallback? onOpenStudents;
  final VoidCallback? onOpenClasses;
  final VoidCallback? onOpenTeachers;
  final VoidCallback? onOpenTransfers;
  final VoidCallback? onOpenHealth;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final studentsProvider = context.watch<StudentProvider>();
    final classesProvider = context.watch<ClassProvider>();
    final teachersProvider = context.watch<TeacherProvider>();
    final transfersProvider = context.watch<ClassTransferProvider>();
    final role = user?.role.toUpperCase() ?? '';
    final isPrincipal = role == 'PRINCIPAL';
    final isTeacher = role == 'TEACHER';
    final pendingTransfers = transfersProvider.items
        .where((item) => item.status.toLowerCase() == 'pending')
        .length;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(
          'Xin chào, ${user?.fullName ?? 'Khách'}',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Vai trò: ${user?.role ?? '-'}',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textGray),
        ),
        const SizedBox(height: AppSpacing.md),
        _RoleDashboardBanner(
          role: role,
          pendingTransfers: pendingTransfers,
          classCount: classesProvider.items.length,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Tổng quan hôm nay',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.45,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _SummaryCard(
              title: 'Trẻ',
              value: studentsProvider.items.length.toString(),
              icon: Icons.child_care,
              isLoading: studentsProvider.isLoading,
            ),
            _SummaryCard(
              title: 'Lớp học',
              value: classesProvider.items.length.toString(),
              icon: Icons.class_,
              isLoading: classesProvider.isLoading,
            ),
            if (isPrincipal)
              _SummaryCard(
                title: 'Giáo viên',
                value: teachersProvider.items.length.toString(),
                icon: Icons.badge,
                isLoading: teachersProvider.isLoading,
              )
            else
              _SummaryCard(
                title: 'Yêu cầu chuyển lớp',
                value: transfersProvider.items.length.toString(),
                icon: Icons.swap_horiz,
                isLoading: transfersProvider.isLoading,
              ),
            _SummaryCard(
              title: 'Chờ duyệt',
              value: pendingTransfers.toString(),
              icon: Icons.pending_actions,
              isLoading: transfersProvider.isLoading,
              accentColor: AppColors.accent,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (isPrincipal) ...[
          _PrincipalDashboardSection(
            pendingTransfers: pendingTransfers,
            onOpenAccounts: () => Navigator.pushNamed(context, '/accounts'),
            onOpenTeachers:
                onOpenTeachers ??
                () => Navigator.pushNamed(context, '/teachers'),
            onOpenTransfers:
                onOpenTransfers ??
                () => Navigator.pushNamed(context, '/transfers'),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (isTeacher) ...[
          _TeacherDashboardSection(
            classCount: classesProvider.items.length,
            studentCount: studentsProvider.items.length,
            onOpenClasses:
                onOpenClasses ?? () => Navigator.pushNamed(context, '/classes'),
            onOpenHealth:
                onOpenHealth ?? () => Navigator.pushNamed(context, '/health'),
            onOpenNutrition: () => Navigator.pushNamed(context, '/nutrition'),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Text(
          'Thao tác nhanh',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        _QuickActionCard(
          title: 'Trẻ',
          subtitle: 'Xem và cập nhật hồ sơ trẻ',
          icon: Icons.child_care_outlined,
          onTap:
              onOpenStudents ?? () => Navigator.pushNamed(context, '/students'),
        ),
        const SizedBox(height: AppSpacing.sm),
        _QuickActionCard(
          title: 'Lớp học',
          subtitle: 'Xem phòng học và giáo viên phụ trách',
          icon: Icons.class_outlined,
          onTap:
              onOpenClasses ?? () => Navigator.pushNamed(context, '/classes'),
        ),
        if (isPrincipal) ...[
          const SizedBox(height: AppSpacing.sm),
          _QuickActionCard(
            title: 'Giáo viên',
            subtitle: 'Mở chức năng quản lý giáo viên',
            icon: Icons.badge_outlined,
            onTap:
                onOpenTeachers ??
                () => Navigator.pushNamed(context, '/teachers'),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        _QuickActionCard(
          title: 'Chuyển lớp',
          subtitle: 'Xem yêu cầu chuyển lớp và chuyển trường',
          icon: Icons.swap_horiz,
          onTap:
              onOpenTransfers ??
              () => Navigator.pushNamed(context, '/transfers'),
        ),
      ],
    );
  }
}

class _RoleDashboardBanner extends StatelessWidget {
  const _RoleDashboardBanner({
    required this.role,
    required this.pendingTransfers,
    required this.classCount,
  });

  final String role;
  final int pendingTransfers;
  final int classCount;

  @override
  Widget build(BuildContext context) {
    final content = switch (role) {
      'PRINCIPAL' => (
        title: 'Tổng quan Ban Giám Hiệu',
        message:
            'Theo dõi toàn trường, yêu cầu chờ duyệt và các thao tác quản lý.',
        icon: Icons.admin_panel_settings_outlined,
      ),
      'TEACHER' => (
        title: 'Công việc giáo viên',
        message:
            'Lớp được phân công: $classCount. Có thể nhập nhanh sức khỏe và dinh dưỡng hằng ngày.',
        icon: Icons.school_outlined,
      ),
      _ => (
        title: 'Tổng quan',
        message: 'Theo dõi hoạt động hằng ngày và các việc quan trọng.',
        icon: Icons.dashboard_outlined,
      ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              foregroundColor: AppColors.primary,
              child: Icon(content.icon),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    content.message,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textGray),
                  ),
                ],
              ),
            ),
            if (role == 'PRINCIPAL')
              _MiniCounter(label: 'Chờ duyệt', value: '$pendingTransfers'),
          ],
        ),
      ),
    );
  }
}

class _PrincipalDashboardSection extends StatelessWidget {
  const _PrincipalDashboardSection({
    required this.pendingTransfers,
    required this.onOpenAccounts,
    required this.onOpenTeachers,
    required this.onOpenTransfers,
  });

  final int pendingTransfers;
  final VoidCallback onOpenAccounts;
  final VoidCallback onOpenTeachers;
  final VoidCallback onOpenTransfers;

  @override
  Widget build(BuildContext context) {
    return _DashboardSection(
      title: 'Thao tác Ban Giám Hiệu',
      children: [
        _QuickActionCard(
          title: 'Yêu cầu chuyển lớp chờ duyệt',
          subtitle: '$pendingTransfers yêu cầu đang chờ xử lý',
          icon: Icons.pending_actions_outlined,
          onTap: onOpenTransfers,
        ),
        const SizedBox(height: AppSpacing.sm),
        _QuickActionCard(
          title: 'Tài khoản',
          subtitle: 'Quản lý quyền truy cập của cán bộ và phụ huynh',
          icon: Icons.manage_accounts_outlined,
          onTap: onOpenAccounts,
        ),
        const SizedBox(height: AppSpacing.sm),
        _QuickActionCard(
          title: 'Giáo viên',
          subtitle: 'Mở chức năng quản lý giáo viên',
          icon: Icons.badge_outlined,
          onTap: onOpenTeachers,
        ),
      ],
    );
  }
}

class _TeacherDashboardSection extends StatelessWidget {
  const _TeacherDashboardSection({
    required this.classCount,
    required this.studentCount,
    required this.onOpenClasses,
    required this.onOpenHealth,
    required this.onOpenNutrition,
  });

  final int classCount;
  final int studentCount;
  final VoidCallback onOpenClasses;
  final VoidCallback onOpenHealth;
  final VoidCallback onOpenNutrition;

  @override
  Widget build(BuildContext context) {
    return _DashboardSection(
      title: 'Thao tác nhanh cho giáo viên',
      children: [
        Row(
          children: [
            Expanded(
              child: _MiniCounter(label: 'Lớp học', value: '$classCount'),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _MiniCounter(label: 'Trẻ', value: '$studentCount'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _QuickActionCard(
          title: 'Lớp được phân công',
          subtitle: 'Kiểm tra lớp trước khi nhập liệu hằng ngày',
          icon: Icons.class_outlined,
          onTap: onOpenClasses,
        ),
        const SizedBox(height: AppSpacing.sm),
        _QuickActionCard(
          title: 'Nhập nhanh sức khỏe',
          subtitle: 'Nhập chiều cao, cân nặng và ghi chú sức khỏe',
          icon: Icons.favorite_outline,
          onTap: onOpenHealth,
        ),
        const SizedBox(height: AppSpacing.sm),
        _QuickActionCard(
          title: 'Nhập nhanh dinh dưỡng',
          subtitle: 'Cập nhật tình trạng dinh dưỡng theo trẻ hoặc lớp',
          icon: Icons.restaurant_outlined,
          onTap: onOpenNutrition,
        ),
      ],
    );
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...children,
      ],
    );
  }
}

class _MiniCounter extends StatelessWidget {
  const _MiniCounter({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textGray),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.isLoading,
    this.accentColor = AppColors.primary,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool isLoading;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: accentColor),
            Text(
              isLoading ? '...' : value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
