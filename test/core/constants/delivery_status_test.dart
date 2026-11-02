import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/constants/delivery_status.dart';

void main() {
  test('แปลงชื่อจาก API เป็นสถานะการส่งได้ครบ', () {
    expect(DeliveryStatus.fromName('pending'), DeliveryStatus.pending);
    expect(DeliveryStatus.fromName('shipped'), DeliveryStatus.shipped);
    expect(DeliveryStatus.fromName('received'), DeliveryStatus.received);
  });

  test('สถานะที่ไม่รู้จัก / ไม่มี (API เก่า) → received', () {
    expect(DeliveryStatus.fromName('lost'), DeliveryStatus.received);
    expect(DeliveryStatus.fromName(null), DeliveryStatus.received);
  });

  test('key ข้อความของสถานะ', () {
    expect(DeliveryStatus.shipped.labelKey, 'delivery.shipped');
  });
}
