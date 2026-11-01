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
    elevatedButtonTheme: ElevatedButtonThemeData(style: _primaryStyle),
    filledButtonTheme: FilledButtonThemeData(style: _primaryStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: _secondaryStyle),
    textButtonTheme: TextButtonThemeData(style: _textStyle),
    iconButtonTheme: _iconButtonTheme,
    segmentedButtonTheme: _segmentedTheme,
    chipTheme: _chipTheme,
    switchTheme: _switchTheme,
    inputDecorationTheme: _inputTheme,
    appBarTheme: _appBarTheme,
    dialogTheme: _dialogTheme,
    datePickerTheme: _datePickerTheme,
    popupMenuTheme: _popupMenuTheme,
  );

  static const RoundedRectangleBorder _dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppSizes.dialogRadius)),
  );

  // dialog พื้นขาว ไม่ย้อมสีส้มตามธีม + ฉากหลังมืดลงชัด ๆ
  static const DialogThemeData _dialogTheme = DialogThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: AppColors.transparent,
    barrierColor: AppColors.scrim,
    shape: _dialogShape,
  );

  // เมนู ⋮ พื้นขาว มีขอบ ไม่ย้อมสีส้มตามธีม
  static const PopupMenuThemeData _popupMenuTheme = PopupMenuThemeData(
    color: AppColors.surface,
    surfaceTintColor: AppColors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.radius)),
      side: BorderSide(color: AppColors.border),
    ),
  );

  static const DatePickerThemeData _datePickerTheme = DatePickerThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: AppColors.transparent,
    shape: _dialogShape,
  );

  static const AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    shape: Border(bottom: BorderSide(color: AppColors.border)),
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

  // ---------- ปุ่ม: ทุกแบบใช้มุมโค้งเท่ากัน (เท่าช่องกรอก) สูงเท่ากัน ตัวหนังสือแบบเดียวกัน ----------
  // desktop / เว็บ Flutter ย่อปุ่มเองอัตโนมัติ (compact) → ใช้ขนาดปกติ ปุ่มจะสูงเท่ากันทุกจอ

  static const OutlinedBorder _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppSizes.radius)),
  );

  static const TextStyle _buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: AppSizes.fontButton,
    fontWeight: FontWeight.bold,
  );

  // ชี้เมาส์ → ปุ่มลอยขึ้นนิดหน่อย / กด → ยุบลง
  static final WidgetStateProperty<double> _hoverLift = WidgetStateProperty.resolveWith(
    (states) =>
        states.contains(WidgetState.hovered) && !states.contains(WidgetState.pressed)
            ? AppSizes.buttonHoverElevation
            : 0,
  );

  // ปุ่มหลัก: พื้นส้ม ตัวหนังสือเข้ม (ใช้ทั้ง FilledButton และ ElevatedButton ใน AppButton)
  static final ButtonStyle _primaryStyle = FilledButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.onPrimary,
    shadowColor: AppColors.shadow,
    minimumSize: const Size(0, AppSizes.buttonHeight),
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.buttonPaddingX),
    iconSize: AppSizes.iconSmall,
    shape: _buttonShape,
    textStyle: _buttonText,
    visualDensity: VisualDensity.standard,
  ).copyWith(elevation: _hoverLift);

  // ปุ่มรอง: พื้นขาว ขอบเทาอ่อน ตัวหนังสือเข้ม ไอคอนส้ม
  static final ButtonStyle _secondaryStyle = OutlinedButton.styleFrom(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    iconColor: AppColors.primary,
    shadowColor: AppColors.shadow,
    side: const BorderSide(color: AppColors.inputBorder),
    minimumSize: const Size(0, AppSizes.buttonHeight),
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.buttonPaddingX),
    iconSize: AppSizes.iconSmall,
    shape: _buttonShape,
    textStyle: _buttonText,
    visualDensity: VisualDensity.standard,
  ).copyWith(elevation: _hoverLift);

  // ปุ่มตัวหนังสือ (ดูทั้งหมด / ลบรูป): ส้มเข้ม ชี้เมาส์มีพื้นส้มอ่อน
  static final ButtonStyle _textStyle = TextButton.styleFrom(
    foregroundColor: AppColors.primaryDark,
    minimumSize: const Size(0, AppSizes.textButtonHeight),
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceMedium),
    iconSize: AppSizes.iconSmall,
    shape: _buttonShape,
    textStyle: _buttonText,
    visualDensity: VisualDensity.standard,
  );

  // ปุ่มไอคอน (แก้ / ลบ ในตาราง): สี่เหลี่ยมมุมโค้ง แทนวงกลม
  static final IconButtonThemeData _iconButtonTheme = IconButtonThemeData(
    style: IconButton.styleFrom(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusSmall))),
    ),
  );

  // ปุ่มเลือกทีละแบบ (ทั้งหมด / สินค้าขาย / วัสดุ): ที่เลือกอยู่ = พื้นส้มอ่อน ตัวหนังสือส้มเข้ม (แบบเดียวกับ chip)
  static final SegmentedButtonThemeData _segmentedTheme = SegmentedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.primarySoft : AppColors.surface,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.primaryDark : AppColors.textSecondary,
      ),
      side: const WidgetStatePropertyAll(BorderSide(color: AppColors.inputBorder)),
      shape: const WidgetStatePropertyAll(_buttonShape),
      textStyle: const WidgetStatePropertyAll(_buttonText),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: AppSizes.spaceMedium)),
      // SegmentedButton ไม่ส่ง minimumSize ต่อให้ปุ่มย่อย (สูง 40 ตามค่าของ Flutter) → ขยายด้วย density: 40 + 2 × 4 = 48 เท่าปุ่มอื่น
      visualDensity: const VisualDensity(vertical: 2),
    ),
  );

  // ตัวกรอง (หมวด / เฉพาะใกล้หมด): ทรงแคปซูล ไม่มีเครื่องหมายถูก ที่เลือกอยู่ = ขอบส้ม พื้นส้มอ่อน
  static final ChipThemeData _chipTheme = ChipThemeData(
    backgroundColor: AppColors.surface,
    selectedColor: AppColors.primarySoft,
    showCheckmark: false,
    shape: const StadiumBorder(),
    side: WidgetStateBorderSide.resolveWith(
      (states) => BorderSide(color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.inputBorder),
    ),
    labelStyle: TextStyle(
      fontFamily: fontFamily,
      fontSize: AppSizes.fontBody,
      fontWeight: FontWeight.bold,
      color: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.primaryDark : AppColors.textSecondary,
      ),
    ),
    iconTheme: const IconThemeData(size: AppSizes.chipIconSize),
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceSmall, vertical: AppSizes.spaceSmall),
  );

  // สวิตช์เปิด / ปิด: ปุ่มกลมสีขาว รางส้ม (เปิด) / เทา (ปิด) ไม่มีขอบ
  static final SwitchThemeData _switchTheme = SwitchThemeData(
    thumbColor: const WidgetStatePropertyAll(AppColors.surface),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) return AppColors.border;
      return states.contains(WidgetState.selected) ? AppColors.primary : AppColors.inputBorder;
    }),
    trackOutlineColor: const WidgetStatePropertyAll(AppColors.transparent),
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
