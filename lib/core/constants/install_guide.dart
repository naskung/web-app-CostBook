// วิธีเพิ่ม CostBook ไว้ที่หน้าจอ แยกตามเครื่อง / browser (ข้อความอยู่ใน install.guide_<ชื่อ>_title / _steps)
enum InstallGuide {
  iphone('iphone'),
  android('android'),
  desktop('desktop'),
  macSafari('mac_safari'),
  firefoxDesktop('firefox');

  const InstallGuide(this.key);

  final String key;

  String get titleKey => 'install.guide_${key}_title';

  String get stepsKey => 'install.guide_${key}_steps';
}
