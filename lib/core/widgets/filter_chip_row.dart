import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class FilterChipRow extends StatelessWidget {
  const FilterChipRow({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
  });

  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      key: const ValueKey('module_filter_chip_row'),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          FilterChip(
            key: const ValueKey('filter_chip_all'),
            label: const Text('All'),
            selected: selectedOption == null,
            onSelected: (_) => onSelected(null),
          ),
          const SizedBox(width: AppSpacing.xs),
          for (final option in options) ...[
            FilterChip(
              key: ValueKey('filter_chip_$option'),
              label: Text(option),
              selected: selectedOption == option,
              onSelected: (_) => onSelected(option),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}
