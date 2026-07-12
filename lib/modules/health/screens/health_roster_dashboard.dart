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
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/sorak_avatar.dart';
import '../../academic_years/providers/active_academic_year_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../classes/models/school_class.dart';
import '../../classes/providers/class_provider.dart';
import '../../form_options/providers/form_options_provider.dart';
import '../../students/models/student.dart';
import '../models/health_assessment.dart';
import '../models/nutrition_assessment.dart';
import '../providers/growth_who_provider.dart';
import '../providers/health_assessment_provider.dart';
import '../providers/nutrition_assessment_provider.dart';

enum HealthRosterMode { health, nutrition }

class HealthRosterDashboard extends StatefulWidget {
  const HealthRosterDashboard({super.key, required this.mode});

  final HealthRosterMode mode;

  @override
  HealthRosterDashboardState createState() => HealthRosterDashboardState();
}

class HealthRosterDashboardState extends State<HealthRosterDashboard> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedClassId;
  String _selectedPeriod = 'dau_nam';
  String _search = '';
  bool _isReloadingRoster = false;

  bool get _isHealth => widget.mode == HealthRosterMode.health;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toIso8601String().substring(0, 10);
    _dateController.addListener(_onDateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDashboard();
    });
  }

  Future<void> _initializeDashboard() async {
    await Future.wait([
      context.read<FormOptionsProvider>().loadInitialOptions(),
      _loadRoleScopedClasses(),
    ]);
    if (mounted) {
      await _reloadRoster();
    }
  }

  Future<void> _loadRoleScopedClasses() async {
    if (!_isTeacher(context)) {
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
    _dateController.removeListener(_onDateChanged);
    _dateController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onDateChanged() {
    if (_isHealth) {
      _reloadRoster();
    }
  }

  /// Public entry for AppBar refresh (same as pull-to-reload path).
  Future<void> reload() => _reloadRoster(forceOptions: true);

  Future<void> _reloadRoster({bool forceOptions = false}) async {
    if (!mounted || _isReloadingRoster) {
      return;
    }

    final formOptions = context.read<FormOptionsProvider>();
    final healthProvider = context.read<HealthAssessmentProvider>();
    final nutritionProvider = context.read<NutritionAssessmentProvider>();
    final yearId = context.read<ActiveAcademicYearProvider>().selectedYearId;

    if (forceOptions) {
      await Future.wait([
        formOptions.loadInitialOptions(),
        _loadRoleScopedClasses(),
      ]);
      if (!mounted) {
        return;
      }
    }

    final classId = int.tryParse(_selectedClassId ?? '');
    if (classId == null) {
      return;
    }
    if (_isTeacher(context) &&
        !context.read<ClassProvider>().items.any(
          (schoolClass) => schoolClass.id == classId,
        )) {
      return;
    }

    setState(() => _isReloadingRoster = true);
    try {
      if (_isHealth) {
        await healthProvider.loadByClassDate(
          classId: classId,
          assessmentDate: _dateController.text.trim(),
        );
      } else {
        if (yearId == null) {
          return;
        }
        await nutritionProvider.loadGrid(
          classId: classId,
          schoolYearId: yearId,
          period: _selectedPeriod,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isReloadingRoster = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final optionsProvider = context.watch<FormOptionsProvider>();
    final healthProvider = context.watch<HealthAssessmentProvider>();
    final nutritionProvider = context.watch<NutritionAssessmentProvider>();
    final yearId = context.watch<ActiveAcademicYearProvider>().selectedYearId;
    final isTeacher =
        context.watch<AuthProvider>().currentUser?.role.toUpperCase() ==
        'TEACHER';
    final classProvider = context.watch<ClassProvider>();
    final scopedClasses = isTeacher
        ? classProvider.items
        : optionsProvider.classes;
    final isClassScopeLoading = isTeacher && classProvider.isLoading;
    _applyDefaultClass(scopedClasses);

    final students = _studentsForClass(optionsProvider);
    final visibleStudents = _filterStudentsBySearch(students);
    final isLoading =
        optionsProvider.isLoading ||
        healthProvider.isLoading ||
        nutritionProvider.isLoading ||
        isClassScopeLoading ||
        _isReloadingRoster;
    final errorMessage = _isHealth
        ? healthProvider.errorMessage
        : nutritionProvider.errorMessage;

    return Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isHealth ? 'Đánh giá sức khỏe' : 'Đánh giá nuôi dưỡng',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppDropdownField<String>(
            key: ValueKey('health_roster_class_${_selectedClassId ?? ''}'),
            label: 'Lớp',
            options: _classOptions(scopedClasses),
            value: _selectedClassId,
            hintText: 'Chọn lớp',
            enabled:
                !optionsProvider.isLoading &&
                !isClassScopeLoading &&
                scopedClasses.isNotEmpty,
            onChanged: (value) {
              setState(() => _selectedClassId = value);
              context.read<FormOptionsProvider>().selectClass(
                int.tryParse(value ?? ''),
              );
              _reloadRoster();
            },
          ),
          if (!isClassScopeLoading && scopedClasses.isEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            const _NoCompatibleClassNotice(),
          ],
          const SizedBox(height: AppSpacing.sm),
          if (_isHealth)
            AppDateField(
              controller: _dateController,
              label: 'Ngày đánh giá',
              firstDate: DateTime(2020),
              lastDate: DateTime(DateTime.now().year + 1, 12, 31),
            )
          else
            AppDropdownField<String>(
              key: ValueKey('nutrition_period_$_selectedPeriod'),
              label: 'Giai đoạn',
              options: _periodOptions,
              value: _selectedPeriod,
              hintText: 'Chọn giai đoạn',
              onChanged: (value) {
                setState(() => _selectedPeriod = value ?? 'dau_nam');
                _reloadRoster();
              },
            ),
          const SizedBox(height: AppSpacing.sm),
          // Web: "Lọc theo tên / mã..."
          AppSearchBar(
            controller: _searchController,
            hintText: 'Lọc theo tên / mã...',
            onChanged: (value) => setState(() => _search = value),
            onClear: () {
              _searchController.clear();
              setState(() => _search = '');
            },
          ),
          if (!_isHealth && yearId == null) ...[
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Chưa chọn năm học — không thể tải lưới nuôi dưỡng.',
              style: TextStyle(color: AppColors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _RosterSummary(
            total: visibleStudents.length,
            completed: _completedCount(
              visibleStudents,
              healthProvider.items,
              nutritionProvider.items,
            ),
            label: _isHealth ? 'đã đo hôm nay' : 'đã đánh giá',
          ),
          const SizedBox(height: AppSpacing.sm),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            // Always surface roster API errors, even when FormOptions still
            // has students (otherwise failed by-class-date/grid looks empty).
            if (errorMessage != null)
              Padding(
                key: const Key('health_roster_error_banner'),
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Column(
                  children: [
                    Text(
                      errorMessage,
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: _reloadRoster,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            if (students.isEmpty)
              const _EmptyRoster()
            else if (visibleStudents.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Center(
                  child: Text(
                    'Không có học sinh khớp tên / mã tìm kiếm.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              for (var index = 0; index < visibleStudents.length; index++) ...[
                _StudentRosterCard(
                  index: index + 1,
                  student: visibleStudents[index],
                  mode: widget.mode,
                  health: _latestHealth(
                    visibleStudents[index].id,
                    healthProvider.items,
                  ),
                  nutrition: _latestNutrition(
                    visibleStudents[index].id,
                    nutritionProvider.items,
                  ),
                  onTap: () => _openStudentPreview(
                    visibleStudents[index],
                    healthProvider.items,
                    nutritionProvider.items,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
          ],
        ],
      ),
    );
  }

  void _applyDefaultClass(List<SchoolClass> classes) {
    if (_selectedClassId != null || classes.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selectedClassId != null || classes.isEmpty) {
        return;
      }
      setState(() => _selectedClassId = '${classes.first.id}');
      context.read<FormOptionsProvider>().selectClass(classes.first.id);
      _reloadRoster();
    });
  }

  List<Student> _studentsForClass(FormOptionsProvider optionsProvider) {
    final classId = int.tryParse(_selectedClassId ?? '');
    return optionsProvider.allStudents.where((student) {
      return classId == null || student.classId == classId;
    }).toList();
  }

  List<Student> _filterStudentsBySearch(List<Student> students) {
    final query = normalizeVietnamese(_search);
    if (query.isEmpty) {
      return students;
    }
    return students.where((student) {
      final haystack = normalizeVietnamese(
        [
          student.fullName,
          student.studentIdCardNumber,
          '${student.id}',
        ].join(' '),
      );
      return haystack.contains(query);
    }).toList();
  }

  List<AppOption<String>> _classOptions(List<SchoolClass> classes) {
    return classes.map((schoolClass) {
      final room = schoolClass.room.isEmpty ? '' : ' - ${schoolClass.room}';
      return AppOption(
        value: '${schoolClass.id}',
        label: '${schoolClass.className}$room',
      );
    }).toList();
  }

  bool _isTeacher(BuildContext context) {
    try {
      return context.read<AuthProvider>().currentUser?.role.toUpperCase() ==
          'TEACHER';
    } on ProviderNotFoundException {
      return false;
    }
  }

  int _completedCount(
    List<Student> students,
    List<HealthAssessment> healthItems,
    List<NutritionAssessment> nutritionItems,
  ) {
    final ids = students.map((student) => student.id).toSet();
    if (_isHealth) {
      final date = _dateController.text.trim();
      return healthItems.where((item) {
        return ids.contains(item.studentId) &&
            item.assessmentDate.startsWith(date);
      }).length;
    }

    return nutritionItems.where((item) {
      return ids.contains(item.studentId) && item.period == _selectedPeriod;
    }).length;
  }

  HealthAssessment? _latestHealth(int studentId, List<HealthAssessment> items) {
    final matches = items.where((item) {
      if (item.studentId != studentId) {
        return false;
      }
      // Treat 0/0 as empty prefill rows (should not happen from by-class-date).
      return item.heightCm > 0 && item.weightKg > 0;
    }).toList();
    matches.sort((a, b) => b.assessmentDate.compareTo(a.assessmentDate));
    return matches.isEmpty ? null : matches.first;
  }

  NutritionAssessment? _latestNutrition(
    int studentId,
    List<NutritionAssessment> items,
  ) {
    final matches = items.where((item) => item.studentId == studentId).toList();
    return matches.isEmpty ? null : matches.last;
  }

  Future<void> _openStudentPreview(
    Student student,
    List<HealthAssessment> healthItems,
    List<NutritionAssessment> nutritionItems,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    var studentHealthHistory = healthItems
        .where((item) => item.studentId == student.id)
        .toList();
    if (_isHealth) {
      final role =
          context.read<AuthProvider>().currentUser?.role.toUpperCase() ??
          'TEACHER';
      final academicYearId = context
          .read<ActiveAcademicYearProvider>()
          .selectedYearId;
      try {
        studentHealthHistory = await context
            .read<GrowthWhoProvider>()
            .getStudentHistory(
              studentId: student.id,
              role: role,
              academicYearId: academicYearId,
            );
      } catch (_) {
        // Keep the date-roster data as a safe fallback when history is offline.
      }
    }
    if (!mounted) {
      return;
    }
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return _StudentPreviewSheet(
          mode: widget.mode,
          student: student,
          selectedClassId: int.tryParse(_selectedClassId ?? '') ?? 0,
          selectedDate: _dateController.text,
          selectedPeriod: _selectedPeriod,
          history: studentHealthHistory,
          nutritionHistory: nutritionItems
              .where((item) => item.studentId == student.id)
              .toList(),
        );
      },
    );

    if (!messenger.mounted || saved == null) {
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(saved ? 'Đã lưu đánh giá' : 'Chưa thể lưu đánh giá'),
      ),
    );

    if (saved) {
      await _reloadRoster();
    }
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

class _StudentRosterCard extends StatelessWidget {
  const _StudentRosterCard({
    required this.index,
    required this.student,
    required this.mode,
    required this.health,
    required this.nutrition,
    required this.onTap,
  });

  final int index;
  final Student student;
  final HealthRosterMode mode;
  final HealthAssessment? health;
  final NutritionAssessment? nutrition;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isHealth = mode == HealthRosterMode.health;
    final healthItem = health;
    final hasMeasure = healthItem != null;
    final heightText = hasMeasure
        ? '${_formatMeasure(healthItem.heightCm)} cm'
        : 'Chưa đo';
    final weightText = hasMeasure
        ? '${_formatMeasure(healthItem.weightKg)} kg'
        : 'Chưa đo';

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
                  // Light STT outside — no boxed chip.
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
                          student.fullName,
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
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 20,
                    color: AppColors.mutedForeground,
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
                    _RosterInfoLine(
                      label: 'Mã thẻ',
                      value: student.studentIdCardNumber.isEmpty
                          ? '—'
                          : student.studentIdCardNumber,
                    ),
                    _RosterInfoLine(label: 'Họ tên', value: student.fullName),
                    _RosterInfoLine(
                      label: 'Ngày sinh',
                      value: _formatDateVi(student.dateOfBirth),
                    ),
                    _RosterInfoLine(
                      label: 'Giới tính',
                      value: student.gender.isEmpty ? '—' : student.gender,
                    ),
                    if (isHealth) ...[
                      _RosterInfoLine(
                        label: 'Cân nặng',
                        value: weightText,
                        emphasize: !hasMeasure,
                      ),
                      _RosterInfoLine(
                        label: 'Chiều cao',
                        value: heightText,
                        emphasize: !hasMeasure,
                      ),
                      if (hasMeasure && healthItem.bmiStatus.isNotEmpty)
                        _RosterInfoLine(
                          label: 'BMI',
                          value:
                              '${healthItem.bmi.toStringAsFixed(1)} · ${healthItem.bmiStatus}',
                        ),
                    ] else ...[
                      _RosterInfoLine(
                        label: 'Nuôi dưỡng',
                        value: nutrition == null
                            ? 'Chưa có đánh giá'
                            : nutrition!.statusSummary,
                      ),
                    ],
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

class _RosterInfoLine extends StatelessWidget {
  const _RosterInfoLine({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;

  /// Primary italic for empty measure state ("Chưa đo").
  final bool emphasize;

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
              value,
              textAlign: TextAlign.right,
              softWrap: true,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: emphasize ? AppColors.primary : AppColors.foreground,
                fontWeight: emphasize ? FontWeight.w600 : FontWeight.w700,
                fontStyle: emphasize ? FontStyle.italic : FontStyle.normal,
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
    return trimmed;
  }
  final day = parsed.day.toString().padLeft(2, '0');
  final month = parsed.month.toString().padLeft(2, '0');
  return '$day/$month/${parsed.year}';
}

String _formatMeasure(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
}

/// Prefill input: empty when missing/zero; avoid "0.0" noise.
String _measureInputText(double? value) {
  if (value == null || value <= 0) {
    return '';
  }
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
}

/// Accept "16,5" (VN keyboard) as well as "16.5".
double? _parseMeasure(String raw) {
  final cleaned = raw.trim().replaceAll(',', '.');
  if (cleaned.isEmpty) {
    return null;
  }
  return double.tryParse(cleaned);
}

class _StudentPreviewSheet extends StatefulWidget {
  const _StudentPreviewSheet({
    required this.mode,
    required this.student,
    required this.selectedClassId,
    required this.selectedDate,
    required this.selectedPeriod,
    required this.history,
    required this.nutritionHistory,
  });

  final HealthRosterMode mode;
  final Student student;
  final int selectedClassId;
  final String selectedDate;
  final String selectedPeriod;
  final List<HealthAssessment> history;
  final List<NutritionAssessment> nutritionHistory;

  @override
  State<_StudentPreviewSheet> createState() => _StudentPreviewSheetState();
}

class _StudentPreviewSheetState extends State<_StudentPreviewSheet> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _weightChannel = NutritionOptions.weightNormal;
  bool _isStunting = false;
  bool _isSevereStunting = false;
  bool _isObese = false;
  bool _isSaving = false;
  bool _allowPop = false;

  /// After a failed save attempt, show which health fields are still missing.
  bool _showHealthMeasureHint = false;
  late final String _initialHeight;
  late final String _initialWeight;
  late final String _initialNote;
  late final String _initialWeightChannel;
  late final bool _initialIsStunting;
  late final bool _initialIsSevereStunting;
  late final bool _initialIsObese;

  bool get _isHealth => widget.mode == HealthRosterMode.health;

  double? get _parsedHeight => _parseMeasure(_heightController.text);
  double? get _parsedWeight => _parseMeasure(_weightController.text);

  /// Backend bulk requires both height_cm and weight_kg > 0 to create/update.
  bool get _hasValidHealthMeasures {
    final height = _parsedHeight;
    final weight = _parsedWeight;
    return height != null && height > 0 && weight != null && weight > 0;
  }

  @override
  void initState() {
    super.initState();
    final latestHealth = _latestHealth;
    _heightController.text = _measureInputText(latestHealth?.heightCm);
    _weightController.text = _measureInputText(latestHealth?.weightKg);
    _noteController.text = _isHealth
        ? latestHealth?.note ?? ''
        : _latestNutrition?.note ?? '';
    _weightChannel = _latestNutrition?.weightChannel.isEmpty == false
        ? _latestNutrition!.weightChannel
        : NutritionOptions.weightNormal;
    _isStunting = _latestNutrition?.isStunting ?? false;
    _isSevereStunting = _latestNutrition?.isSevereStunting ?? false;
    _isObese = _latestNutrition?.isObese ?? false;
    _initialHeight = _heightController.text;
    _initialWeight = _weightController.text;
    _initialNote = _noteController.text;
    _initialWeightChannel = _weightChannel;
    _initialIsStunting = _isStunting;
    _initialIsSevereStunting = _isSevereStunting;
    _initialIsObese = _isObese;
    _heightController.addListener(_onTextChanged);
    _weightController.addListener(_onTextChanged);
    _noteController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _heightController.removeListener(_onTextChanged);
    _weightController.removeListener(_onTextChanged);
    _noteController.removeListener(_onTextChanged);
    _heightController.dispose();
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  HealthAssessment? get _latestHealth {
    final items = List<HealthAssessment>.of(widget.history);
    items.sort((a, b) => b.assessmentDate.compareTo(a.assessmentDate));
    return items.isEmpty ? null : items.first;
  }

  NutritionAssessment? get _latestNutrition {
    return widget.nutritionHistory.isEmpty
        ? null
        : widget.nutritionHistory.last;
  }

  bool get _isDirty {
    return _heightController.text != _initialHeight ||
        _weightController.text != _initialWeight ||
        _noteController.text != _initialNote ||
        _weightChannel != _initialWeightChannel ||
        _isStunting != _initialIsStunting ||
        _isSevereStunting != _initialIsSevereStunting ||
        _isObese != _initialIsObese;
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {
        // Clear partial-entry hint once user completes both measures.
        if (_hasValidHealthMeasures) {
          _showHealthMeasureHint = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final availableHeight = media.size.height - media.viewInsets.bottom;

    return PopScope<bool>(
      canPop: _allowPop || !_isDirty,
      onPopInvokedWithResult: (didPop, result) => _handlePop(didPop),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: SafeArea(
          top: false,
          child: Material(
            color: AppColors.popover,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radius),
            ),
            child: SizedBox(
              height: availableHeight * 0.9,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Drag handle
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                          Text(
                            widget.student.fullName,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.foreground,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            [
                              if (widget.student.studentIdCardNumber.isNotEmpty)
                                widget.student.studentIdCardNumber,
                              if (widget.student.className.isNotEmpty)
                                widget.student.className,
                              if (widget.student.gender.isNotEmpty)
                                widget.student.gender,
                              _formatDateVi(widget.student.dateOfBirth),
                            ].join(' · '),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.mutedForeground,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (_isHealth) ...[
                            _EntryBlock(
                              title: 'Số đo gần nhất',
                              child: _PreviewSummary(
                                health: _latestHealth,
                                nutrition: _latestNutrition,
                                mode: widget.mode,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _EntryBlock(
                              title: 'Chiều cao (cm)',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AppTextField(
                                    controller: _heightController,
                                    label: 'Nhập chiều cao',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                  ),
                                  if (_showHealthMeasureHint &&
                                      (_parsedHeight == null ||
                                          _parsedHeight! <= 0))
                                    const Padding(
                                      padding: EdgeInsets.only(top: 6),
                                      child: Text(
                                        'Thiếu chiều cao hợp lệ',
                                        style: TextStyle(
                                          color: AppColors.error,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  _PresetChipRow(
                                    values: _heightPresets,
                                    selectedText: _heightController.text.trim(),
                                    onSelected: (value) {
                                      setState(() {
                                        _heightController.text = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _EntryBlock(
                              title: 'Cân nặng (kg)',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AppTextField(
                                    controller: _weightController,
                                    label: 'Nhập cân nặng',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                  ),
                                  if (_showHealthMeasureHint &&
                                      (_parsedWeight == null ||
                                          _parsedWeight! <= 0))
                                    const Padding(
                                      padding: EdgeInsets.only(top: 6),
                                      child: Text(
                                        'Thiếu cân nặng hợp lệ',
                                        style: TextStyle(
                                          color: AppColors.error,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  _PresetChipRow(
                                    values: _weightPresets,
                                    selectedText: _weightController.text.trim(),
                                    onSelected: (value) {
                                      setState(() {
                                        _weightController.text = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 6),
                                  _DeltaChipRow(
                                    onDelta: (delta) {
                                      final current =
                                          _parseMeasure(
                                            _weightController.text,
                                          ) ??
                                          0;
                                      final next = (current + delta).clamp(
                                        0,
                                        100,
                                      );
                                      setState(() {
                                        _weightController.text =
                                            next == next.roundToDouble()
                                            ? next.toStringAsFixed(0)
                                            : next.toStringAsFixed(1);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.xs,
                              ),
                              child: Text(
                                'Cần nhập đủ cả chiều cao và cân nặng để lưu.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _EntryBlock(
                              title: 'Ghi chú',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AppTextField(
                                    controller: _noteController,
                                    label: 'Nhập ghi chú',
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 8),
                                  _NoteChipRow(
                                    selected: _noteController.text.trim(),
                                    onSelected: (note) {
                                      setState(() {
                                        _noteController.text = note;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            if (widget.history.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.sm),
                              _EntryBlock(
                                title: 'Lịch sử gần đây',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (final item in widget.history.take(3))
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        child: Text(
                                          '${item.assessmentDate.length >= 10 ? item.assessmentDate.substring(0, 10) : item.assessmentDate} · ${_formatMeasure(item.heightCm)} cm · ${_formatMeasure(item.weightKg)} kg',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color:
                                                    AppColors.mutedForeground,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ] else ...[
                            Text(
                              'Preview nuôi dưỡng',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            _PreviewSummary(
                              health: _latestHealth,
                              nutrition: _latestNutrition,
                              mode: widget.mode,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppDropdownField<String>(
                              key: ValueKey(
                                'nutrition_channel_$_weightChannel',
                              ),
                              label: 'Kênh tăng trưởng cân nặng',
                              options: NutritionOptions.weightChannels,
                              value: _weightChannel,
                              onChanged: (value) {
                                setState(() {
                                  _weightChannel =
                                      value ?? NutritionOptions.weightNormal;
                                });
                              },
                            ),
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('SDD thấp còi'),
                              value: _isStunting,
                              onChanged: (value) {
                                setState(() => _isStunting = value ?? false);
                              },
                            ),
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('SDD còi cọc'),
                              value: _isSevereStunting,
                              onChanged: (value) {
                                setState(
                                  () => _isSevereStunting = value ?? false,
                                );
                              },
                            ),
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Béo phì'),
                              value: _isObese,
                              onChanged: (value) {
                                setState(() => _isObese = value ?? false);
                              },
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppTextField(
                              controller: _noteController,
                              label: 'Ghi chú',
                              maxLines: 2,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      color: AppColors.popover,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          key: const Key('health_roster_save_button'),
                          // Enable when dirty so partial height-only entry still
                          // shows a clear "need weight" message instead of a
                          // silent disabled button.
                          onPressed: _isSaving || !_isDirty
                              ? null
                              : () {
                                  if (_isHealth && !_hasValidHealthMeasures) {
                                    setState(
                                      () => _showHealthMeasureHint = true,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          _healthMeasureErrorMessage(),
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  _save();
                                },
                          child: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryForeground,
                                  ),
                                )
                              : Text(
                                  _isHealth ? 'Lưu sức khỏe' : 'Lưu nuôi dưỡng',
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePop(bool didPop) async {
    if (didPop || !_isDirty || _isSaving || !mounted) {
      return;
    }

    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Bỏ thay đổi?'),
        content: const Text(
          'Thông tin vừa nhập chưa được lưu. Bạn có muốn rời màn hình không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Tiếp tục nhập'),
          ),
          FilledButton(
            key: const ValueKey('discard_health_changes_button'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Bỏ thay đổi'),
          ),
        ],
      ),
    );

    if (discard == true && mounted) {
      setState(() => _allowPop = true);
      Navigator.pop(context);
    }
  }

  String _healthMeasureErrorMessage() {
    final heightMissing = _parsedHeight == null || _parsedHeight! <= 0;
    final weightMissing = _parsedWeight == null || _parsedWeight! <= 0;
    if (heightMissing && weightMissing) {
      return 'Vui lòng nhập chiều cao và cân nặng hợp lệ';
    }
    if (heightMissing) {
      return 'Vui lòng nhập chiều cao hợp lệ';
    }
    if (weightMissing) {
      return 'Vui lòng nhập cân nặng hợp lệ (bắt buộc cùng chiều cao)';
    }
    return 'Vui lòng nhập chiều cao và cân nặng hợp lệ';
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final healthProvider = context.read<HealthAssessmentProvider>();
    final nutritionProvider = context.read<NutritionAssessmentProvider>();
    final schoolYearId = context
        .read<ActiveAcademicYearProvider>()
        .selectedYearId;

    if (schoolYearId == null) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Chưa chọn năm học')));
      }
      return;
    }

    // Roster dropdown class wins; student.classId may be 0 from incomplete DTO.
    final classId = widget.selectedClassId != 0
        ? widget.selectedClassId
        : widget.student.classId;
    if (classId == 0) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa chọn lớp để lưu đánh giá')),
        );
      }
      return;
    }

    final height = _parsedHeight;
    final weight = _parsedWeight;
    if (_isHealth &&
        (height == null || height <= 0 || weight == null || weight <= 0)) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _showHealthMeasureHint = true;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_healthMeasureErrorMessage())));
      }
      return;
    }

    final ok = _isHealth
        ? await healthProvider.bulkSaveRoster(
            schoolYearId: schoolYearId,
            classId: classId,
            assessmentDate: widget.selectedDate,
            rows: [
              {
                'student_id': widget.student.id,
                'height_cm': height,
                'weight_kg': weight,
                'note': _noteController.text.trim(),
                'student_name': widget.student.fullName,
                'class_name': widget.student.className,
              },
            ],
          )
        : await nutritionProvider.bulkSaveGrid(
            classId: classId,
            schoolYearId: schoolYearId,
            period: widget.selectedPeriod,
            rows: [
              {
                'student_id': widget.student.id,
                'weight_channel':
                    _weightChannel == NutritionOptions.weightNormal
                    ? ''
                    : _weightChannel,
                'is_stunting': _isStunting,
                'is_severe_stunting': _isSevereStunting,
                'is_obese': _isObese,
                'note': _noteController.text.trim(),
                'student_name': widget.student.fullName,
                'class_name': widget.student.className,
              },
            ],
          );

    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);
    if (ok) {
      _allowPop = true;
      Navigator.pop(context, true);
    } else {
      final message = _isHealth
          ? healthProvider.errorMessage
          : nutritionProvider.errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Chưa thể lưu đánh giá')),
      );
    }
  }
}

/// Preset height values for preschool quick entry (cm).
const _heightPresets = <String>[
  '90',
  '95',
  '100',
  '105',
  '110',
  '115',
  '120',
  '125',
  '130',
];

/// Preset weight values for preschool quick entry (kg).
const _weightPresets = <String>[
  '12',
  '13',
  '14',
  '15',
  '16',
  '17',
  '18',
  '19',
  '20',
  '22',
  '24',
];

const _notePresets = <String>[
  'Khỏe mạnh',
  'Cảm cúm nhẹ',
  'Đang theo dõi',
  'Cần tái kiểm',
];

class _EntryBlock extends StatelessWidget {
  const _EntryBlock({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Light Claude surface: background + border (no heavy muted fill).
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _PresetChipRow extends StatelessWidget {
  const _PresetChipRow({
    required this.values,
    required this.selectedText,
    required this.onSelected,
  });

  final List<String> values;
  final String selectedText;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final value in values)
          FilterChip(
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            labelPadding: const EdgeInsets.symmetric(horizontal: 2),
            label: Text(value),
            selected: selectedText == value,
            showCheckmark: false,
            onSelected: (_) => onSelected(value),
            // Claude selected state: secondary surface, not loud primary fill.
            backgroundColor: AppColors.popover,
            selectedColor: AppColors.secondary,
            side: BorderSide(
              color: selectedText == value ? AppColors.input : AppColors.border,
            ),
            labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: selectedText == value
                  ? AppColors.foreground
                  : AppColors.secondaryForeground,
            ),
          ),
      ],
    );
  }
}

class _DeltaChipRow extends StatelessWidget {
  const _DeltaChipRow({required this.onDelta});

  final ValueChanged<double> onDelta;

  @override
  Widget build(BuildContext context) {
    const deltas = <(String, double)>[
      ('-1', -1),
      ('-0.5', -0.5),
      ('+0.5', 0.5),
      ('+1', 1),
    ];

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final entry in deltas)
          ActionChip(
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            labelPadding: const EdgeInsets.symmetric(horizontal: 2),
            label: Text(entry.$1),
            onPressed: () => onDelta(entry.$2),
            backgroundColor: AppColors.popover,
            side: const BorderSide(color: AppColors.border),
            labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppColors.secondaryForeground,
            ),
          ),
      ],
    );
  }
}

class _NoteChipRow extends StatelessWidget {
  const _NoteChipRow({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final note in _notePresets)
          FilterChip(
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            labelPadding: const EdgeInsets.symmetric(horizontal: 2),
            label: Text(note),
            selected: selected == note,
            showCheckmark: false,
            onSelected: (_) => onSelected(note),
            backgroundColor: AppColors.popover,
            selectedColor: AppColors.secondary,
            side: BorderSide(
              color: selected == note ? AppColors.input : AppColors.border,
            ),
            labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: selected == note
                  ? AppColors.foreground
                  : AppColors.secondaryForeground,
            ),
          ),
      ],
    );
  }
}

class _RosterSummary extends StatelessWidget {
  const _RosterSummary({
    required this.total,
    required this.completed,
    required this.label,
  });

  final int total;
  final int completed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.users, color: AppColors.primary, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text('$completed/$total $label')),
        ],
      ),
    );
  }
}

class _PreviewSummary extends StatelessWidget {
  const _PreviewSummary({
    required this.health,
    required this.nutrition,
    required this.mode,
  });

  final HealthAssessment? health;
  final NutritionAssessment? nutrition;
  final HealthRosterMode mode;

  @override
  Widget build(BuildContext context) {
    final healthItem = health;
    final nutritionItem = nutrition;
    final text = mode == HealthRosterMode.health
        ? healthItem == null
              ? 'Chưa có dữ liệu sức khỏe'
              : 'BMI ${healthItem.bmi.toStringAsFixed(1)} · ${healthItem.bmiStatus}'
        : nutritionItem == null
        ? 'Chưa có dữ liệu nuôi dưỡng'
        : nutritionItem.statusSummary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyRoster extends StatelessWidget {
  const _EmptyRoster();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: Text(
          'Chưa có học sinh trong lớp này',
          style: TextStyle(color: AppColors.textGray),
        ),
      ),
    );
  }
}

const _periodOptions = [
  AppOption(value: 'dau_nam', label: 'Học kỳ 1 (đầu năm)'),
  AppOption(value: 'giua_ky_1', label: 'Học kỳ 1 (giữa kỳ)'),
  AppOption(value: 'cuoi_ky_1', label: 'Học kỳ 1 (cuối kỳ)'),
  AppOption(value: 'dau_ky_2', label: 'Học kỳ 2 (đầu kỳ)'),
  AppOption(value: 'giua_ky_2', label: 'Học kỳ 2 (giữa kỳ)'),
  AppOption(value: 'cuoi_nam', label: 'Học kỳ 2 (cuối năm)'),
];
