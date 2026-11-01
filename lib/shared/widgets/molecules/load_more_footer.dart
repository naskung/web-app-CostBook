import 'package:flutter/material.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/theme/app_sizes.dart';

// ท้ายรายการที่โหลดทีละหน้า: กำลังโหลดเพิ่ม = วงกลมหมุน / โหลดเพิ่มไม่สำเร็จ = ปุ่มลองใหม่ / อื่น ๆ = ไม่มีอะไร
class LoadMoreFooter extends StatelessWidget {
  const LoadMoreFooter({super.key, required this.status, required this.retryLabel, required this.onRetry});

  final AppStatus status;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (status == AppStatus.loading) {
      return const Padding(
        padding: EdgeInsets.all(AppSizes.spaceMedium),
        child: Center(
          child: SizedBox.square(
            dimension: AppSizes.loadingSize,
            child: CircularProgressIndicator(strokeWidth: AppSizes.loadingStroke),
          ),
        ),
      );
    }
    if (status == AppStatus.failure) {
      return Padding(
        padding: const EdgeInsets.all(AppSizes.spaceSmall),
        child: Center(
          child: TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: Text(retryLabel)),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
