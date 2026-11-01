// error จาก API: code = ค่า "error" / params = ค่าอื่นที่ส่งมาด้วย (เช่น วัสดุไม่พอ: material, need, have)
// ใช้แสดงข้อความด้วย 'error.<code>'.trParams(params)
class ApiException implements Exception {
  ApiException(this.code, {this.params = const {}});

  final String code;
  final Map<String, String> params;

  @override
  String toString() => 'ApiException: $code';
}
