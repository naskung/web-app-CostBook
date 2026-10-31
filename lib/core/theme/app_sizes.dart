/// ขนาดทั้งหมดของแอป (ตัวอักษร, ระยะห่าง, มุมโค้ง) แก้ที่นี่ที่เดียว
class AppSizes {
  // ขนาดตัวอักษร — ใช้ผ่าน Theme.of(context).textTheme ดู app_theme.dart
  static const double fontSmall = 12; // คำอธิบาย, หมายเหตุ
  static const double fontBody = 14; // ข้อความทั่วไป, ปุ่ม
  static const double fontLarge = 16; // ข้อความเด่น, หัวข้อย่อย
  static const double fontTitle = 20; // หัวข้อการ์ด / ส่วน
  static const double fontHeading = 24; // หัวข้อหน้า

  // ระยะห่าง (padding / margin / ช่องว่างระหว่าง widget)
  static const double spaceSmall = 8;
  static const double spaceMedium = 16;
  static const double spaceLarge = 24;

  // มุมโค้งของปุ่ม / ช่องกรอก / การ์ด
  static const double radius = 8;
}
