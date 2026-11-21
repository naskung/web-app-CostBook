import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/barcode_util.dart';
import 'package:costbook/shared/widgets/organisms/app_dialog.dart';

// สแกนบาร์โค้ดด้วยกล้อง (มือถือ / iPad / แท็บเล็ต / โน้ตบุ๊กที่มีกล้อง)
// อ่านได้รหัสแรก → ปิดเองแล้วส่งรหัสกลับ / กดปิด = null
// browser ยอมให้ใช้กล้องเฉพาะหน้าที่เปิดผ่าน https หรือ localhost เท่านั้น
class BarcodeScanDialog extends StatefulWidget {
  const BarcodeScanDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(context: context, builder: (_) => const BarcodeScanDialog());
  }

  @override
  State<BarcodeScanDialog> createState() => _BarcodeScanDialogState();
}

class _BarcodeScanDialogState extends State<BarcodeScanDialog> {
  // บาร์โค้ดสินค้าที่ใช้กันทั่วไป + QR — ระบุไว้ให้อ่านเร็วขึ้น / อ่านผิดน้อยลง
  final _controller = MobileScannerController(
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.itf14,
      BarcodeFormat.qrCode,
    ],
  );

  // กล้องส่งผลมาหลายครั้งติดกัน → ปิดหน้าต่างครั้งเดียว
  bool _isDone = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final code = BarcodeUtil.firstCode(capture.barcodes.map((barcode) => barcode.rawValue));
    if (code.isEmpty || _isDone) return;
    _isDone = true;
    Navigator.pop(context, code);
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'barcode.title'.tr,
      subtitle: 'barcode.subtitle'.tr,
      icon: Icons.qr_code_scanner,
      closeLabel: 'common.close'.tr,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          child: ColoredBox(
            color: AppColors.dark,
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: _errorView,
              overlayBuilder: (context, constraints) => _frame(constraints),
            ),
          ),
        ),
      ),
    );
  }

  // กรอบกลางภาพ บอกว่าให้วางบาร์โค้ดตรงไหน
  Widget _frame(BoxConstraints constraints) {
    return Center(
      child: Container(
        width: constraints.maxWidth * 0.75,
        height: constraints.maxHeight * 0.45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          border: Border.all(color: AppColors.primary, width: AppSizes.focusBorderWidth),
        ),
      ),
    );
  }

  Widget _errorView(BuildContext context, MobileScannerException error) {
    final message = switch (error.errorCode) {
      MobileScannerErrorCode.permissionDenied => 'barcode.error_permission'.tr,
      MobileScannerErrorCode.unsupported => 'barcode.error_unsupported'.tr,
      _ => 'barcode.error_generic'.tr,
    };
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spaceLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.no_photography_outlined, color: AppColors.onDark, size: AppSizes.alertIcon),
          const SizedBox(height: AppSizes.spaceMedium),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onDark),
          ),
        ],
      ),
    );
  }
}
