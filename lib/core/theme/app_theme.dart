import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';

class AppTheme {
  static const String fontFamily = 'LINESeedSansTH';

  static const BoxShadow cardShadow = BoxShadow(
    color: AppColors.shadow,
    blurRadius: AppSizes.shadowBlur,
    offset: Offset(0, AppSizes.shadowOffsetY),
  );

  static final ThemeData light = ThemeData(
    fontFamily: fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      error: AppColors.danger,
      outlineVariant: AppColors.border,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: _textTheme,
    elevatedButtonTheme: _buttonTheme,
    inputDecorationTheme: _inputTheme,
  );

  static const TextTheme _textTheme = TextTheme(
    headlineSmall: TextStyle(fontSize: AppSizes.fontHeading, fontWeight: FontWeight.bold),
    titleLarge: TextStyle(fontSize: AppSizes.fontTitle, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(fontSize: AppSizes.fontLarge, fontWeight: FontWeight.bold),
    titleSmall: TextStyle(fontSize: AppSizes.fontBody, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: AppSizes.fontLarge),
    bodyMedium: TextStyle(fontSize: AppSizes.fontBody),
    bodySmall: TextStyle(fontSize: AppSizes.fontSmall, color: AppColors.textSecondary),
    labelLarge: TextStyle(fontSize: AppSizes.fontLarge, fontWeight: FontWeight.bold),
  );

  static final ElevatedButtonThemeData _buttonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      minimumSize: const Size(0, AppSizes.buttonHeight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radius)),
    ),
  );

  static final InputDecorationTheme _inputTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.inputFill,
    contentPadding: const EdgeInsets.all(AppSizes.spaceMedium),
    enabledBorder: _inputBorder(AppColors.inputBorder, AppSizes.borderWidth),
    focusedBorder: _inputBorder(AppColors.primary, AppSizes.focusBorderWidth),
    errorBorder: _inputBorder(AppColors.danger, AppSizes.borderWidth),
    focusedErrorBorder: _inputBorder(AppColors.danger, AppSizes.focusBorderWidth),
  );

  static OutlineInputBorder _inputBorder(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
