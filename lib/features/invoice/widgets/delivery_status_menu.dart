import 'package:flutter/material.dart';

import 'package:costbook/core/constants/delivery_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/shared/widgets/atoms/app_badge.dart';

// สถานะการส่งสินค้า: ป้ายสี กดแล้วเลือกสถานะใหม่ (รอส่ง / ส่งสินค้าแล้ว / รับสินค้าแล้ว) — เลือกสถานะเดิม = ไม่ทำอะไร
class DeliveryStatusMenu extends StatelessWidget {
  const DeliveryStatusMenu({super.key, required this.status, required this.onChanged});

  final DeliveryStatus status;
  final ValueChanged<DeliveryStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DeliveryStatus>(
      tooltip: 'delivery.change'.tr,
      initialValue: status,
      onSelected: (selected) {
        if (selected != status) onChanged(selected);
      },
      itemBuilder:
          (context) => [
            for (final option in DeliveryStatus.values)
              PopupMenuItem(
                value: option,
                child: Row(
                  children: [
                    Icon(_icon(option), color: _color(option), size: AppSizes.iconSmall),
                    const SizedBox(width: AppSizes.spaceSmall),
                    Text(option.labelKey.tr),
                  ],
                ),
              ),
          ],
      child: AppBadge(
        text: status.labelKey.tr,
        color: _color(status),
        backgroundColor: _backgroundColor(status),
        trailingIcon: Icons.expand_more,
      ),
    );
  }

  IconData _icon(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return Icons.inventory_2_outlined;
      case DeliveryStatus.shipped:
        return Icons.local_shipping_outlined;
      case DeliveryStatus.received:
        return Icons.check_circle_outline;
    }
  }

  Color _color(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return AppColors.primaryDark;
      case DeliveryStatus.shipped:
        return AppColors.info;
      case DeliveryStatus.received:
        return AppColors.success;
    }
  }

  Color _backgroundColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return AppColors.primarySoft;
      case DeliveryStatus.shipped:
        return AppColors.infoSoft;
      case DeliveryStatus.received:
        return AppColors.successSoft;
    }
  }
}
