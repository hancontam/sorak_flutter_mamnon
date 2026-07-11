import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/text_normalizer.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/filter_chip_row.dart';
import '../../../core/widgets/loading_view.dart';
import '../../academic_years/providers/active_academic_year_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/health_assessment.dart';
import '../models/who_curve_point.dart';
import '../providers/growth_who_provider.dart';

class GrowthWhoScreen extends StatefulWidget {
  const GrowthWhoScreen({super.key, this.embedded = false});

  /// When true, content is a shrink-wrapped column for nesting inside Health tab ListView.
  final bool embedded;

  @override
  State<GrowthWhoScreen> createState() => _GrowthWhoScreenState();
}

class _GrowthWhoScreenState extends State<GrowthWhoScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _selectedClass;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final role = _role(context);
      if (role == 'PARENT') return;
      context.read<GrowthWhoProvider>().load(
        role: role,
        academicYearId: context
            .read<ActiveAcademicYearProvider>()
            .selectedYearId,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _role(BuildContext context) {
    return context.read<AuthProvider>().currentUser?.role.toUpperCase() ??
        'TEACHER';
  }

  @override
  Widget build(BuildContext context) {
    final role =
        context.watch<AuthProvider>().currentUser?.role.toUpperCase() ??
        'TEACHER';
    final isParent = role == 'PARENT';
    final academicYearId = context
        .watch<ActiveAcademicYearProvider>()
        .selectedYearId;
    final media = MediaQuery.of(context);
    final bottomPadding = widget.embedded
        ? 0.0
        : AppSpacing.md + media.padding.bottom + kBottomNavigationBarHeight;

    if (isParent) {
      return const Center(
        key: ValueKey('parent_growth_api_unavailable'),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: EmptyView(
            title: 'Chưa có dữ liệu tăng trưởng',
            message:
                'Nhà trường chưa cung cấp API tăng trưởng dành cho phụ huynh. Ứng dụng không hiển thị dữ liệu mẫu khi đang kết nối hệ thống thật.',
            icon: Icons.cloud_off_outlined,
            type: EmptyViewType.unsupported,
          ),
        ),
      );
    }

    return Consumer<GrowthWhoProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.students.isEmpty) {
          return const LoadingView();
        }
        if (provider.errorMessage != null && provider.students.isEmpty) {
          return ErrorView(
            message: provider.errorMessage!,
            onRetry: () =>
                provider.load(role: role, academicYearId: academicYearId),
          );
        }
        if (provider.students.isEmpty) {
          return const EmptyView(
            title: 'Chưa có dữ liệu tăng trưởng',
            message: 'Các lần đo sức khỏe sẽ hiển thị tại đây sau khi nhập.',
            icon: Icons.trending_up,
          );
        }

        final filteredStudents = _filteredStudents(provider.students, isParent);
        final selected = provider.selectedStudent ?? filteredStudents.first;

        final body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _GrowthHeader(isParent: isParent),
            if (!isParent) ...[
              const SizedBox(height: AppSpacing.sm),
              AppSearchBar(
                controller: _searchController,
                hintText: 'Tìm trẻ, lớp hoặc mã trẻ',
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
                onClear: () {
                  _searchController.clear();
                  setState(() {
                    _query = '';
                  });
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              FilterChipRow(
                options: _classOptions(provider.students),
                selectedOption: _selectedClass,
                onSelected: (value) {
                  setState(() {
                    _selectedClass = value;
                  });
                },
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            _SummaryGrid(
              selected: selected,
              historyCount: provider.history.length,
            ),
            const SizedBox(height: AppSpacing.md),
            _WhoCurvesSummary(
              curves: provider.whoCurves,
              isLoading: provider.isLoadingCurves,
            ),
            const SizedBox(height: AppSpacing.md),
            _GrowthChartCard(history: provider.history),
            const SizedBox(height: AppSpacing.md),
            if (!isParent)
              _StudentPicker(
                students: filteredStudents,
                selectedStudentId: selected.studentId,
                onSelected: (student) {
                  provider.selectStudent(
                    student.studentId,
                    role: role,
                    academicYearId: academicYearId,
                  );
                },
              ),
            const SizedBox(height: AppSpacing.md),
            _HistoryList(history: provider.history),
          ],
        );

        if (widget.embedded) {
          return Material(color: AppColors.background, child: body);
        }

        return Material(
          color: AppColors.background,
          child: RefreshIndicator(
            onRefresh: () =>
                provider.load(role: role, academicYearId: academicYearId),
            child: ListView(
              padding: EdgeInsets.fromLTRB(0, 0, 0, bottomPadding),
              children: [body],
            ),
          ),
        );
      },
    );
  }

  List<HealthAssessment> _filteredStudents(
    List<HealthAssessment> students,
    bool isParent,
  ) {
    if (isParent) {
      return students;
    }

    final query = normalizeVietnamese(_query);
    return students.where((student) {
      if (_selectedClass != null && student.className != _selectedClass) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return normalizeVietnamese(
        [student.studentName, student.studentCode, student.className].join(' '),
      ).contains(query);
    }).toList();
  }

  List<String> _classOptions(List<HealthAssessment> students) {
    final values = students
        .map((item) => item.className)
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList();
    values.sort();
    return values;
  }
}

