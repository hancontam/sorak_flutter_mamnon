import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../modules/academic_years/models/academic_year.dart';
import '../../modules/academic_years/providers/active_academic_year_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AcademicYearAccordion extends StatefulWidget {
  const AcademicYearAccordion({super.key});

  @override
  State<AcademicYearAccordion> createState() => _AcademicYearAccordionState();
}

class _AcademicYearAccordionState extends State<AcademicYearAccordion> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<ActiveAcademicYearProvider>().loadYears();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveAcademicYearProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.years.isEmpty) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: LinearProgressIndicator(minHeight: 2),
          );
        }

        if (provider.years.isEmpty) {
          return const SizedBox.shrink();
        }

        final selectedYear = _selectedYear(provider);

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                KeyedSubtree(
                  key: const ValueKey('active_year_dropdown'),
                  child: InkWell(
                    key: const ValueKey('active_year_accordion_trigger'),
                    borderRadius: BorderRadius.circular(AppSpacing.radius),
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.calendarDays,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Năm học đang chọn',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: AppColors.mutedForeground,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  selectedYear?.name ?? 'Chọn năm học',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                          AnimatedRotation(
                            turns: _expanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(
                              LucideIcons.chevronDown,
                              size: 20,
                              color: AppColors.secondaryForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: _expanded
                      ? Column(
                          children: [
                            const Divider(),
                            for (final year in provider.years)
                              _AcademicYearRow(
                                year: year,
                                selected: year.id == provider.selectedYearId,
                                onTap: () async {
                                  await provider.selectYear(year.id);
                                  if (mounted) {
                                    setState(() => _expanded = false);
                                  }
                                },
                              ),
                          ],
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  AcademicYear? _selectedYear(ActiveAcademicYearProvider provider) {
    for (final year in provider.years) {
      if (year.id == provider.selectedYearId) {
        return year;
      }
    }
    return null;
  }
}

class _AcademicYearRow extends StatelessWidget {
  const _AcademicYearRow({
    required this.year,
    required this.selected,
    required this.onTap,
  });

  final AcademicYear year;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('academic_year_option_${year.id}'),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        color: selected ? AppColors.secondary : Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                year.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.foreground,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Radio-style: empty circle / circle with primary inner dot.
            // No status badge on year filter rows.
            _YearSelectIndicator(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _YearSelectIndicator extends StatelessWidget {
  const _YearSelectIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.mutedForeground,
            width: 1.5,
          ),
        ),
        child: selected
            ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
