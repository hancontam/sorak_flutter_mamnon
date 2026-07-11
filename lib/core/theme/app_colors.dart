import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color background = Color(0xFFFAF9F5);
  static const Color card = Color(0xFFFAF9F5);
  static const Color foreground = Color(0xFF3D3929);
  static const Color cardForeground = Color(0xFF141413);
  static const Color primary = Color(0xFFC96442);
  static const Color ring = Color(0xFFC96442);
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFFE9E6DC);
  static const Color accent = Color(0xFFE9E6DC);
  static const Color secondaryForeground = Color(0xFF535146);
  static const Color muted = Color(0xFFEDE9DE);
  static const Color mutedForeground = Color(0xFF83827D);
  static const Color border = Color(0xFFDAD9D4);
  static const Color input = Color(0xFFB4B2A7);
  static const Color popover = Color(0xFFFFFFFF);
  static const Color drawer = Color(0xFFF5F4EE);
  static const Color chart1 = Color(0xFFB05730);
  static const Color chart2 = Color(0xFF9C87F5);
  static const Color chartNeutral = Color(0xFFDED8C4);
  static const Color destructive = Color(0xFF141413);

  static const Color textDark = foreground;
  static const Color textGray = mutedForeground;
  static const Color surface = card;

  // Compatibility aliases. Semantic state colors still stay inside Claude.
  static const Color success = secondary;
  static const Color warning = chartNeutral;
  static const Color error = destructive;

  static const Color statusSuccessText = foreground;
  static const Color statusSuccessBackground = secondary;
  static const Color statusSuccessBorder = input;
  static const Color statusWarningText = chart1;
  static const Color statusWarningBackground = chartNeutral;
  static const Color statusWarningBorder = primary;
  static const Color statusErrorText = primaryForeground;
  static const Color statusErrorBackground = destructive;
  static const Color statusErrorBorder = destructive;
  static const Color statusNeutralText = secondaryForeground;
  static const Color statusNeutralBackground = muted;
  static const Color statusNeutralBorder = border;
}
