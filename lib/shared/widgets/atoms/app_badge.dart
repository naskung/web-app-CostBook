import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_sizes.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.text, required this.color, required this.backgroundColor});

  final String text;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.badgePaddingX, vertical: AppSizes.badgePaddingY),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(AppSizes.radiusLarge)),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
    );
  }
}
