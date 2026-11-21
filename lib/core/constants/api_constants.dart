class ApiConstants {
  static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080/api/v1');
  static const String companyLogoUrl = '$baseUrl/company/logo';

  // รายการที่โหลดทีละหน้า: หน้าละ 20 / API ให้ต่อครั้งมากสุด 200 (?limit=)
  static const int pageSize = 20;
  static const int maxPageLimit = 200;

  // ?v= เปลี่ยนทุกครั้งที่เปลี่ยนรูป → browser โหลดรูปใหม่ ไม่ใช้รูปเก่าที่เก็บไว้
  static String productImageUrl(String id, int version) => '$baseUrl/products/$id/image?v=$version';

  static String userAvatarUrl(String id, int version) => '$baseUrl/users/$id/avatar?v=$version';

  // ไอคอนแอป / favicon สี่เหลี่ยมจัตุรัส: โลโก้ร้าน หรือไอคอนเริ่มต้นของ CostBook (size = 32 / 64 / 180 / 192 / 512)
  static String companyIconUrl(int size, int version) => '$baseUrl/company/icon?size=$size&v=$version';
}
