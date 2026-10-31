import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_sizes.dart';

class PageToolbar extends StatelessWidget {
  const PageToolbar({super.key, required this.children, this.actions = const []});

  final List<Widget> children;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceMedium),
      child: Wrap(
        spacing: AppSizes.spaceMedium,
        runSpacing: AppSizes.spaceMedium,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Wrap(
            spacing: AppSizes.spaceMedium,
            runSpacing: AppSizes.spaceMedium,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children,
          ),
          Wrap(spacing: AppSizes.spaceSmall, runSpacing: AppSizes.spaceSmall, children: actions),
        ],
      ),
    );
  }
}
