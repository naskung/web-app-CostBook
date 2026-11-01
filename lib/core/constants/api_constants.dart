class ApiConstants {
  static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080/api/v1');
  static const String companyLogoUrl = '$baseUrl/company/logo';

  // ?v= เปลี่ยนทุกครั้งที่เปลี่ยนรูป → browser โหลดรูปใหม่ ไม่ใช้รูปเก่าที่เก็บไว้
  static String productImageUrl(String id, int version) => '$baseUrl/products/$id/image?v=$version';

  static String userAvatarUrl(String id, int version) => '$baseUrl/users/$id/avatar?v=$version';
}
