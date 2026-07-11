import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_options.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/text_normalizer.dart';
import '../../../core/widgets/app_date_field.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/sorak_avatar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../classes/models/school_class.dart';
import '../../classes/providers/class_provider.dart';
import '../../form_options/providers/form_options_provider.dart';
import '../models/health_assessment.dart';
import '../providers/health_assessment_provider.dart';

/// History-style list (web "Lịch sử đánh giá"): filter class/date/search,
/// full metric cards. No detail navigation in this flow.
class HealthAssessmentListScreen extends StatefulWidget {
  const HealthAssessmentListScreen({super.key});

  @override
  State<HealthAssessmentListScreen> createState() =>
      _HealthAssessmentListScreenState();
}

class _HealthAssessmentListScreenState
    extends State<HealthAssessmentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String _search = '';
  String? _selectedClassId;

  @override
  void initState() {
    super.initState();
    _dateController.addListener(_onDateFilterChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FormOptionsProvider>().loadInitialOptions();
      context.read<HealthAssessmentProvider>().loadItems();
    });
  }

  @override
  void dispose() {
    _dateController.removeListener(_onDateFilterChanged);
    _searchController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _onDateFilterChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _reload() async {
    await context.read<FormOptionsProvider>().loadInitialOptions();
    if (!mounted) {
      return;
    }
    await context.read<HealthAssessmentProvider>().loadItems();
  }

  List<HealthAssessment> _filtered(
    List<HealthAssessment> source,
    Set<int>? allowedClassIds,
  ) {
    final query = normalizeVietnamese(_search);
    final classId = int.tryParse(_selectedClassId ?? '');
    final dateFilter = _dateController.text.trim();

    final items = source.where((item) {
      if (allowedClassIds != null && !allowedClassIds.contains(item.classId)) {
        return false;
      }
      if (classId != null && item.classId != classId) {
        return false;
      }
      if (dateFilter.isNotEmpty &&
          !item.assessmentDate.startsWith(dateFilter)) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final haystack = normalizeVietnamese(
        [
          item.studentName,
          item.studentCode,
          item.className,
          '${item.studentId}',
        ].join(' '),
      );
      return haystack.contains(query);
    }).toList();

    items.sort((a, b) {
      final byDate = b.assessmentDate.compareTo(a.assessmentDate);
      if (byDate != 0) {
        return byDate;
      }
      return normalizeVietnamese(
        a.studentName,
      ).compareTo(normalizeVietnamese(b.studentName));
    });
    return items;
  }

  List<AppOption<String>> _classOptions(List<SchoolClass> classes) {
    return [
      const AppOption(value: '', label: 'Tất cả lớp'),
      ...classes.map((schoolClass) {
        final room = schoolClass.room.isEmpty ? '' : ' - ${schoolClass.room}';
        return AppOption(
          value: '${schoolClass.id}',
          label: '${schoolClass.className}$room',
        );
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final optionsProvider = context.watch<FormOptionsProvider>();
    final healthProvider = context.watch<HealthAssessmentProvider>();
    final role = context.watch<AuthProvider>().currentUser?.role.toUpperCase();
    final isTeacher = role == 'TEACHER';
    final scopedClasses = isTeacher
        ? context.watch<ClassProvider>().items
        : optionsProvider.classes;
    final allowedClassIds = isTeacher
        ? scopedClasses.map((schoolClass) => schoolClass.id).toSet()
        : null;
    final items = _filtered(healthProvider.items, allowedClassIds);
    final isLoading = healthProvider.isLoading || optionsProvider.isLoading;
    final errorMessage = healthProvider.errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem đánh giá sức khỏe'),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: isLoading ? null : _reload,
            icon: const Icon(LucideIcons.refreshCcw, size: 20),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          children: [
            AppDropdownField<String>(
              key: ValueKey('health_history_class_${_selectedClassId ?? ''}'),
              label: 'Lớp',
              options: _classOptions(scopedClasses),
              value: _selectedClassId ?? '',
              hintText: 'Chọn lớp',
              enabled: !optionsProvider.isLoading && scopedClasses.isNotEmpty,
              onChanged: (value) {
                setState(() {
                  _selectedClassId = (value == null || value.isEmpty)
                      ? null
                      : value;
                });
              },
            ),
            if (scopedClasses.isEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              const _NoCompatibleClassNotice(),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppDateField(
                    controller: _dateController,
                    label: 'Ngày đánh giá',
                    firstDate: DateTime(2020),
                    lastDate: DateTime(DateTime.now().year + 1, 12, 31),
                  ),
                ),
                if (_dateController.text.trim().isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.xs),
                  IconButton(
                    tooltip: 'Xóa ngày',
                    onPressed: () {
                      _dateController.clear();
                      setState(() {});
                    },
                    icon: const Icon(LucideIcons.x, size: 20),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AppSearchBar(
              controller: _searchController,
              hintText: 'Lọc theo tên / mã...',
              onChanged: (value) => setState(() => _search = value),
              onClear: () {
                _searchController.clear();
                setState(() => _search = '');
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              items.isEmpty ? '0 đánh giá' : '${items.length} đánh giá',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (isLoading && healthProvider.items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: LoadingView(),
              )
            else if (errorMessage != null && healthProvider.items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: ErrorView(message: errorMessage, onRetry: _reload),
              )
            else if (items.isEmpty)
              EmptyView(
                title:
                    _search.trim().isNotEmpty ||
                        _selectedClassId != null ||
                        _dateController.text.trim().isNotEmpty
                    ? 'Không tìm thấy đánh giá'
                    : 'Chưa có đánh giá sức khỏe',
                message:
                    _search.trim().isNotEmpty ||
                        _selectedClassId != null ||
                        _dateController.text.trim().isNotEmpty
                    ? 'Thử đổi lớp, ngày hoặc từ khóa tìm kiếm.'
                    : 'Dữ liệu sẽ hiện khi có đánh giá trong năm học.',
                type:
                    _search.trim().isNotEmpty ||
                        _selectedClassId != null ||
                        _dateController.text.trim().isNotEmpty
                    ? EmptyViewType.search
                    : EmptyViewType.data,
              )
            else
              for (var index = 0; index < items.length; index++) ...[
                _HealthHistoryCard(index: index + 1, assessment: items[index]),
                const SizedBox(height: AppSpacing.sm),
              ],
          ],
        ),
      ),
    );
  }
}

class _NoCompatibleClassNotice extends StatelessWidget {
  const _NoCompatibleClassNotice();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Hiện tại không có lớp phù hợp.',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class _HealthHistoryCard extends StatelessWidget {
  const _HealthHistoryCard({required this.index, required this.assessment});

  final int index;
  final HealthAssessment assessment;

  @override
  Widget build(BuildContext context) {
    final dateText = _formatDateVi(assessment.assessmentDate);
    final heightText = _formatMeasure(assessment.heightCm);
    final weightText = _formatMeasure(assessment.weightKg);
    final bmiText = assessment.bmi <= 0
        ? '—'
        : assessment.bmiStatus.isEmpty
        ? assessment.bmi.toStringAsFixed(1)
        : '${assessment.bmi.toStringAsFixed(1)} · ${assessment.bmiStatus}';
    final heightAge = assessment.heightStatus.isEmpty
        ? '—'
        : assessment.heightStatus;
    final weightAge = assessment.weightStatus.isEmpty
        ? '—'
        : assessment.weightStatus;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: AppSpacing.xs),
                  child: Text(
                    '$index.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SorakAvatar(
                  seed: assessment.studentId,
                  fallbackLabel: assessment.studentName,
                  size: 44,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assessment.studentName.isEmpty
                            ? 'Học sinh'
                            : assessment.studentName,
                        softWrap: true,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                      ),
                      if (assessment.studentCode.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          assessment.studentCode,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.mutedForeground,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'monospace',
                              ),
                        ),
                      ],
                      if (assessment.className.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          assessment.className,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.secondaryForeground,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(AppSpacing.radius),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _InfoLine(label: 'Ngày', value: dateText),
                  _InfoLine(
                    label: 'Chiều cao',
                    value: heightText == '—' ? '—' : '$heightText cm',
                  ),
                  _InfoLine(
                    label: 'Cân nặng',
                    value: weightText == '—' ? '—' : '$weightText kg',
                  ),
                  _InfoLine(label: 'BMI/tuổi', value: bmiText),
                  _InfoLine(label: 'Cao/tuổi', value: heightAge),
                  _InfoLine(label: 'Nặng/tuổi', value: weightAge),
                ],
              ),
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              value.isEmpty ? '—' : value,
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

String _formatDateVi(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return '—';
  }
  final parsed = DateTime.tryParse(trimmed);
  if (parsed == null) {
    return trimmed.length >= 10 ? trimmed.substring(0, 10) : trimmed;
  }
  final day = parsed.day.toString().padLeft(2, '0');
  final month = parsed.month.toString().padLeft(2, '0');
  return '$day/$month/${parsed.year}';
}

String _formatMeasure(double value) {
  if (value <= 0) {
    return '—';
  }
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
}
