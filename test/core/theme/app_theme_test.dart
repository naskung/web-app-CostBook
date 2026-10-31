import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('ตัวอักษรใช้ฟอนต์ LINESeedSansTH', () {
      expect(AppTheme.light.textTheme.bodyMedium?.fontFamily, 'LINESeedSansTH');
    });

    test('ชื่อฟอนต์ตรงกับที่ลงทะเบียนใน pubspec.yaml', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('family: ${AppTheme.fontFamily}'));
    });

    test('ขนาดตัวอักษรทั่วไปมาจาก AppSizes.fontBody', () {
      expect(AppTheme.light.textTheme.bodyMedium?.fontSize, AppSizes.fontBody);
    });

    test('สีหลักมาจาก AppColors.primary', () {
      expect(AppTheme.light.colorScheme.primary, AppColors.primary);
    });
  });
}
