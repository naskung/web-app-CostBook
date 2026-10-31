import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/utils/tax_util.dart';

void main() {
  group('TaxUtil', () {
    test('vat ของ 100 บาท ได้ 7 บาท', () {
      expect(TaxUtil.vat(100), 7);
    });

    test('vat ของ 1,234.56 บาท ได้ 86.42 บาท', () {
      expect(TaxUtil.vat(1234.56), 86.42);
    });

    test('vat ของ 0 บาท ได้ 0', () {
      expect(TaxUtil.vat(0), 0);
    });

    test('ราคารวม vat ของ 100 บาท ได้ 107 บาท', () {
      expect(TaxUtil.totalWithVat(100), 107);
    });

    test('ถอด vat จาก 107 บาท ได้ 100 บาท', () {
      expect(TaxUtil.priceBeforeVat(107), 100);
    });
  });
}
