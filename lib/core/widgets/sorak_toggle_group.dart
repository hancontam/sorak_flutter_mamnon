import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class SorakToggleOption<T> {
  const SorakToggleOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

class SorakToggleGroup<T> extends StatelessWidget {
  const SorakToggleGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final List<SorakToggleOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasFiniteWidth = constraints.hasBoundedWidth;

        return Semantics(
          container: true,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              mainAxisSize: hasFiniteWidth
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              children: [
                for (var index = 0; index < options.length; index++) ...[
                  if (hasFiniteWidth)
                    Expanded(
                      child: _ToggleButton<T>(
                        option: options[index],
                        selected: options[index].value == selected,
                        enabled: enabled,
                        onPressed: () => onChanged(options[index].value),
                      ),
                    )
                  else
                    _ToggleButton<T>(
                      option: options[index],
                      selected: options[index].value == selected,
                      enabled: enabled,
                      onPressed: () => onChanged(options[index].value),
                    ),
                  if (index != options.length - 1)
                    const SizedBox(
                      height: 48,
                      child: VerticalDivider(width: 1),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ToggleButton<T> extends StatelessWidget {
  const _ToggleButton({
    required this.option,
    required this.selected,
    required this.enabled,
    required this.onPressed,
  });

  final SorakToggleOption<T> option;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // Selected segment uses primary for clear contrast.
    final foreground = selected
        ? AppColors.primaryForeground
        : AppColors.mutedForeground;
    final background = selected ? AppColors.primary : Colors.transparent;

    return Material(
      color: background,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (option.icon != null) ...[
                Icon(option.icon, size: 18, color: foreground),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(
                child: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
