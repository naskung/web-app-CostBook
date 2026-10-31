import 'package:flutter/material.dart';

import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/core/theme/app_colors.dart';

class ShopLogo extends StatelessWidget {
  const ShopLogo({super.key, required this.size, required this.radius});

  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        ApiConstants.companyLogoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _defaultLogo(),
      ),
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
