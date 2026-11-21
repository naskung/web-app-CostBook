class BarcodeUtil {
  // กล้องอ่านได้หลายค่าพร้อมกัน → ใช้รหัสแรกที่ไม่ว่าง (ตัดช่องว่างหัวท้าย) / อ่านไม่ได้เลย = ''
  static String firstCode(Iterable<String?> values) {
    for (final value in values) {
      final code = value?.trim() ?? '';
      if (code.isNotEmpty) return code;
    }
    return '';
  }
}
