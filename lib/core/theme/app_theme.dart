import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.montserratTextTheme().apply(
      bodyColor: AppColors.foreground,
      displayColor: AppColors.foreground,
    );

    final colorScheme = const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      secondary: AppColors.secondary,
      onSecondary: AppColors.secondaryForeground,
      error: AppColors.destructive,
      onError: AppColors.primaryForeground,
      surface: AppColors.background,
      onSurface: AppColors.foreground,
      outline: AppColors.border,
      outlineVariant: AppColors.input,
    );

    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radius),
    );

    final bordered = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      side: const BorderSide(color: AppColors.border),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      fontFamily: GoogleFonts.montserrat().fontFamily,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.foreground,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.card,
        margin: EdgeInsets.zero,
        shape: bordered,
        surfaceTintColor: Colors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          disabledBackgroundColor: AppColors.muted,
          disabledForegroundColor: AppColors.mutedForeground,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: rounded,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.foreground,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: AppColors.input),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: rounded,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.foreground,
          minimumSize: const Size(48, 48),
          shape: rounded,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.foreground,
          minimumSize: const Size(48, 48),
          shape: rounded,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radius)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: AppColors.background,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? AppColors.primary : AppColors.mutedForeground,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: 0,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primary : AppColors.mutedForeground,
            size: selected ? 24 : 22,
          );
        }),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: AppColors.drawer,
        indicatorColor: AppColors.secondary,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.bodyMedium?.copyWith(
            color: selected
                ? AppColors.foreground
                : AppColors.secondaryForeground,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        labelStyle: const TextStyle(color: AppColors.secondaryForeground),
        hintStyle: const TextStyle(color: AppColors.mutedForeground),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          borderSide: const BorderSide(color: AppColors.input),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          borderSide: const BorderSide(color: AppColors.input),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          borderSide: const BorderSide(color: AppColors.ring, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          borderSide: const BorderSide(color: AppColors.destructive),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          borderSide: const BorderSide(
            color: AppColors.destructive,
            width: 1.4,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.muted,
        selectedColor: AppColors.secondary,
        disabledColor: AppColors.muted,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.secondaryForeground,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.foreground,
          fontWeight: FontWeight.w700,
        ),
        side: const BorderSide(color: AppColors.border),
        shape: rounded,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.popover,
        surfaceTintColor: Colors.transparent,
        shape: rounded,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.foreground,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.secondaryForeground,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.popover,
        surfaceTintColor: Colors.transparent,
        shape: rounded,
        textStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.destructive,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.primaryForeground,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: rounded,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.muted,
      ),
    );
  }
}
