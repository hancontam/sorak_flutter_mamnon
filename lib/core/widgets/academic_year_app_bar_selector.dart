import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../modules/academic_years/providers/active_academic_year_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AcademicYearAppBarSelector extends StatefulWidget {
  const AcademicYearAppBarSelector({super.key});

  @override
  State<AcademicYearAppBarSelector> createState() =>
      _AcademicYearAppBarSelectorState();
}

class _AcademicYearAppBarSelectorState
    extends State<AcademicYearAppBarSelector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ActiveAcademicYearProvider>().loadYears();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveAcademicYearProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.years.isEmpty) {
          return const SizedBox(
            width: 40,
            height: 40,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        if (provider.years.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.xs),
          child: PopupMenuButton<int>(
            key: const ValueKey('active_year_dropdown'),
            tooltip: 'Chọn năm học',
            initialValue: provider.selectedYearId,
            onSelected: provider.selectYear,
            itemBuilder: (context) => [
              for (final year in provider.years)
                PopupMenuItem<int>(
                  key: ValueKey('academic_year_option_${year.id}'),
                  value: year.id,
                  child: Row(
                    children: [
                      Expanded(child: Text(year.name)),
                      if (year.id == provider.selectedYearId)
                        const Icon(
                          LucideIcons.check,
                          size: 18,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ),
            ],
            child: Container(
              key: const ValueKey('active_year_selector_surface'),
              width: 140,
              constraints: const BoxConstraints(minHeight: 36),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(AppSpacing.radius),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.calendarDays,
                    size: 15,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      provider.selectedYear?.name ?? 'Năm học',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.secondaryForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(LucideIcons.chevronDown, size: 14),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
