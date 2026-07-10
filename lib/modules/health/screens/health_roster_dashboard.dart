import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_options.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_date_field.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../academic_years/providers/active_academic_year_provider.dart';
import '../../classes/models/school_class.dart';
import '../../form_options/providers/form_options_provider.dart';
import '../../students/models/student.dart';
import '../models/health_assessment.dart';
import '../models/nutrition_assessment.dart';
import '../providers/health_assessment_provider.dart';
import '../providers/nutrition_assessment_provider.dart';

enum HealthRosterMode { health, nutrition }

class HealthRosterDashboard extends StatefulWidget {
  const HealthRosterDashboard({super.key, required this.mode});

  final HealthRosterMode mode;

  @override
  State<HealthRosterDashboard> createState() => _HealthRosterDashboardState();
}

class _HealthRosterDashboardState extends State<HealthRosterDashboard> {
  final TextEditingController _dateController = TextEditingController();
  String? _selectedClassId;
  String _selectedPeriod = 'dau_nam';
  bool _isReloadingRoster = false;

  bool get _isHealth => widget.mode == HealthRosterMode.health;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toIso8601String().substring(0, 10);
    _dateController.addListener(_onDateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FormOptionsProvider>().loadInitialOptions();
      _reloadRoster();
    });
  }

  @override
  void dispose() {
    _dateController.removeListener(_onDateChanged);
    _dateController.dispose();
    super.dispose();
  }

  void _onDateChanged() {
    if (_isHealth) {
      _reloadRoster();
    }
  }

  Future<void> _reloadRoster() async {
    if (!mounted || _isReloadingRoster) {
      return;
    }

    final classId = int.tryParse(_selectedClassId ?? '');
    if (classId == null) {
      return;
    }

    setState(() => _isReloadingRoster = true);
    try {
      if (_isHealth) {
        await context.read<HealthAssessmentProvider>().loadByClassDate(
          classId: classId,
          assessmentDate: _dateController.text.trim(),
        );
      } else {
        final yearId = context
            .read<ActiveAcademicYearProvider>()
            .selectedYearId;
        if (yearId == null) {
          return;
        }
        await context.read<NutritionAssessmentProvider>().loadGrid(
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

    _applyDefaultClass(optionsProvider);

    final students = _studentsForClass(optionsProvider);
    final isLoading =
        optionsProvider.isLoading ||
        healthProvider.isLoading ||
        nutritionProvider.isLoading ||
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
            options: _classOptions(optionsProvider.classes),
            value: _selectedClassId,
            hintText: 'Chọn lớp',
            onChanged: (value) {
              setState(() => _selectedClassId = value);
              context.read<FormOptionsProvider>().selectClass(
                int.tryParse(value ?? ''),
              );
              _reloadRoster();
            },
          ),
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
          if (!_isHealth && yearId == null) ...[
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Chưa chọn năm học — không thể tải lưới nuôi dưỡng.',
              style: TextStyle(color: AppColors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _RosterSummary(
            total: students.length,
            completed: _completedCount(
              students,
              healthProvider.items,
              nutritionProvider.items,
            ),
            label: _isHealth ? 'đã đo hôm nay' : 'đã đánh giá',
          ),
          const SizedBox(height: AppSpacing.sm),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (errorMessage != null && students.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
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
            )
          else if (students.isEmpty)
            const _EmptyRoster()
          else
            for (final student in students) ...[
              _StudentRosterCard(
                student: student,
                mode: widget.mode,
                health: _latestHealth(student.id, healthProvider.items),
                nutrition: _latestNutrition(
                  student.id,
                  nutritionProvider.items,
                ),
                onTap: () => _openStudentPreview(
                  context,
                  student,
                  healthProvider.items,
                  nutritionProvider.items,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
        ],
      ),
    );
  }

  void _applyDefaultClass(FormOptionsProvider optionsProvider) {
    if (_selectedClassId != null || optionsProvider.classes.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _selectedClassId != null ||
          optionsProvider.classes.isEmpty) {
        return;
      }
      setState(() => _selectedClassId = '${optionsProvider.classes.first.id}');
      context.read<FormOptionsProvider>().selectClass(
        optionsProvider.classes.first.id,
      );
      _reloadRoster();
    });
  }

  List<Student> _studentsForClass(FormOptionsProvider optionsProvider) {
    final classId = int.tryParse(_selectedClassId ?? '');
    return optionsProvider.allStudents.where((student) {
      return classId == null || student.classId == classId;
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
    final matches = items.where((item) => item.studentId == studentId).toList();
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
    BuildContext context,
    Student student,
    List<HealthAssessment> healthItems,
    List<NutritionAssessment> nutritionItems,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return _StudentPreviewSheet(
          mode: widget.mode,
          student: student,
          selectedDate: _dateController.text,
          selectedPeriod: _selectedPeriod,
          history: healthItems
              .where((item) => item.studentId == student.id)
              .toList(),
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

class _StudentRosterCard extends StatelessWidget {
  const _StudentRosterCard({
    required this.student,
    required this.mode,
    required this.health,
    required this.nutrition,
    required this.onTap,
  });

  final Student student;
  final HealthRosterMode mode;
  final HealthAssessment? health;
  final NutritionAssessment? nutrition;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isHealth = mode == HealthRosterMode.health;
    final healthItem = health;
    final nutritionItem = nutrition;
    final subtitle = isHealth
        ? healthItem == null
              ? 'Chưa có số đo'
              : '${healthItem.heightCm.toStringAsFixed(0)} cm · ${healthItem.weightKg.toStringAsFixed(1)} kg · ${healthItem.bmiStatus}'
        : nutritionItem == null
        ? 'Chưa có đánh giá'
        : '${nutritionItem.statusSummary} · BMI ${nutritionItem.latestBmi.toStringAsFixed(1)}';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.accent.withValues(alpha: 0.18),
          child: Text(student.fullName.characters.first),
        ),
        title: Text(student.fullName),
        subtitle: Text('${student.className} · $subtitle'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _StudentPreviewSheet extends StatefulWidget {
  const _StudentPreviewSheet({
    required this.mode,
    required this.student,
    required this.selectedDate,
    required this.selectedPeriod,
    required this.history,
    required this.nutritionHistory,
  });

  final HealthRosterMode mode;
  final Student student;
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

  bool get _isHealth => widget.mode == HealthRosterMode.health;

  @override
  void initState() {
    super.initState();
    final latestHealth = _latestHealth;
    _heightController.text = latestHealth?.heightCm.toString() ?? '';
    _weightController.text = latestHealth?.weightKg.toString() ?? '';
    _noteController.text = _isHealth
        ? latestHealth?.note ?? ''
        : _latestNutrition?.note ?? '';
    _weightChannel = _latestNutrition?.weightChannel.isEmpty == false
        ? _latestNutrition!.weightChannel
        : NutritionOptions.weightNormal;
    _isStunting = _latestNutrition?.isStunting ?? false;
    _isSevereStunting = _latestNutrition?.isSevereStunting ?? false;
    _isObese = _latestNutrition?.isObese ?? false;
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Keyboard + system safe-area bottom so Save stays reachable.
    final bottomPad =
        media.viewInsets.bottom + media.padding.bottom + AppSpacing.md;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: bottomPad,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.student.fullName,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              widget.student.className,
              style: const TextStyle(color: AppColors.textGray),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _isHealth ? 'Preview sức khỏe' : 'Preview nuôi dưỡng',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            _PreviewSummary(
              health: _latestHealth,
              nutrition: _latestNutrition,
              mode: widget.mode,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Lịch sử gần đây',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            if (_isHealth)
              for (final item in widget.history.take(3))
                Text(
                  '${item.assessmentDate.substring(0, 10)} · ${item.heightCm} cm · ${item.weightKg} kg',
                )
            else
              for (final item in widget.nutritionHistory.take(3))
                Text('${item.period} · ${item.statusSummary}'),
            const SizedBox(height: AppSpacing.md),
            Text(
              _isHealth ? 'Nhập nhanh sức khỏe' : 'Nhập nhanh nuôi dưỡng',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_isHealth) ...[
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _heightController,
                      label: 'Chiều cao (cm)',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextField(
                      controller: _weightController,
                      label: 'Cân nặng (kg)',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              AppDropdownField<String>(
                key: ValueKey('nutrition_channel_$_weightChannel'),
                label: 'Kênh tăng trưởng cân nặng',
                options: NutritionOptions.weightChannels,
                value: _weightChannel,
                onChanged: (value) {
                  setState(() {
                    _weightChannel = value ?? NutritionOptions.weightNormal;
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
                  setState(() => _isSevereStunting = value ?? false);
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
            ],
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _noteController,
              label: 'Ghi chú',
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('health_roster_save_button'),
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isHealth ? 'Lưu sức khỏe' : 'Lưu nuôi dưỡng'),
              ),
            ),
          ],
        ),
      ),
    );
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

    final classId = widget.student.classId;
    final ok = _isHealth
        ? await healthProvider.bulkSaveRoster(
            schoolYearId: schoolYearId,
            classId: classId,
            assessmentDate: widget.selectedDate,
            rows: [
              {
                'student_id': widget.student.id,
                'height_cm': _heightController.text.trim(),
                'weight_kg': _weightController.text.trim(),
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
                'weight_channel': _weightChannel == NutritionOptions.weightNormal
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
          const Icon(Icons.groups_outlined, color: AppColors.primary),
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
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Text(text),
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
