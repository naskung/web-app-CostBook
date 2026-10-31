import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';

class AppTheme {
  static const String fontFamily = 'LINESeedSansTH';

  static final ThemeData light = ThemeData(
    fontFamily: fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
      outlineVariant: AppColors.border,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: _textTheme,
  );

  static const TextTheme _textTheme = TextTheme(
    headlineSmall: TextStyle(fontSize: AppSizes.fontHeading, fontWeight: FontWeight.bold),
    titleLarge: TextStyle(fontSize: AppSizes.fontTitle, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(fontSize: AppSizes.fontLarge, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: AppSizes.fontLarge),
    bodyMedium: TextStyle(fontSize: AppSizes.fontBody),
    bodySmall: TextStyle(fontSize: AppSizes.fontSmall, color: AppColors.textSecondary),
    labelLarge: TextStyle(fontSize: AppSizes.fontBody, fontWeight: FontWeight.bold),
  );
}
