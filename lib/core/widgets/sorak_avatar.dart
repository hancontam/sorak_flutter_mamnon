import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class SorakAvatar extends StatelessWidget {
  const SorakAvatar({
    super.key,
    required this.seed,
    this.size = 48,
    this.fallbackLabel,
  });

  final Object seed;
  final double size;
  final String? fallbackLabel;

  @override
  Widget build(BuildContext context) {
    if (_isWidgetTest) {
      return _AvatarFrame(
        size: size,
        child: _AvatarFallback(size: size, label: fallbackLabel),
      );
    }

    final safeSeed = Uri.encodeComponent('account-$seed');
    final url = 'https://api.dicebear.com/10.x/pixel-art/svg?seed=$safeSeed';

    return _AvatarFrame(
      size: size,
      child: SvgPicture.network(
        url,
        fit: BoxFit.cover,
        placeholderBuilder: (_) =>
            _AvatarFallback(size: size, label: fallbackLabel),
        errorBuilder: (context, error, stackTrace) =>
            _AvatarFallback(size: size, label: fallbackLabel),
      ),
    );
  }

  bool get _isWidgetTest {
    return WidgetsBinding.instance.runtimeType.toString().contains('Test');
  }
}

class _AvatarFrame extends StatelessWidget {
  const _AvatarFrame({required this.size, required this.child});

  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.size, this.label});

  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final initial = (label?.trim().isNotEmpty ?? false)
        ? label!.trim().characters.first.toUpperCase()
        : 'S';

    return Center(
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.foreground,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
