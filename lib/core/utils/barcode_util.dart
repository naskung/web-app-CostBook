class BarcodeUtil {
  static const List<int> _globalCodeLengths = [8, 12, 13, 14];

  // กล้องอ่านได้หลายค่าพร้อมกัน → ใช้รหัสแรกที่ไม่ว่าง (ตัดช่องว่างหัวท้าย) / อ่านไม่ได้เลย = ''
  static String firstCode(Iterable<String?> values) {
    for (final value in values) {
      final code = value?.trim() ?? '';
      if (code.isNotEmpty) return code;
    }
    return '';
  }

  // เลขบาร์โค้ดสากล (EAN-8 / UPC-A / EAN-13 / GTIN-14) = ตัวเลขล้วน 8 / 12 / 13 / 14 หลัก
  // รหัสที่ร้านตั้งเอง เช่น CF001 ไม่ใช่ → ไม่ต้องไปหาชื่อจากฐานข้อมูลสากล
  static bool isGlobalCode(String code) {
    if (!_globalCodeLengths.contains(code.length)) return false;
    return RegExp(r'^[0-9]+$').hasMatch(code);
  }
}
