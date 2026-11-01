import 'package:costbook/core/network/api_exception.dart';

class ErrorUtil {
  static String codeOf(Object error) {
    if (error is ApiException) return error.code;
    return 'unknown_error';
  }

  // ค่าที่ API ส่งมากับ error (ไว้ใส่ในข้อความ) — ไม่มี = {}
  static Map<String, String> paramsOf(Object error) {
    if (error is ApiException) return error.params;
    return const {};
  }
}
