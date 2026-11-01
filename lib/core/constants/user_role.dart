// role ของผู้ใช้ (ตรงกับ API) เรียงจากสิทธิ์มากไปน้อย / role ที่ไม่รู้จัก → staff (สิทธิ์น้อยสุด)
enum UserRole {
  owner,
  manager,
  staff;

  String get labelKey => 'role.$name';

  static UserRole fromName(String? name) {
    for (final role in values) {
      if (role.name == name) return role;
    }
    return staff;
  }
}
