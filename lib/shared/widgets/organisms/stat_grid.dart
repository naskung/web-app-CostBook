import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_sizes.dart';

class StatGrid extends StatelessWidget {
  const StatGrid({super.key, required this.children, this.maxColumns = 3});

  final List<Widget> children;
  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceMedium),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = (constraints.maxWidth / AppSizes.statCardWidth).floor().clamp(1, maxColumns);
          final cardWidth = (constraints.maxWidth - AppSizes.spaceMedium * (columns - 1)) / columns;
          return Wrap(
            spacing: AppSizes.spaceMedium,
            runSpacing: AppSizes.spaceMedium,
            children: [for (final child in children) SizedBox(width: cardWidth, child: child)],
          );
        },
      ),
    );
  }
}
