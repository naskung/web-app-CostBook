import 'package:flutter/material.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';

class BarcodeLookupNote extends StatelessWidget {
  const BarcodeLookupNote({super.key, required this.status, this.errorCode = ''});

  final AppStatus status;
  final String errorCode;

  @override
  Widget build(BuildContext context) {
    if (status == AppStatus.initial) return const SizedBox.shrink();
    final textStyle = Theme.of(context).textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.spaceXSmall),
      child: Row(
        children: [
          _icon(),
          const SizedBox(width: AppSizes.spaceSmall),
          Expanded(child: Text(_message(), style: textStyle?.copyWith(color: _color()))),
        ],
      ),
    );
  }

  Widget _icon() {
    if (status == AppStatus.loading) {
      return const SizedBox(
        width: AppSizes.iconSmall,
        height: AppSizes.iconSmall,
        child: CircularProgressIndicator(strokeWidth: AppSizes.loadingStroke),
      );
    }
    if (status == AppStatus.success) return Icon(Icons.check_circle_outline, size: AppSizes.iconSmall, color: _color());
    return Icon(Icons.info_outline, size: AppSizes.iconSmall, color: _color());
  }

  String _message() {
    if (status == AppStatus.loading) return 'product.barcode_searching'.tr;
    if (status == AppStatus.success) return 'product.barcode_found'.tr;
    return 'error.$errorCode'.tr;
  }

  Color _color() {
    if (status == AppStatus.success) return AppColors.success;
    return AppColors.textSecondary;
  }
}
