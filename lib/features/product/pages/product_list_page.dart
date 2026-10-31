import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/shared/widgets/molecules/coming_soon_view.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ComingSoonView(
      title: 'common.coming_soon'.tr,
      description: 'product.description'.tr,
    );
  }
}
