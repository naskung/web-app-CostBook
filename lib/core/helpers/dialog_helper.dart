import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/shared/widgets/organisms/app_alert_dialog.dart';

class DialogHelper {
  // ถามยืนยันก่อนทำสิ่งที่ย้อนกลับไม่ได้ (ลบ / ยกเลิก) → true = กดยืนยัน
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    IconData icon = Icons.delete_outline,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AppAlertDialog(
            icon: icon,
            title: title,
            message: message,
            primaryText: confirmText,
            onPrimary: () => Navigator.pop(dialogContext, true),
            secondaryText: 'common.cancel'.tr,
            onSecondary: () => Navigator.pop(dialogContext, false),
          ),
    );
    return result ?? false;
  }
}
