import 'package:flutter/material.dart';

import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/shared/widgets/atoms/app_image_box.dart';

// รูปสินค้า (โหลดจาก API พร้อม token) ไม่มีรูป = กล่องเทาไอคอนสินค้า
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.product, this.width, this.height});

  final ProductModel product;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return AppImageBox(
      url: product.imageUrl,
      headers: ApiClient.authHeaders,
      width: width,
      height: height,
      placeholderIcon: Icons.inventory_2_outlined,
    );
  }
}
