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

  group('BarcodeUtil.isGlobalCode', () {
    test('EAN-13 ของไทย / EAN-8 / UPC-A 12 หลัก / GTIN-14 เป็นบาร์โค้ดสากล', () {
      expect(BarcodeUtil.isGlobalCode('8850124003850'), isTrue);
      expect(BarcodeUtil.isGlobalCode('96385074'), isTrue);
      expect(BarcodeUtil.isGlobalCode('036000291452'), isTrue);
      expect(BarcodeUtil.isGlobalCode('18850124003857'), isTrue);
    });

    test('รหัสที่ร้านตั้งเอง / ความยาวไม่ตรง / ว่าง ไม่ใช่บาร์โค้ดสากล', () {
      expect(BarcodeUtil.isGlobalCode('CF001'), isFalse);
      expect(BarcodeUtil.isGlobalCode('885012400385A'), isFalse);
      expect(BarcodeUtil.isGlobalCode('1234567890'), isFalse);
      expect(BarcodeUtil.isGlobalCode(''), isFalse);
    });
  });
}