class _GrowthHeader extends StatelessWidget {
  const _GrowthHeader({required this.isParent});

  final bool isParent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              foregroundColor: AppColors.primary,
              child: const Icon(Icons.trending_up),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tăng trưởng WHO',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    isParent
                        ? 'Phụ huynh chỉ xem biểu đồ tăng trưởng của trẻ.'
                        : 'Lọc theo lớp hoặc trẻ để xem xu hướng tăng trưởng.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textGray),
                  ),
                ],
              ),
            ),
            if (isParent)
              const Chip(
                label: Text('Chỉ xem'),
                avatar: Icon(Icons.visibility_outlined, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

class _WhoCurvesSummary extends StatelessWidget {
  const _WhoCurvesSummary({required this.curves, required this.isLoading});

  final List<WhoCurvePoint> curves;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đường cong WHO (tham chiếu)',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            if (isLoading)
              const LinearProgressIndicator()
            else if (curves.isEmpty)
              Text(
                'Chưa tải được đường cong WHO.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textGray),
              )
            else
              Text(
                '${curves.length} mốc tuổi · median tháng ${curves.first.month}: '
                '${curves.first.median.toStringAsFixed(1)} → '
                'tháng ${curves.last.month}: ${curves.last.median.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.selected, required this.historyCount});

  final HealthAssessment selected;
  final int historyCount;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.55,
      children: [
        _MetricCard(
          label: selected.studentName,
          value: selected.className,
          icon: Icons.child_care_outlined,
        ),
        _MetricCard(
          label: 'BMI',
          value: selected.bmi == 0 ? '-' : selected.bmi.toStringAsFixed(2),
          helper: selected.bmiStatus,
          icon: Icons.favorite_outline,
        ),
        _MetricCard(
          label: 'Chiều cao',
          value: '${selected.heightCm} cm',
          helper: selected.heightStatus,
          icon: Icons.height,
        ),
        _MetricCard(
          label: 'Số lần đo',
          value: '$historyCount',
          helper: 'Lịch sử WHO',
          icon: Icons.timeline_outlined,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.helper = '',
  });

  final String label;
  final String value;
  final IconData icon;
  final String helper;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const Spacer(),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textGray),
            ),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (helper.isNotEmpty)
              Text(
                helper,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textGray),
              ),
          ],
        ),
      ),
    );
  }
}

class _GrowthChartCard extends StatelessWidget {
  const _GrowthChartCard({required this.history});

  final List<HealthAssessment> history;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Biểu đồ BMI',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'Tóm tắt WHO',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textGray),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 220,
              width: double.infinity,
              child: CustomPaint(
                painter: _GrowthChartPainter(history),
                child: history.isEmpty
                    ? Center(
                        child: Text(
                          'Chưa có dữ liệu biểu đồ',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textGray),
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrowthChartPainter extends CustomPainter {
  const _GrowthChartPainter(this.history);

  final List<HealthAssessment> history;

  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    final paintLine = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final paintPoint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    const left = 28.0;
    const top = 12.0;
    const bottom = 28.0;
    const right = 12.0;
    final chart = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );

    for (var i = 0; i <= 4; i++) {
      final y = chart.top + chart.height * i / 4;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), paintGrid);
    }

    if (history.isEmpty) {
      return;
    }

    final values = history.map((item) => item.bmi).where((value) => value > 0);
    final minValue = values.isEmpty ? 0.0 : values.reduce(math.min) - 1;
    final maxValue = values.isEmpty ? 1.0 : values.reduce(math.max) + 1;
    final range = (maxValue - minValue).abs() < 0.1 ? 1.0 : maxValue - minValue;

    final path = Path();
    for (var i = 0; i < history.length; i++) {
      final item = history[i];
      final x =
          chart.left +
          (history.length == 1
              ? chart.width / 2
              : chart.width * i / (history.length - 1));
      final y = chart.bottom - ((item.bmi - minValue) / range) * chart.height;
      final point = Offset(x, y);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawCircle(point, 5, paintPoint);
    }
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter oldDelegate) {
    return oldDelegate.history != history;
  }
}

class _StudentPicker extends StatelessWidget {
  const _StudentPicker({
    required this.students,
    required this.selectedStudentId,
    required this.onSelected,
  });

  final List<HealthAssessment> students;
  final int selectedStudentId;
  final ValueChanged<HealthAssessment> onSelected;

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return const EmptyView(
        title: 'Không có trẻ phù hợp',
        message: 'Thử từ khóa hoặc bộ lọc lớp khác.',
        icon: Icons.search_off,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh sách trẻ',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final student in students) ...[
          Card(
            child: ListTile(
              selected: student.studentId == selectedStudentId,
              leading: const Icon(Icons.child_care_outlined),
              title: Text(student.studentName),
              subtitle: Text('${student.className} | ${student.studentCode}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onSelected(student),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.history});

  final List<HealthAssessment> history;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lịch sử đánh giá',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final item in history.reversed) ...[
          Card(
            child: ListTile(
              leading: const Icon(Icons.event_note_outlined),
              title: Text(item.assessmentDate.substring(0, 10)),
              subtitle: Text(
                '${item.heightCm} cm | ${item.weightKg} kg | BMI ${item.bmi.toStringAsFixed(2)}',
              ),
              trailing: Text(
                item.bmiStatus,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}
