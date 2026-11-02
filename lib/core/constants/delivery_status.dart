// สถานะการส่งสินค้าของเอกสารขาย (ตรงกับ API) เรียงตามลำดับที่เกิด / ค่าที่ไม่รู้จัก → received (ถือว่าลูกค้าได้ของแล้ว)
enum DeliveryStatus {
  pending,
  shipped,
  received;

  String get labelKey => 'delivery.$name';

  static DeliveryStatus fromName(String? name) {
    for (final status in values) {
      if (status.name == name) return status;
    }
    return received;
  }
}
