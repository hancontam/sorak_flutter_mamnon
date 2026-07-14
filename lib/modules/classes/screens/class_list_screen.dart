import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_options.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/text_normalizer.dart';
import '../../../core/utils/student_enrollment.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/academic_year_app_bar_selector.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/confirm_archive_dialog.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/sorak_avatar.dart';
import '../../academic_years/providers/active_academic_year_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../class_transfers/providers/class_transfer_provider.dart';
import '../../incoming_transfers/providers/incoming_transfer_provider.dart';
import '../../outgoing_transfers/providers/outgoing_transfer_provider.dart';
import '../../students/models/student.dart';
import '../../students/providers/student_provider.dart';
import '../models/school_class.dart';
import '../providers/class_provider.dart';
import 'class_form_screen.dart';

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  String? _selectedAgeGroup;
  int? _lastAcademicYearId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadForSelectedYear());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadForSelectedYear() async {
    final yearId = context.read<ActiveAcademicYearProvider>().selectedYearId;
    if (yearId == null) {
      await Future.wait([
        context.read<ClassProvider>().loadItems(),
        context.read<StudentProvider>().loadItems(),
        context.read<ClassTransferProvider>().loadItems(),
        context.read<IncomingTransferProvider>().loadItems(),
        context.read<OutgoingTransferProvider>().loadItems(),
      ]);
      return;
    }
    await Future.wait([
      context.read<ClassProvider>().loadForAcademicYear(yearId),
      context.read<StudentProvider>().loadForAcademicYear(yearId),
      context.read<ClassTransferProvider>().loadForAcademicYear(yearId),
      context.read<IncomingTransferProvider>().loadForAcademicYear(yearId),
      context.read<OutgoingTransferProvider>().loadForAcademicYear(yearId),
    ]);
  }

  void _openForm([SchoolClass? schoolClass]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClassFormScreen(schoolClass: schoolClass),
      ),
    );
  }

  void _openClassDetail(SchoolClass schoolClass) {
    final allStudents = context.read<StudentProvider>().items;
    final students =
        allStudents
            .where(
              (student) =>
                  student.classId == schoolClass.id &&
                  isStudentCurrentlyEnrolled(student),
            )
            .toList()
          ..sort(
            (a, b) => normalizeVietnamese(
              a.fullName,
            ).compareTo(normalizeVietnamese(b.fullName)),
          );
    final history = _movementHistory(schoolClass, allStudents);

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
      builder: (_) => _ClassDetailSheet(
        schoolClass: schoolClass,
        students: students,
        history: history,
      ),
    );
  }

  List<_ClassMovementEvent> _movementHistory(
    SchoolClass schoolClass,
    List<Student> allStudents,
  ) {
    final result = <_ClassMovementEvent>[];
    Student? findStudent(int id) {
      for (final student in allStudents) {
        if (student.id == id) return student;
      }
      return null;
    }

    for (final student in allStudents.where(
      (item) =>
          item.classId == schoolClass.id && !isStudentCurrentlyEnrolled(item),
    )) {
      result.add(
        _ClassMovementEvent(
          key: 'status-${student.id}',
          student: student,
          title: student.studentStatus,
          date: student.currentEnrollmentLeftDate,
        ),
      );
    }

    for (final transfer in context.read<ClassTransferProvider>().items) {
      if (transfer.appliedAt.isEmpty ||
          (transfer.fromClassId != schoolClass.id &&
              transfer.toClassId != schoolClass.id)) {
        continue;
      }
      final student = findStudent(transfer.studentId);
      result.add(
        _ClassMovementEvent(
          key: 'class-${transfer.id}',
          student: student,
          fallbackName: transfer.studentName,
          title: transfer.fromClassId == schoolClass.id
              ? 'Đã chuyển sang ${transfer.toClassName}'
              : 'Chuyển đến từ ${transfer.fromClassName}',
          date: transfer.effectiveDate,
        ),
      );
    }

    final today = DateTime.now();
    bool isEffective(String value) {
      final date = DateTime.tryParse(value);
      return date == null || !date.isAfter(today);
    }

    for (final transfer in context.read<OutgoingTransferProvider>().items) {
      if (transfer.className != schoolClass.className ||
          transfer.status.toLowerCase() != 'recorded' ||
          !isEffective(transfer.transferDate)) {
        continue;
      }
      result.add(
        _ClassMovementEvent(
          key: 'outgoing-${transfer.id}',
          student: findStudent(transfer.studentId),
          fallbackName: transfer.studentName,
          title: 'Đã chuyển trường đi',
          date: transfer.transferDate,
        ),
      );
    }

    for (final transfer in context.read<IncomingTransferProvider>().items) {
      if (transfer.className != schoolClass.className ||
          transfer.status.toLowerCase() != 'recorded' ||
          !isEffective(transfer.transferDate)) {
        continue;
      }
      result.add(
        _ClassMovementEvent(
          key: 'incoming-${transfer.id}',
          student: findStudent(transfer.studentId),
          fallbackName: transfer.studentName,
          title: 'Chuyển trường đến',
          date: transfer.transferDate,
        ),
      );
    }

    final explicitStudentIds = result
        .where((event) => !event.key.startsWith('status-'))
        .map((event) => event.student?.id)
        .whereType<int>()
        .toSet();
    final unique = <String, _ClassMovementEvent>{};
    for (final event in result.where(
      (item) =>
          !item.key.startsWith('status-') ||
          !explicitStudentIds.contains(item.student?.id),
    )) {
      unique[event.key] = event;
    }
    final events = unique.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return events;
  }

  List<SchoolClass> _filteredClasses(List<SchoolClass> classes) {
    final query = normalizeVietnamese(_search);

    return classes.where((schoolClass) {
      if (_selectedAgeGroup != null &&
          _normalizedAgeGroup(schoolClass.ageGroup) != _selectedAgeGroup) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return normalizeVietnamese(
        [
          schoolClass.className,
          schoolClass.ageGroup,
          schoolClass.room,
          schoolClass.teacherName,
        ].join(' '),
      ).contains(query);
    }).toList();
  }

  List<_ClassGroupData> _groupedClasses(List<SchoolClass> classes) {
    final groups = <String, List<SchoolClass>>{};
    for (final schoolClass in classes) {
      final group = _displayAgeGroup(schoolClass.ageGroup);
      groups.putIfAbsent(group, () => []).add(schoolClass);
    }

    final sortedNames = groups.keys.toList()
      ..sort((a, b) => _ageGroupRank(a).compareTo(_ageGroupRank(b)));
    return [
      for (final name in sortedNames)
        _ClassGroupData(name: name, classes: groups[name]!),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final yearId = context.watch<ActiveAcademicYearProvider>().selectedYearId;
    if (yearId != _lastAcademicYearId) {
      _lastAcademicYearId = yearId;
      _selectedAgeGroup = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadForSelectedYear();
      });
    }

    final provider = context.watch<ClassProvider>();
    final isPrincipal =
        context.watch<AuthProvider>().currentUser?.role.toUpperCase() ==
        'PRINCIPAL';
    final ageGroupOptions = _ageGroupOptions(
      provider.items,
      isPrincipal: isPrincipal,
    );
    _resetInvalidAgeGroupFilter(ageGroupOptions, provider.isLoading);
    final classes = _filteredClasses(provider.items);
    final groups = _groupedClasses(classes);

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Lớp học'),
              actions: [
                const AcademicYearAppBarSelector(),
                IconButton(
                  tooltip: 'Làm mới',
                  onPressed: provider.isLoading ? null : _loadForSelectedYear,
                  icon: const Icon(LucideIcons.refreshCcw, size: 20),
                ),
              ],
            )
          : null,
      floatingActionButton: isPrincipal
          ? FloatingActionButton(
              key: const ValueKey('module_add_button'),
              tooltip: 'Thêm lớp học',
              onPressed: () => _openForm(),
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
              hintText: 'Tìm tên lớp / phòng / giáo viên',
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
              key: ValueKey('class_grade_filter_${_selectedAgeGroup ?? ''}'),
              label: 'Lọc theo khối',
              showLabel: false,
              options: ageGroupOptions,
              value: _selectedAgeGroup ?? '',
              hintText: 'Tất cả khối',
              onChanged: (value) => setState(() {
                _selectedAgeGroup = value == null || value.isEmpty
                    ? null
                    : value;
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (provider.isLoading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: _buildContent(
              context,
              provider,
              classes,
              groups,
              isPrincipal,
            ),
          ),
        ],
      ),
    );
  }

  List<AppOption<String>> _ageGroupOptions(
    List<SchoolClass> classes, {
    required bool isPrincipal,
  }) {
    if (isPrincipal) {
      return const [
        AppOption(value: '', label: 'Tất cả khối'),
        ...GradeOptions.all,
      ];
    }

    final assignedAgeGroups = classes
        .map((schoolClass) => _normalizedAgeGroup(schoolClass.ageGroup))
        .where((value) => value.isNotEmpty)
        .toSet();
    return [
      const AppOption(value: '', label: 'Tất cả khối'),
      ...GradeOptions.all.where(
        (option) => assignedAgeGroups.contains(option.value),
      ),
    ];
  }

  void _resetInvalidAgeGroupFilter(
    List<AppOption<String>> options,
    bool isLoading,
  ) {
    final selected = _selectedAgeGroup;
    if (isLoading ||
        selected == null ||
        options.any((option) => option.value == selected)) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _selectedAgeGroup != null) {
        setState(() => _selectedAgeGroup = null);
      }
    });
  }

  Widget _buildContent(
    BuildContext context,
    ClassProvider provider,
    List<SchoolClass> classes,
    List<_ClassGroupData> groups,
    bool isPrincipal,
  ) {
    if (provider.isLoading && provider.items.isEmpty) {
      return const LoadingView();
    }
    if (provider.errorMessage != null && provider.items.isEmpty) {
      return ErrorView(
        message: provider.errorMessage!,
        onRetry: _loadForSelectedYear,
      );
    }
    if (provider.items.isEmpty) {
      return EmptyView(
        title: 'Chưa có lớp học',
        message: 'Chưa có dữ liệu trong năm học đang chọn.',
        actionLabel: isPrincipal ? 'Thêm lớp học' : null,
        onAction: isPrincipal ? () => _openForm() : null,
      );
    }
    if (classes.isEmpty) {
      return EmptyView(
        title: 'Không tìm thấy lớp học',
        message: 'Thử tên lớp, phòng, giáo viên hoặc đổi khối.',
        type: EmptyViewType.search,
        actionLabel: 'Xóa bộ lọc',
        onAction: () {
          _searchController.clear();
          setState(() {
            _search = '';
            _selectedAgeGroup = null;
          });
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadForSelectedYear,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          96,
        ),
        itemCount: groups.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
        itemBuilder: (context, groupIndex) {
          final group = groups[groupIndex];
          return _ClassFolderGroup(
            group: group,
            canManage: isPrincipal,
            onDetail: _openClassDetail,
            onEdit: _openForm,
            onArchive: _archiveClass,
          );
        },
      ),
    );
  }

  Future<void> _archiveClass(SchoolClass schoolClass) async {
    final confirmed = await showConfirmArchiveDialog(
      context: context,
      title: 'Xóa lớp học?',
      message:
          'Lớp học sẽ được ẩn khỏi danh sách đang hoạt động và không bị xóa vĩnh viễn.',
    );
    if (!confirmed || !mounted) {
      return;
    }
    await context.read<ClassProvider>().archiveItem(schoolClass.id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa lớp học khỏi danh sách')),
    );
  }
}

