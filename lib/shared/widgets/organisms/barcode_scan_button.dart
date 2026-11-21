import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/shared/widgets/organisms/barcode_scan_dialog.dart';

// ปุ่มสแกนบาร์โค้ด (วางท้ายช่องกรอก) → เปิดกล้อง → อ่านได้รหัส → onScanned / กดปิดกล้อง = ไม่ทำอะไร
class BarcodeScanButton extends StatelessWidget {
  const BarcodeScanButton({super.key, required this.onScanned});

  final ValueChanged<String> onScanned;

  Future<void> _scan(BuildContext context) async {
    final code = await BarcodeScanDialog.show(context);
    if (code == null || code.isEmpty) return;
    onScanned(code);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'barcode.scan'.tr,
      onPressed: () => _scan(context),
      icon: const Icon(Icons.qr_code_scanner),
    );
  }
}
