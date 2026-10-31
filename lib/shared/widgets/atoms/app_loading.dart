import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_sizes.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.spaceXLarge),
        child: CircularProgressIndicator(),
      ),
    );
  }
}
