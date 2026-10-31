import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';

/// ธีมของแอป: รวมฟอนต์ สี และขนาดตัวอักษรจาก AppColors / AppSizes
/// widget ใช้ตัวอักษรผ่าน textTheme ห้ามใส่ fontSize เอง เช่น
/// Text('product.title'.tr, style: Theme.of(context).textTheme.headlineSmall)
class AppTheme {
  static const String fontFamily = 'LINESeedSansTH'; // ต้องตรงกับ family ใน pubspec.yaml

  static final ThemeData light = ThemeData(
    fontFamily: fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary, // สีตัวอักษรเริ่มต้นของทุก Text
      error: AppColors.danger,
      outlineVariant: AppColors.border, // เส้นแบ่ง / ขอบการ์ด
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: _textTheme,
  );

  static const TextTheme _textTheme = TextTheme(
    headlineSmall: TextStyle(fontSize: AppSizes.fontHeading, fontWeight: FontWeight.bold), // หัวข้อหน้า
    titleLarge: TextStyle(fontSize: AppSizes.fontTitle, fontWeight: FontWeight.bold), // หัวข้อการ์ด / ส่วน
    titleMedium: TextStyle(fontSize: AppSizes.fontLarge, fontWeight: FontWeight.bold), // หัวข้อย่อย
    bodyLarge: TextStyle(fontSize: AppSizes.fontLarge), // ข้อความเด่น
    bodyMedium: TextStyle(fontSize: AppSizes.fontBody), // ข้อความทั่วไป (ค่าเริ่มต้นของ Text)
    bodySmall: TextStyle(fontSize: AppSizes.fontSmall, color: AppColors.textSecondary), // คำอธิบาย
    labelLarge: TextStyle(fontSize: AppSizes.fontBody, fontWeight: FontWeight.bold), // ตัวอักษรบนปุ่ม
  );
}
