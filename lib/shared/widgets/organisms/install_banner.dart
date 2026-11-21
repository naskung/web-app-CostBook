import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';

class InstallBanner extends StatelessWidget {
  const InstallBanner({super.key, required this.onAdd, required this.onDismiss});

  final VoidCallback onAdd;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: AppSizes.spaceMedium,
        top: AppSizes.spaceXSmall,
        bottom: AppSizes.spaceXSmall,
      ),
      decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppSizes.radius)),
      child: Row(
        children: [
          const Icon(Icons.install_mobile_outlined, color: AppColors.primary),
          const SizedBox(width: AppSizes.spaceSmall),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSizes.spaceSmall,
              children: [
                Text('install.banner'.tr, style: Theme.of(context).textTheme.bodyMedium),
                TextButton(onPressed: onAdd, child: Text('install.add'.tr)),
              ],
            ),
          ),
          IconButton(tooltip: 'install.dismiss'.tr, onPressed: onDismiss, icon: const Icon(Icons.close)),
        ],
      ),
    );
  }
}