class _ClassGroupData {
  const _ClassGroupData({required this.name, required this.classes});

  final String name;
  final List<SchoolClass> classes;
}

class _ClassFolderGroup extends StatelessWidget {
  const _ClassFolderGroup({
    required this.group,
    required this.canManage,
    required this.onDetail,
    required this.onEdit,
    required this.onArchive,
  });

  final _ClassGroupData group;
  final bool canManage;
  final ValueChanged<SchoolClass> onDetail;
  final ValueChanged<SchoolClass> onEdit;
  final ValueChanged<SchoolClass> onArchive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.folder, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                group.name == 'Chưa phân khối'
                    ? group.name
                    : 'Khối ${group.name}',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '${group.classes.length} lớp',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (var index = 0; index < group.classes.length; index++) ...[
          _ClassCard(
            key: ValueKey('class_card_${group.classes[index].id}'),
            schoolClass: group.classes[index],
            grade: group.name,
            canManage: canManage,
            onTap: () => onDetail(group.classes[index]),
            onEdit: () => onEdit(group.classes[index]),
            onArchive: () => onArchive(group.classes[index]),
          ),
          if (index != group.classes.length - 1)
            const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({
    super.key,
    required this.schoolClass,
    required this.grade,
    required this.canManage,
    required this.onTap,
    required this.onEdit,
    required this.onArchive,
  });

  final SchoolClass schoolClass;
  final String grade;
  final bool canManage;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final currentStudentCount = context
        .watch<StudentProvider>()
        .items
        .where(
          (student) =>
              student.classId == schoolClass.id &&
              isStudentCurrentlyEnrolled(student),
        )
        .length;
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
                  SorakAvatar(
                    seed: 'class-${schoolClass.id}',
                    fallbackLabel: schoolClass.className,
                    diceBearStyle: 'pixel-art-neutral',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _valueOrMissing(schoolClass.className),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        _ClassGradePill(label: grade),
                      ],
                    ),
                  ),
                  if (canManage)
                    PopupMenuButton<_ClassAction>(
                      tooltip: 'Thao tác với lớp học',
                      icon: const Icon(LucideIcons.ellipsisVertical, size: 20),
                      onSelected: (action) {
                        if (action == _ClassAction.edit) {
                          onEdit();
                        } else {
                          onArchive();
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: _ClassAction.edit,
                          child: Text('Chỉnh sửa'),
                        ),
                        PopupMenuItem(
                          value: _ClassAction.archive,
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
                    _ClassInfoLine(label: 'Khối', value: grade),
                    _ClassInfoLine(label: 'Phòng', value: schoolClass.room),
                    _ClassInfoLine(
                      label: 'Sĩ số',
                      value: '$currentStudentCount trẻ',
                    ),
                    _ClassInfoLine(
                      label: 'Giáo viên',
                      value: schoolClass.teacherName,
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

class _ClassDetailSheet extends StatelessWidget {
  const _ClassDetailSheet({
    required this.schoolClass,
    required this.students,
    required this.history,
  });

  final SchoolClass schoolClass;
  final List<Student> students;
  final List<_ClassMovementEvent> history;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.55,
      maxChildSize: 0.95,
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
                    seed: 'class-${schoolClass.id}',
                    fallbackLabel: schoolClass.className,
                    diceBearStyle: 'pixel-art-neutral',
                    size: 52,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _valueOrMissing(schoolClass.className),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _displayAgeGroup(schoolClass.ageGroup),
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
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                children: [
                  Text(
                    'Chi tiết lớp học',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          _ClassInfoLine(
                            label: 'Tên lớp',
                            value: schoolClass.className,
                          ),
                          _ClassInfoLine(
                            label: 'Khối',
                            value: _displayAgeGroup(schoolClass.ageGroup),
                          ),
                          _ClassInfoLine(
                            label: 'Phòng học',
                            value: schoolClass.room,
                          ),
                          _ClassInfoLine(
                            label: 'Sĩ số',
                            value: '${students.length} trẻ',
                          ),
                          _ClassInfoLine(
                            label: 'Giáo viên phụ trách',
                            value: schoolClass.teacherName,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Học sinh trong lớp',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        '${students.length} học sinh',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (students.isEmpty)
                    const EmptyView(
                      title: 'Chưa có học sinh',
                      message: 'Lớp học này chưa có học sinh đang theo học.',
                      type: EmptyViewType.data,
                    )
                  else
                    for (var index = 0; index < students.length; index++) ...[
                      _ClassStudentCard(
                        index: index + 1,
                        student: students[index],
                      ),
                      if (index < students.length - 1)
                        const SizedBox(height: AppSpacing.sm),
                    ],
                  if (history.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: ExpansionTile(
                        key: const ValueKey('class_movement_history'),
                        initiallyExpanded: false,
                        leading: const Icon(
                          LucideIcons.folderClock,
                          color: AppColors.primary,
                        ),
                        title: const Text('Lịch sử biến động'),
                        subtitle: Text('${history.length} lượt chuyển'),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          AppSpacing.sm,
                          0,
                          AppSpacing.sm,
                          AppSpacing.sm,
                        ),
                        children: [
                          for (var index = 0; index < history.length; index++)
                            _MovementHistoryCard(event: history[index]),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ClassMovementEvent {
  const _ClassMovementEvent({
    required this.key,
    required this.title,
    required this.date,
    this.student,
    this.fallbackName = '',
  });

  final String key;
  final Student? student;
  final String fallbackName;
  final String title;
  final String date;
}

class _MovementHistoryCard extends StatelessWidget {
  const _MovementHistoryCard({required this.event});

  final _ClassMovementEvent event;

  @override
  Widget build(BuildContext context) {
    final name = event.student?.fullName ?? event.fallbackName;
    final code = event.student?.studentIdCardNumber ?? '';
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            SorakAvatar(
              seed: event.student?.id ?? event.key,
              fallbackLabel: name,
              size: 40,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _valueOrMissing(name),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (code.isNotEmpty)
                    Text(
                      code,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (event.date.isNotEmpty)
              Text(
                _formatDate(event.date),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ClassStudentCard extends StatelessWidget {
  const _ClassStudentCard({required this.index, required this.student});

  final int index;
  final Student student;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '$index.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SorakAvatar(
              seed: student.id,
              fallbackLabel: student.fullName,
              size: 40,
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _valueOrMissing(student.studentIdCardNumber),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Text(
              student.studentStatus,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.secondaryForeground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ClassAction { edit, archive }

class _ClassGradePill extends StatelessWidget {
  const _ClassGradePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.secondaryForeground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ClassInfoLine extends StatelessWidget {
  const _ClassInfoLine({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final isMissing = _isMissingValue(value);

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

String _normalizedAgeGroup(String value) {
  return switch (value.trim().toLowerCase()) {
    'nhà trẻ' || 'nha tre' => GradeOptions.nursery,
    '3-4' || 'mầm' || 'mam' => GradeOptions.mam,
    '4-5' || 'chồi' || 'choi' => GradeOptions.choi,
    '5-6' || 'lá' || 'la' => GradeOptions.la,
    _ => value.trim(),
  };
}

String _displayAgeGroup(String value) {
  final normalized = _normalizedAgeGroup(value);
  return normalized.isEmpty ? 'Chưa phân khối' : normalized;
}

int _ageGroupRank(String value) {
  return switch (value) {
    GradeOptions.nursery => 0,
    GradeOptions.mam => 1,
    GradeOptions.choi => 2,
    GradeOptions.la => 3,
    'Chưa phân khối' => 4,
    _ => 5,
  };
}

String _valueOrMissing(String? value) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty || trimmed == '-' ? 'Chưa có' : trimmed;
}

bool _isMissingValue(String? value) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty || trimmed == '-';
}

String _formatDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  final day = parsed.day.toString().padLeft(2, '0');
  final month = parsed.month.toString().padLeft(2, '0');
  return '$day/$month/${parsed.year}';
}
