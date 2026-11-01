import 'package:costbook/core/constants/api_constants.dart';

// รายการที่โหลดทีละหน้า (เลื่อนลงแล้วโหลดเพิ่ม)
class PageUtil {
  // ต่อหน้าใหม่ท้ายรายการ — ตัวที่มีอยู่แล้ว (id ซ้ำ) ไม่เพิ่มซ้ำ
  // (ระหว่างเลื่อนมีรายการใหม่เข้ามาข้างบน ลำดับเลื่อน หน้าถัดไปอาจมีตัวที่เห็นแล้ว)
  static List<T> append<T>(List<T> current, List<T> next, String Function(T item) idOf) {
    final ids = current.map(idOf).toSet();
    return [...current, ...next.where((item) => !ids.contains(idOf(item)))];
  }

  // ได้ครบตามที่ขอ = อาจยังมีอีก / ได้น้อยกว่า = หมดแล้ว
  static bool hasMore(int received, int requested) => received >= requested;

  // โหลดใหม่หลังบันทึก / ลบ: โหลดเท่าที่เคยโหลดไว้ (เลื่อนไปถึงไหนก็ยังอยู่ตรงนั้น) ไม่น้อยกว่า 1 หน้า ไม่เกินที่ API ให้
  static int reloadLimit(int loaded) => loaded.clamp(ApiConstants.pageSize, ApiConstants.maxPageLimit);
}
