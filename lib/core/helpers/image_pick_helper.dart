import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class ImagePickHelper {
  // API รับรูปไม่เกิน 1 MB
  static const int maxBytes = 1024 * 1024;

  // ย่อรูปด้านยาวไม่เกิน 1200 px + ลดคุณภาพนิดหน่อย → รูปจากมือถือ / กล้องเล็กพอส่งได้
  static const double maxSide = 1200;
  static const int quality = 85;

  // เลือกรูปจากเครื่อง ได้ไฟล์รูปที่ย่อแล้ว / null = ไม่ได้เลือก
  static Future<Uint8List?> pick() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: maxSide,
      maxHeight: maxSide,
      imageQuality: quality,
    );
    if (file == null) return null;
    return file.readAsBytes();
  }
}
