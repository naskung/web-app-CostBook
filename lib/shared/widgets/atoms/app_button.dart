import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_sizes.dart';

class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.text, required this.onPressed, this.isLoading = false});

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: isLoading ? null : onPressed, child: _label());
  }

  Widget _label() {
    if (!isLoading) return Text(text);
    return const SizedBox.square(
      dimension: AppSizes.loadingSize,
      child: CircularProgressIndicator(strokeWidth: AppSizes.loadingStroke),
    );
  }
}
