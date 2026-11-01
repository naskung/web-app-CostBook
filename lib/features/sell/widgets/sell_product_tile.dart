import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/money_util.dart';

// การ์ดสินค้าในหน้าขาย: อยู่ในบิลแล้ว → ขอบส้ม + วงกลมบอกจำนวนที่มุมรูป
class SellProductTile extends StatelessWidget {
  const SellProductTile({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    required this.stockText,
    required this.width,
    required this.isOut,
    required this.onTap,
    this.quantityInCart = 0,
  });

  final Widget image;
  final String name;
  final double price;
  final String stockText;
  final double width;
  final bool isOut;
  final VoidCallback onTap;
  final int quantityInCart;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isInCart = quantityInCart > 0;
    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radius),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.spaceMedium),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radius),
              border: Border.all(
                color: isInCart ? AppColors.primary : AppColors.border,
                width: isInCart ? AppSizes.focusBorderWidth : AppSizes.borderWidth,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    image,
                    if (isInCart) Positioned(top: 0, right: 0, child: _QuantityBadge(quantity: quantityInCart)),
                  ],
                ),
                const SizedBox(height: AppSizes.spaceSmall),
                // จองที่ชื่อไว้ 2 บรรทัดเสมอ (ข้อความว่าง 2 บรรทัดซ้อนอยู่ข้างหลัง) → ชื่อสั้น / ยาว การ์ดก็สูงเท่ากัน
                Stack(
                  children: [
                    ExcludeSemantics(child: Text('\n', style: textTheme.titleSmall)),
                    Text(name, style: textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
                const SizedBox(height: AppSizes.spaceSmall),
                Text(MoneyUtil.format(price), style: textTheme.titleMedium?.copyWith(color: AppColors.primaryDark)),
                Text(stockText, style: textTheme.bodySmall?.copyWith(color: isOut ? AppColors.danger : null)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantityBadge extends StatelessWidget {
  const _QuantityBadge({required this.quantity});

  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: AppSizes.sellQuantityBadge, minHeight: AppSizes.sellQuantityBadge),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceXSmall),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppSizes.radiusLarge)),
      child: Text(
        '$quantity',
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.bold),
      ),
    );
  }
}
