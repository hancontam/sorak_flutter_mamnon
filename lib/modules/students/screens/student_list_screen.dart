import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_options.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/text_normalizer.dart';
import '../../../core/utils/ui_labels.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/confirm_archive_dialog.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/sorak_avatar.dart';
import '../../academic_years/providers/active_academic_year_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../classes/models/school_class.dart';
import '../../classes/providers/class_provider.dart';
import '../../form_options/providers/form_options_provider.dart';
import '../models/student.dart';
import '../providers/student_provider.dart';
import 'student_detail_screen.dart';
import 'student_form_screen.dart';
import 'student_guardian_form_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  String? _selectedClassId;
  int? _lastAcademicYearId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FormOptionsProvider>().loadInitialOptions();
      _loadStudentsForCurrentYear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentsForCurrentYear() async {
    final yearId = context.read<ActiveAcademicYearProvider>().selectedYearId;
    if (yearId == null) {
      await Future.wait([
        context.read<StudentProvider>().loadItems(),
        context.read<ClassProvider>().loadItems(),
      ]);
      return;
    }
    await Future.wait([
      context.read<StudentProvider>().loadForAcademicYear(yearId),
      context.read<ClassProvider>().loadForAcademicYear(yearId),
    ]);
  }

  void _openStudentForm([Student? student]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StudentFormScreen(student: student)),
    );
  }

  void _openGuardianForm(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentGuardianFormScreen(student: student),
      ),
    );
  }

  void _openDetail(Student student, String grade) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentDetailScreen(
          student: student,
          grade: grade,
          onEditStudent: () => _openStudentForm(student),
          onEditGuardian: () => _openGuardianForm(student),
        ),
      ),
    );
  }

  List<Student> _filteredStudents(List<Student> items) {
    final query = normalizeVietnamese(_search);
    final classId = int.tryParse(_selectedClassId ?? '');

    return items.where((student) {
      if (classId != null && student.classId != classId) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return normalizeVietnamese(
        [
          student.fullName,
          student.studentIdCardNumber,
          student.className,
          '${student.id}',
        ].join(' '),
      ).contains(query);
    }).toList();
  }

  List<AppOption<String>> _classOptions(List<SchoolClass> classes) {
    return [
      const AppOption(value: '', label: 'Tất cả lớp'),
      ...classes.map(
        (schoolClass) => AppOption(
          value: '${schoolClass.id}',
          label: schoolClass.room.isEmpty
              ? schoolClass.className
              : '${schoolClass.className} - ${schoolClass.room}',
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final yearId = context.watch<ActiveAcademicYearProvider>().selectedYearId;
    if (yearId != _lastAcademicYearId) {
      _lastAcademicYearId = yearId;
      _selectedClassId = null;
    }

    final isPrincipal =
        context.watch<AuthProvider>().currentUser?.role.toUpperCase() ==
        'PRINCIPAL';
    final options = context.watch<FormOptionsProvider>();
    final provider = context.watch<StudentProvider>();
    final classProvider = context.watch<ClassProvider>();
    final filterClasses = isPrincipal ? options.classes : classProvider.items;
    final isClassFilterLoading = isPrincipal
        ? options.isLoading
        : classProvider.isLoading;
    _resetInvalidClassFilter(filterClasses, isLoading: isClassFilterLoading);
    final students = _filteredStudents(provider.items);
    final isLoading =
        provider.isLoading || options.isLoading || isClassFilterLoading;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Học sinh'),
              actions: [
                IconButton(
                  tooltip: 'Làm mới',
                  onPressed: isLoading ? null : _loadStudentsForCurrentYear,
                  icon: const Icon(LucideIcons.refreshCcw, size: 20),
                ),
              ],
            )
          : null,
      floatingActionButton: isPrincipal
          ? FloatingActionButton(
              key: const ValueKey('module_add_button'),
              tooltip: 'Thêm học sinh',
              onPressed: () => _openStudentForm(),
              child: const Icon(LucideIcons.plus),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              0,
            ),
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Tìm tên / mã thẻ',
              onChanged: (value) => setState(() => _search = value),
              onClear: () {
                _searchController.clear();
                setState(() => _search = '');
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: AppDropdownField<String>(
              key: ValueKey('student_class_filter_${_selectedClassId ?? ''}'),
              label: 'Lọc theo lớp',
              showLabel: false,
              options: _classOptions(filterClasses),
              value: _selectedClassId ?? '',
              hintText: isClassFilterLoading ? 'Đang tải lớp...' : 'Tất cả lớp',
              enabled: !isClassFilterLoading,
              onChanged: (value) => setState(() {
                _selectedClassId = value == null || value.isEmpty
                    ? null
                    : value;
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (isLoading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: _buildContent(
              context,
              provider,
              students,
              filterClasses,
              isPrincipal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    StudentProvider provider,
    List<Student> students,
    List<SchoolClass> classes,
    bool isPrincipal,
  ) {
    if (provider.isLoading && provider.items.isEmpty) {
      return const LoadingView();
    }
    if (provider.errorMessage != null && provider.items.isEmpty) {
      return ErrorView(
        message: provider.errorMessage!,
        onRetry: _loadStudentsForCurrentYear,
      );
    }
    if (provider.items.isEmpty) {
      return EmptyView(
        title: 'Chưa có học sinh',
        message: 'Chưa có dữ liệu trong năm học đang chọn.',
        actionLabel: isPrincipal ? 'Thêm học sinh' : null,
        onAction: isPrincipal ? () => _openStudentForm() : null,
      );
    }
    if (students.isEmpty) {
      return EmptyView(
        title: 'Không tìm thấy học sinh',
        message: 'Thử tên, mã thẻ khác hoặc đổi lớp.',
        type: EmptyViewType.search,
        actionLabel: 'Xóa bộ lọc',
        onAction: () {
          _searchController.clear();
          setState(() {
            _search = '';
            _selectedClassId = null;
          });
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStudentsForCurrentYear,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          96,
        ),
        itemCount: students.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) => _StudentCard(
          key: ValueKey('student_card_${students[index].id}'),
          index: index + 1,
          student: students[index],
          grade: _gradeForStudent(students[index], classes),
          canArchive: isPrincipal,
          onTap: () => _openDetail(
            students[index],
            _gradeForStudent(students[index], classes),
          ),
          onEditStudent: () => _openStudentForm(students[index]),
          onEditGuardian: () => _openGuardianForm(students[index]),
          onArchive: () => _archiveStudent(students[index]),
        ),
      ),
    );
  }

  void _resetInvalidClassFilter(
    List<SchoolClass> classes, {
    required bool isLoading,
  }) {
    final selectedId = int.tryParse(_selectedClassId ?? '');
    if (isLoading ||
        selectedId == null ||
        classes.any((schoolClass) => schoolClass.id == selectedId)) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _selectedClassId != null) {
        setState(() => _selectedClassId = null);
      }
    });
  }

  String _gradeForStudent(Student student, List<SchoolClass> classes) {
    for (final schoolClass in classes) {
      if (schoolClass.id == student.classId) {
        return schoolClass.ageGroup;
      }
    }
    return student.gradeLevel;
  }

  Future<void> _archiveStudent(Student student) async {
    final confirmed = await showConfirmArchiveDialog(
      context: context,
      title: 'Xóa hồ sơ trẻ?',
      message:
          'Hồ sơ trẻ sẽ được ẩn khỏi danh sách đang hoạt động và không bị xóa vĩnh viễn.',
    );
    if (!confirmed || !mounted) {
      return;
    }

    await context.read<StudentProvider>().archiveItem(student.id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa hồ sơ trẻ khỏi danh sách')),
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({
    super.key,
    required this.index,
    required this.student,
    required this.grade,
    required this.canArchive,
    required this.onTap,
    required this.onEditStudent,
    required this.onEditGuardian,
    required this.onArchive,
  });

  final int index;
  final Student student;
  final String grade;
  final bool canArchive;
  final VoidCallback onTap;
  final VoidCallback onEditStudent;
  final VoidCallback onEditGuardian;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
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
                  Text(
                    '$index.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
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
                          _valueOrMissing(student.fullName),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
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
                  PopupMenuButton<_StudentAction>(
                    tooltip: 'Thao tác với học sinh',
                    icon: const Icon(LucideIcons.ellipsisVertical, size: 20),
                    onSelected: (action) {
                      switch (action) {
                        case _StudentAction.editStudent:
                          onEditStudent();
                        case _StudentAction.editGuardian:
                          onEditGuardian();
                        case _StudentAction.archive:
                          onArchive();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: _StudentAction.editStudent,
                        child: Text('Cập nhật trẻ'),
                      ),
                      const PopupMenuItem(
                        value: _StudentAction.editGuardian,
                        child: Text('Cập nhật phụ huynh'),
                      ),
                      if (canArchive)
                        const PopupMenuItem(
                          value: _StudentAction.archive,
                          child: Text(
                            'Xóa',
                            style: TextStyle(color: AppColors.destructive),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _StudentDataPill(label: _valueOrMissing(student.className)),
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
                    _StudentInfoLine(
                      label: 'Ngày sinh',
                      value: _formatDateOnly(student.dateOfBirth),
                    ),
                    _StudentInfoLine(
                      label: 'Giới tính',
                      value: UiLabels.gender(student.gender),
                    ),
                    _StudentInfoLine(label: 'Khối', value: grade),
                    _StudentInfoLine(
                      label: 'Học vụ',
                      value: UiLabels.status(student.studentStatus),
                    ),
                    _StudentInfoLine(
                      label: 'SĐT phụ huynh',
                      value: student.contactPhone,
                    ),
                    _StudentInfoLine(
                      label: 'Ngày nhập học',
                      value: _formatDateOnly(student.enrollmentDate),
                    ),
                    _StudentInfoLine(
                      label: 'Nơi sinh',
                      value: student.birthPlace,
                    ),
                    _StudentInfoLine(
                      label: 'Dân tộc',
                      value: student.ethnicity,
                    ),
                    _StudentInfoLine(
                      label: 'Quốc tịch',
                      value: student.nationality,
                    ),
                    _StudentInfoLine(
                      label: 'Tôn giáo',
                      value: student.religion,
                    ),
                    _StudentInfoLine(
                      label: 'Nhóm máu',
                      value: student.bloodType,
                    ),
                    _StudentInfoLine(
                      label: 'Địa chỉ hiện tại',
                      value: student.currentAddress,
                    ),
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

enum _StudentAction { editStudent, editGuardian, archive }

class _StudentDataPill extends StatelessWidget {
  const _StudentDataPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 130),
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.secondaryForeground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _StudentInfoLine extends StatelessWidget {
  const _StudentInfoLine({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final isMissing = value?.trim().isEmpty ?? true;

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
              _valueOrMissing(value),
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

String _valueOrMissing(String? value) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? 'Chưa có' : trimmed;
}

String _formatDateOnly(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) {
    return '';
  }
  final date = DateTime.tryParse(raw);
  if (date == null) {
    return raw.length >= 10 ? raw.substring(0, 10) : raw;
  }
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
