import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_sizes.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.text,
    required this.color,
    required this.backgroundColor,
    this.trailingIcon,
  });

  final String text;
  final Color color;
  final Color backgroundColor;
  // ไอคอนท้ายป้าย เช่น ลูกศรบอกว่ากดเปลี่ยนได้
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.bold),
    );
    final icon = trailingIcon;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.badgePaddingX, vertical: AppSizes.badgePaddingY),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(AppSizes.radiusLarge)),
      child:
          icon == null
              ? label
              : Row(
                mainAxisSize: MainAxisSize.min,
                children: [Flexible(child: label), Icon(icon, size: AppSizes.badgeIcon, color: color)],
              ),
    );
  }
}
