import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('ตัวอักษรใช้ฟอนต์ LINESeedSansTH', () {
      expect(AppTheme.fontFamily, 'LINESeedSansTH');
      expect(AppTheme.light.textTheme.bodyMedium?.fontFamily, AppTheme.fontFamily);
    });

    test('ชื่อฟอนต์ตรงกับที่ลงทะเบียนใน pubspec.yaml', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('family: ${AppTheme.fontFamily}'));
    });

    test('สีหลักมาจาก AppColors.primary', () {
      expect(AppTheme.light.colorScheme.primary, AppColors.primary);
    });

    test('ขนาดตัวอักษรทั่วไปมาจาก AppSizes.fontBody', () {
      expect(AppTheme.light.textTheme.bodyMedium?.fontSize, AppSizes.fontBody);
    });
  });

  group('AppTheme ปุ่ม', () {
    // จำลองเว็บบนจอคอม: Flutter ย่อปุ่ม (compact) และไม่เผื่อที่กดรอบปุ่ม (shrinkWrap) — ปุ่มยังต้องสูง 48
    final desktopTheme = AppTheme.light.copyWith(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    Future<void> pump(WidgetTester tester, Widget child) {
      return tester.pumpWidget(MaterialApp(theme: desktopTheme, home: Scaffold(body: Center(child: child))));
    }

    testWidgets('ปุ่มหลัก / ปุ่มรอง / ปุ่มใน AppButton สูงเท่าช่องกรอก (48)', (tester) async {
      await pump(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(onPressed: () {}, child: const Text('เพิ่ม')),
            OutlinedButton(onPressed: () {}, child: const Text('รับเข้า')),
            ElevatedButton(onPressed: () {}, child: const Text('บันทึก')),
          ],
        ),
      );
      expect(tester.getSize(find.byType(FilledButton)).height, AppSizes.buttonHeight);
      expect(tester.getSize(find.byType(OutlinedButton)).height, AppSizes.buttonHeight);
      expect(tester.getSize(find.byType(ElevatedButton)).height, AppSizes.buttonHeight);
    });

    testWidgets('ปุ่มเลือกทีละแบบ (SegmentedButton) สูงเท่าปุ่มอื่น', (tester) async {
      await pump(
        tester,
        SegmentedButton<String>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 'a', label: Text('ทั้งหมด')),
            ButtonSegment(value: 'b', label: Text('วัสดุ')),
          ],
          selected: const {'a'},
          onSelectionChanged: (_) {},
        ),
      );
      expect(tester.getSize(find.byType(TextButton).first).height, AppSizes.buttonHeight);
    });
  });
}
