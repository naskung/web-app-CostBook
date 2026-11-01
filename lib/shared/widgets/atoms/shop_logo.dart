import 'package:flutter/material.dart';

import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/core/theme/app_colors.dart';

class ShopLogo extends StatelessWidget {
  const ShopLogo({super.key, required this.size, required this.radius});

  final double size;
  final double radius;

  // เปลี่ยน / ลบโลโก้แล้วเรียก ShopLogo.refresh() → โลโก้ทุกที่ (เมนู / หน้า login / ใบกำกับ) โหลดรูปใหม่
  // (URL เปลี่ยนตาม version ไม่งั้น Flutter ใช้รูปเก่าที่จำไว้)
  static final ValueNotifier<int> _version = ValueNotifier(0);

  static void refresh() => _version.value++;

  static String urlOf(int version) => '${ApiConstants.companyLogoUrl}?v=$version';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _version,
      builder: (context, version, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Image.network(
            urlOf(version),
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _defaultLogo(),
          ),
        );
      },
    );
  }

  Widget _defaultLogo() {
    return Container(
      width: size,
      height: size,
      color: AppColors.primary,
      child: Icon(Icons.menu_book_rounded, color: AppColors.onPrimary, size: size / 2),
    );
  }
}
