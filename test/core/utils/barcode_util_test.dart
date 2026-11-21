import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/utils/barcode_util.dart';

void main() {
  group('BarcodeUtil.firstCode', () {
    test('ได้รหัสแรกที่อ่านได้', () {
      expect(BarcodeUtil.firstCode(['8851234567890', '123']), '8851234567890');
    });

    test('ข้ามค่าว่าง / null และตัดช่องว่างหัวท้าย', () {
      expect(BarcodeUtil.firstCode([null, '  ', ' 8850999 ']), '8850999');
    });

    test('อ่านไม่ได้เลย = ว่าง', () {
      expect(BarcodeUtil.firstCode([]), '');
      expect(BarcodeUtil.firstCode([null, '']), '');
    });
  });
}
