import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/shared/widgets/molecules/coming_soon_view.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ComingSoonView(
      title: 'dashboard.welcome'.tr,
      description: 'dashboard.description'.tr,
    );
  }
}
