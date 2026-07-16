import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_options.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/text_normalizer.dart';
import '../../../core/utils/class_sort.dart';
import '../../../core/utils/student_enrollment.dart';
import '../../../core/widgets/app_date_field.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/sorak_avatar.dart';
import '../../academic_years/providers/active_academic_year_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../classes/models/school_class.dart';
import '../../classes/providers/class_provider.dart';
import '../../form_options/providers/form_options_provider.dart';
import '../../students/models/student.dart';
import '../../students/providers/student_provider.dart';
import '../models/health_assessment.dart';
import '../providers/health_assessment_provider.dart';

/// One latest-assessment card per student. Tapping a card opens that student's
/// full health history in a read-only bottom sheet.
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
      _initializeScreen();
    });
  }

  Future<void> _initializeScreen() async {
    await Future.wait([
      context.read<FormOptionsProvider>().loadInitialOptions(),
      _loadRoleScopedClasses(),
      _loadStudentsAndLatest(),
    ]);
  }

  Future<void> _loadStudentsAndLatest() async {
    final yearId = context.read<ActiveAcademicYearProvider>().selectedYearId;
    final health = context.read<HealthAssessmentProvider>();
    if (yearId == null) {
      await Future.wait([
        context.read<StudentProvider>().loadItems(),
        health.loadLatest(),
        health.loadItems(),
      ]);
      return;
    }
    await Future.wait([
      context.read<StudentProvider>().loadForAcademicYear(yearId),
      health.loadLatest(schoolYearId: yearId),
      health.loadForAcademicYear(yearId),
    ]);
  }

  Future<void> _loadRoleScopedClasses() async {
    final isTeacher =
        context.read<AuthProvider>().currentUser?.role.toUpperCase() ==
        'TEACHER';
    if (!isTeacher) {
      return;
    }
    final classProvider = context.read<ClassProvider>();
    final yearId = context.read<ActiveAcademicYearProvider>().selectedYearId;
    if (yearId == null) {
      await classProvider.loadItems();
    } else {
      await classProvider.loadForAcademicYear(yearId);
    }
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
    await Future.wait([
      context.read<FormOptionsProvider>().loadInitialOptions(),
      _loadRoleScopedClasses(),
      _loadStudentsAndLatest(),
    ]);
  }

  List<Student> _filtered(List<Student> source, Set<int>? allowedClassIds) {
    final query = normalizeVietnamese(_search);
    final classId = int.tryParse(_selectedClassId ?? '');

    final items = source.where((item) {
      if (!isStudentCurrentlyEnrolled(item)) return false;
      if (allowedClassIds != null && !allowedClassIds.contains(item.classId)) {
        return false;
      }
      if (classId != null && item.classId != classId) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final haystack = normalizeVietnamese(
        [
          item.fullName,
          item.studentIdCardNumber,
          item.className,
          '${item.id}',
        ].join(' '),
      );
      return haystack.contains(query);
    }).toList();

    items.sort((a, b) {
      return normalizeVietnamese(
        a.fullName,
      ).compareTo(normalizeVietnamese(b.fullName));
    });
    return items;
  }

  List<AppOption<String>> _classOptions(List<SchoolClass> classes) {
    final sortedClasses = sortedClassesByGrade(classes);

    return [
      const AppOption(value: '', label: 'Tất cả lớp'),
      ...sortedClasses.map((schoolClass) {
        final room = schoolClass.room.isEmpty ? '' : ' - ${schoolClass.room}';
        return AppOption(
          value: '${schoolClass.id}',
          label: '${schoolClass.className}$room',
        );
      }),
    ];
  }

  void _openHistorySheet(Student student, int? academicYearId) {
    final history = context.read<HealthAssessmentProvider>().getStudentHistory(
      studentId: student.id,
      schoolYearId: academicYearId,
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radius),
        ),
      ),
      builder: (context) =>
          _HealthHistorySheet(student: student, history: history),
    );
  }

  String? _validSelectedClassId(List<SchoolClass> classes) {
    final selectedId = int.tryParse(_selectedClassId ?? '');
    if (selectedId == null) {
      return null;
    }
    if (classes.any((schoolClass) => schoolClass.id == selectedId)) {
      return _selectedClassId;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _selectedClassId != null) {
        setState(() => _selectedClassId = null);
      }
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final optionsProvider = context.watch<FormOptionsProvider>();
    final studentProvider = context.watch<StudentProvider>();
    final healthProvider = context.watch<HealthAssessmentProvider>();
    final role = context.watch<AuthProvider>().currentUser?.role.toUpperCase();
    final isTeacher = role == 'TEACHER';
    final classProvider = context.watch<ClassProvider>();
    final scopedClasses = isTeacher
        ? classProvider.items
        : optionsProvider.classes;
    final isClassScopeLoading = isTeacher && classProvider.isLoading;
    final selectedClassId = _validSelectedClassId(scopedClasses);
    final allowedClassIds = isTeacher
        ? scopedClasses.map((schoolClass) => schoolClass.id).toSet()
        : null;
    final items = _filtered(studentProvider.items, allowedClassIds);
    final latestByStudent = {
      for (final item in healthProvider.latestByStudent) item.studentId: item,
    };
    final selectedDate = _dateController.text.trim();
    final selectedDateByStudent = <int, HealthAssessment>{};
    if (selectedDate.isNotEmpty) {
      for (final item in healthProvider.items) {
        if (item.assessmentDate.startsWith(selectedDate)) {
          selectedDateByStudent[item.studentId] = item;
        }
      }
    }
    final isDateFiltered = selectedDate.isNotEmpty;
    final academicYearId = context
        .watch<ActiveAcademicYearProvider>()
        .selectedYearId;
    final isLoading =
        studentProvider.isLoading ||
        healthProvider.isLoading ||
        healthProvider.isLoadingLatest ||
        optionsProvider.isLoading ||
        isClassScopeLoading;
    final errorMessage = studentProvider.errorMessage ?? healthProvider.errorMessage;

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
              value: selectedClassId ?? '',
              hintText: 'Chọn lớp',
              enabled:
                  !optionsProvider.isLoading &&
                  !isClassScopeLoading &&
                  scopedClasses.isNotEmpty,
              onChanged: (value) {
                setState(() {
                  _selectedClassId = (value == null || value.isEmpty)
                      ? null
                      : value;
                });
              },
            ),
            if (!isClassScopeLoading && scopedClasses.isEmpty) ...[
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
                if (isDateFiltered) ...[
                  const SizedBox(width: AppSpacing.xs),
                  IconButton(
                    tooltip: 'Xóa ngày',
                    onPressed: _dateController.clear,
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
              items.isEmpty ? '0 học sinh' : '${items.length} học sinh',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (isLoading && studentProvider.items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: LoadingView(),
              )
            else if (errorMessage != null && studentProvider.items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: ErrorView(message: errorMessage, onRetry: _reload),
              )
            else if (items.isEmpty)
              EmptyView(
                title: _search.trim().isNotEmpty || _selectedClassId != null
                    ? 'Không tìm thấy học sinh'
                    : 'Chưa có học sinh',
                message: _search.trim().isNotEmpty || _selectedClassId != null
                    ? 'Thử đổi lớp hoặc từ khóa tìm kiếm.'
                    : 'Chưa có học sinh trong năm học này.',
                type: _search.trim().isNotEmpty || _selectedClassId != null
                    ? EmptyViewType.search
                    : EmptyViewType.data,
              )
            else
              for (var index = 0; index < items.length; index++) ...[
                _HealthHistoryCard(
                  index: index + 1,
                  student: items[index],
                  assessment: isDateFiltered
                      ? selectedDateByStudent[items[index].id]
                      : latestByStudent[items[index].id],
                  dateFiltered: isDateFiltered,
                  onTap: isDateFiltered
                      ? null
                      : () => _openHistorySheet(items[index], academicYearId),
                ),
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
  const _HealthHistoryCard({
    required this.index,
    required this.student,
    required this.assessment,
    required this.dateFiltered,
    required this.onTap,
  });

  final int index;
  final Student student;
  final HealthAssessment? assessment;
  final bool dateFiltered;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final latest = assessment;
    final dateText = latest == null
        ? 'Chưa có'
        : _formatDateVi(latest.assessmentDate);
    final heightText = latest == null || latest.heightCm <= 0
        ? 'Chưa có'
        : '${_formatMeasure(latest.heightCm)} cm';
    final weightText = latest == null || latest.weightKg <= 0
        ? 'Chưa có'
        : '${_formatMeasure(latest.weightKg)} kg';
    final bmiText = latest == null || latest.bmi <= 0
        ? 'Chưa có'
        : latest.bmiStatus.isEmpty
        ? latest.bmi.toStringAsFixed(1)
        : '${latest.bmi.toStringAsFixed(1)} ${latest.bmiStatus}';
    final heightAge = latest == null
        ? 'Chưa có'
        : _valueOrMissing(latest.heightStatus);
    final weightAge = latest == null
        ? 'Chưa có'
        : _valueOrMissing(latest.weightStatus);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      right: AppSpacing.xs,
                    ),
                    child: Text(
                      '$index.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SorakAvatar(
                    seed: student.id,
                    fallbackLabel: student.fullName,
                    size: 44,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName.isEmpty
                              ? 'Học sinh'
                              : student.fullName,
                          softWrap: true,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                              ),
                        ),
                        if (student.studentIdCardNumber.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            student.studentIdCardNumber,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.mutedForeground,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'monospace',
                                ),
                          ),
                        ],
                        if (student.className.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            student.className,
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
                  if (onTap != null)
                    const Padding(
                      padding: EdgeInsets.only(top: AppSpacing.xs),
                      child: Icon(
                        LucideIcons.chevronRight,
                        size: 20,
                        color: AppColors.mutedForeground,
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
                    _InfoLine(
                      label: dateFiltered
                          ? 'Ngày đánh giá'
                          : 'Đánh giá mới nhất',
                      value: dateText,
                    ),
                    _InfoLine(label: 'Chiều cao', value: heightText),
                    _InfoLine(label: 'Cân nặng', value: weightText),
                    _InfoLine(label: 'BMI/tuổi', value: bmiText),
                    _InfoLine(label: 'Cao/tuổi', value: heightAge),
                    _InfoLine(label: 'Nặng/tuổi', value: weightAge),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthHistorySheet extends StatelessWidget {
  const _HealthHistorySheet({required this.student, required this.history});

  final Student student;
  final Future<List<HealthAssessment>> history;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.86,
      minChildSize: 0.55,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: AppSpacing.xs),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.input,
                borderRadius: BorderRadius.circular(AppSpacing.radius),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  SorakAvatar(
                    seed: student.id,
                    fallbackLabel: student.fullName,
                    size: 48,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName.isEmpty
                              ? 'Học sinh'
                              : student.fullName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        if (student.studentIdCardNumber.isNotEmpty ||
                            student.className.isNotEmpty)
                          Text(
                            [
                              student.studentIdCardNumber,
                              student.className,
                            ].where((value) => value.isNotEmpty).join('  '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.mutedForeground,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: FutureBuilder<List<HealthAssessment>>(
                future: history,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const LoadingView();
                  }
                  if (snapshot.hasError) {
                    return ErrorView(
                      message: '${snapshot.error}',
                      onRetry: () => Navigator.pop(context),
                    );
                  }
                  final items = [...?snapshot.data]
                    ..sort(
                      (a, b) => b.assessmentDate.compareTo(a.assessmentDate),
                    );
                  return ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.lg,
                    ),
                    children: [
                      Text(
                        'Lịch sử đánh giá sức khỏe',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${items.length} lần đánh giá',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (items.isEmpty)
                        const EmptyView(
                          title: 'Chưa có lịch sử đánh giá',
                          message: 'Học sinh này chưa có dữ liệu sức khỏe.',
                          type: EmptyViewType.data,
                        )
                      else
                        for (var index = 0; index < items.length; index++) ...[
                          _HealthHistoryRecordCard(assessment: items[index]),
                          if (index < items.length - 1)
                            const SizedBox(height: AppSpacing.sm),
                        ],
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HealthHistoryRecordCard extends StatelessWidget {
  const _HealthHistoryRecordCard({required this.assessment});

  final HealthAssessment assessment;

  @override
  Widget build(BuildContext context) {
    final bmi = assessment.bmi <= 0
        ? 'Chưa có'
        : assessment.bmi.toStringAsFixed(2);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.calendarDays,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    _formatDateVi(assessment.assessmentDate),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _InfoLine(
              label: 'Chiều cao',
              value: assessment.heightCm <= 0
                  ? 'Chưa có'
                  : '${_formatMeasure(assessment.heightCm)} cm',
            ),
            _InfoLine(
              label: 'Cân nặng',
              value: assessment.weightKg <= 0
                  ? 'Chưa có'
                  : '${_formatMeasure(assessment.weightKg)} kg',
            ),
            _InfoLine(label: 'BMI', value: bmi),
            _InfoLine(
              label: 'BMI/tuổi',
              value: _valueOrMissing(assessment.bmiStatus),
            ),
            _InfoLine(
              label: 'Cao/tuổi',
              value: _valueOrMissing(assessment.heightStatus),
            ),
            _InfoLine(
              label: 'Nặng/tuổi',
              value: _valueOrMissing(assessment.weightStatus),
            ),
            if (assessment.note.trim().isNotEmpty) ...[
              const Divider(height: AppSpacing.md),
              Text(
                'Ghi chú',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                assessment.note.trim(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
    final displayValue = value.isEmpty ? 'Chưa có' : value;
    final isMissing = displayValue == 'Chưa có';

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
              displayValue,
              textAlign: TextAlign.right,
              softWrap: true,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isMissing ? AppColors.primary : AppColors.foreground,
                fontWeight: isMissing ? FontWeight.w600 : FontWeight.w700,
                fontStyle: isMissing ? FontStyle.italic : FontStyle.normal,
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
    return 'Chưa có';
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

String _valueOrMissing(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? 'Chưa có' : trimmed;
}
