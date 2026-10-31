import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/utils/market_util.dart';

void main() {
  group('MarketUtil.customerPrice', () {
    test('จด VAT ราคาไม่รวม VAT: 100 → ลูกค้าจ่าย 107', () {
      expect(MarketUtil.customerPrice(sellPrice: 100, vatRegistered: true, pricesIncludeVat: false), 107);
    });

    test('ราคารวม VAT แล้ว หรือไม่จด VAT: ลูกค้าจ่ายเท่าราคาที่ตั้ง', () {
      expect(MarketUtil.customerPrice(sellPrice: 100, vatRegistered: true, pricesIncludeVat: true), 100);
      expect(MarketUtil.customerPrice(sellPrice: 100, vatRegistered: false, pricesIncludeVat: false), 100);
    });
  });

  group('MarketUtil.position', () {
    test('ถูกกว่า / อยู่ในช่วง / แพงกว่า / ไม่มีราคาตลาด', () {
      expect(
        [
          MarketUtil.position(price: 150, low: 199, high: 390),
          MarketUtil.position(price: 250, low: 199, high: 390),
          MarketUtil.position(price: 450, low: 199, high: 390),
          MarketUtil.position(price: 250, low: 0, high: 0),
        ],
        [MarketUtil.below, MarketUtil.within, MarketUtil.above, MarketUtil.unknown],
      );
    });
  });

  group('MarketUtil.diffPercent', () {
    test('250 เทียบราคาที่เจอบ่อย 259 = -3.47%', () {
      expect(MarketUtil.diffPercent(price: 250, typical: 259), -3.47);
    });

    test('ไม่มีราคาที่เจอบ่อย ได้ 0', () {
      expect(MarketUtil.diffPercent(price: 250, typical: 0), 0);
    });
  });

  group('MarketUtil.placeInRange', () {
    test('ตำแหน่งบนแถบ 0 ถึง 1', () {
      expect(MarketUtil.placeInRange(value: 300, low: 200, high: 400), 0.5);
      expect(MarketUtil.placeInRange(value: 500, low: 200, high: 400), 1);
    });

    test('ช่วงเป็นจุดเดียว วางไว้ตรงกลาง', () {
      expect(MarketUtil.placeInRange(value: 200, low: 200, high: 200), 0.5);
    });
  });
}
