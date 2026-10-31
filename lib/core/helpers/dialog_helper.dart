import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';

class DialogHelper {
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text('common.cancel'.tr)),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                child: Text(confirmText),
              ),
            ],
          ),
    );
    return result ?? false;
  }
}
