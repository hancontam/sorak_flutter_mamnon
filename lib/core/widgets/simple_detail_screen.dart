import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class DetailRow {
  const DetailRow({
    required this.label,
    required this.value,
    this.icon = LucideIcons.info,
  });

  final String label;
  final String value;
  final IconData icon;
}

class SimpleDetailScreen extends StatelessWidget {
  const SimpleDetailScreen({
    super.key,
    required this.title,
    required this.rows,
  });

  final String title;
  final List<DetailRow> rows;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    foregroundColor: AppColors.primary,
                    child: const Icon(LucideIcons.fileText, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final row in rows) ...[
            Card(
              child: ListTile(
                leading: Icon(row.icon, color: AppColors.primary),
                title: Text(
                  row.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    row.value.isEmpty ? '-' : row.value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}
