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

  group('TaxUtil.documentAmounts', () {
    test('ร้านจด VAT ราคาไม่รวม VAT: รวม 100 ลด 10 ก่อน VAT 90 VAT 6.30 สุทธิ 96.30', () {
      final amounts = TaxUtil.documentAmounts(
        itemsTotal: 100,
        discount: 10,
        vatRegistered: true,
        pricesIncludeVat: false,
      );
      expect([amounts.subtotal, amounts.vat, amounts.total], [90, 6.3, 96.3]);
    });

    test('ร้านจด VAT ราคารวม VAT แล้ว: 107 ถอดเป็นก่อน VAT 100 + VAT 7', () {
      final amounts = TaxUtil.documentAmounts(
        itemsTotal: 107,
        discount: 0,
        vatRegistered: true,
        pricesIncludeVat: true,
      );
      expect([amounts.subtotal, amounts.vat, amounts.total], [100, 7, 107]);
    });

    test('ร้านไม่จด VAT: ไม่มี VAT สุทธิ = รวม − ส่วนลด', () {
      final amounts = TaxUtil.documentAmounts(
        itemsTotal: 200,
        discount: 10,
        vatRegistered: false,
        pricesIncludeVat: true,
      );
      expect([amounts.subtotal, amounts.vat, amounts.total], [190, 0, 190]);
    });
  });
}
