import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/widgets/product_image.dart';
import 'package:costbook/shared/widgets/atoms/app_badge.dart';

// สินค้า 1 รายการบนมือถือ (แทนแถวตาราง)
// บน: รูป + ชื่อ + ป้ายวัสดุ / รหัส · หมวด + ช่องเพิ่มเติมที่มีค่า + เมนู ⋮
// ล่าง: กล่องเทาอ่อน ต้นทุน | ราคาขาย (เฉพาะสินค้าขาย) | คงเหลือ + ปุ่มรับเข้า / เบิกออก
class ProductMobileCard extends StatelessWidget {
  const ProductMobileCard({
    super.key,
    required this.product,
    required this.menu,
    this.fieldTexts = const [],
    this.onStockMove,
  });

  final ProductModel product;
  final Widget menu;

  // ช่องเพิ่มเติมที่โชว์ในรายการ เฉพาะที่มีค่า เช่น "ยี่ห้อ R3D"
  final List<String> fieldTexts;

  // null = ไม่นับสต็อก (ไม่มีปุ่ม)
  final VoidCallback? onStockMove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spaceMedium,
        AppSizes.spaceMedium,
        AppSizes.spaceSmall,
        AppSizes.spaceMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _top(context),
          const SizedBox(height: AppSizes.spaceSmall + AppSizes.spaceXSmall),
          Padding(padding: const EdgeInsets.only(right: AppSizes.spaceSmall), child: _numbers(context)),
        ],
      ),
    );
  }

  Widget _top(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final details = [product.code, product.category].where((text) => text.isNotEmpty).join(' · ');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductImage(product: product, width: AppSizes.productMobileThumb, height: AppSizes.productMobileThumb),
        const SizedBox(width: AppSizes.spaceSmall + AppSizes.spaceXSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              if (!product.forSale || details.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spaceXSmall),
                Wrap(
                  spacing: AppSizes.spaceSmall,
                  runSpacing: AppSizes.spaceXSmall,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (!product.forSale)
                      AppBadge(
                        text: 'product.kind_material'.tr,
                        color: AppColors.textPrimary,
                        backgroundColor: AppColors.warningSoft,
                      ),
                    if (details.isNotEmpty) Text(details, style: textTheme.bodySmall),
                  ],
                ),
              ],
              if (fieldTexts.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spaceXSmall),
                Text(
                  fieldTexts.join(' · '),
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        menu,
      ],
    );
  }

  // ตัวเลขสำคัญเรียงในกล่องเดียว อ่านง่ายกว่าแบบ หัวข้อ ... ค่า ทีละบรรทัด
  Widget _numbers(BuildContext context) {
    final onMove = onStockMove;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spaceSmall + AppSizes.spaceXSmall,
        AppSizes.spaceSmall,
        AppSizes.spaceXSmall,
        AppSizes.spaceSmall,
      ),
      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppSizes.radius)),
      child: Row(
        children: [
          Expanded(child: _number(context, 'product.table_cost'.tr, MoneyUtil.format(product.costPrice))),
          if (product.forSale)
            Expanded(child: _number(context, 'product.table_price'.tr, MoneyUtil.format(product.sellPrice))),
          Expanded(child: _stock(context)),
          if (onMove != null)
            IconButton(
              tooltip: 'stock.move'.tr,
              onPressed: onMove,
              icon: const Icon(Icons.swap_vert_rounded, color: AppColors.primaryDark),
            ),
        ],
      ),
    );
  }

  Widget _number(BuildContext context, String label, String value, {Color? color}) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodySmall),
        const SizedBox(height: AppSizes.spaceXSmall / 2),
        Text(value, style: textTheme.titleSmall?.copyWith(color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  // คงเหลือ: ใกล้หมด = ตัวเลขสีแดง + ป้าย / ไม่นับสต็อก = บอกว่าไม่นับ
  Widget _stock(BuildContext context) {
    if (!product.trackStock) return _number(context, 'product.stock'.tr, 'product.no_stock'.tr);
    // 1000 → 1,000 อ่านง่ายบนจอเล็ก
    final amount = '${MoneyUtil.formatShort(product.stock.toDouble())} ${product.unit}'.trim();
    if (!product.isLowStock) return _number(context, 'product.stock'.tr, amount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _number(context, 'product.stock'.tr, amount, color: AppColors.danger),
        const SizedBox(height: AppSizes.spaceXSmall),
        AppBadge(text: 'product.low'.tr, color: AppColors.danger, backgroundColor: AppColors.dangerSoft),
      ],
    );
  }
}
