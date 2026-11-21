import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/features/invoice/models/invoice_draft_model.dart';
import 'package:costbook/features/invoice/widgets/invoice_item_row.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/shared/widgets/atoms/app_dropdown.dart';
import 'package:costbook/shared/widgets/molecules/empty_view.dart';

class DraftItemsEditor extends StatelessWidget {
  const DraftItemsEditor({
    super.key,
    required this.products,
    required this.items,
    required this.selectedProductId,
    required this.onAdd,
    required this.onChanged,
    required this.onRemove,
    this.showStock = true,
  });

  final List<ProductModel> products;
  final List<InvoiceDraftItemModel> items;
  final String? selectedProductId;
  final ValueChanged<String?> onAdd;
  final void Function(String productId, int quantity, double unitPrice) onChanged;
  final ValueChanged<String> onRemove;
  final bool showStock;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppDropdown<String>(
          label: 'invoice.add_item'.tr,
          hint: 'invoice.choose_product'.tr,
          value: selectedProductId,
          items: {
            for (final product in products) product.id: '${product.name}  ·  ${MoneyUtil.format(product.sellPrice)}',
          },
          onChanged: onAdd,
        ),
        const SizedBox(height: AppSizes.spaceMedium),
        if (items.isEmpty) EmptyView(message: 'invoice.items_empty'.tr, icon: Icons.add_shopping_cart),
        for (final item in items)
          InvoiceItemRow(
            key: ValueKey(item.productId),
            item: item,
            showStock: showStock,
            onChanged: (quantity, unitPrice) => onChanged(item.productId, quantity, unitPrice),
            onRemove: () => onRemove(item.productId),
          ),
      ],
    );
  }
}
