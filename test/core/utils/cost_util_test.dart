import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/utils/cost_util.dart';

void main() {
  group('CostUtil.costPerUnit', () {
    test('ต้นทุนรวม 1,000 บาท ผลิต 100 ชิ้น ได้ต้นทุนชิ้นละ 10 บาท', () {
      final result = CostUtil.costPerUnit(material: 500, labor: 300, overhead: 200, quantity: 100);
      expect(result, 10);
    });

    test('ต้นทุน 100 บาท ผลิต 3 ชิ้น ได้ชิ้นละ 33.33 บาท', () {
      expect(CostUtil.costPerUnit(material: 100, labor: 0, overhead: 0, quantity: 3), 33.33);
    });

    test('จำนวนผลิตเป็น 0 ได้ต้นทุน 0 (ไม่ error)', () {
      expect(CostUtil.costPerUnit(material: 500, labor: 0, overhead: 0, quantity: 0), 0);
    });
  });

  group('CostUtil.sellPrice', () {
    test('ต้นทุน 10 บาท markup 50% ได้ราคาขาย 15 บาท', () {
      expect(CostUtil.sellPrice(cost: 10, markupPercent: 50), 15);
    });

    test('markup 0% ได้ราคาเท่าทุน', () {
      expect(CostUtil.sellPrice(cost: 12.5, markupPercent: 0), 12.5);
    });
  });

  group('CostUtil.profitPerUnit / markupPercent', () {
    test('ขาย 45 ทุน 25 กำไรชิ้นละ 20', () {
      expect(CostUtil.profitPerUnit(sellPrice: 45, cost: 25), 20);
    });

    test('ขาย 45 ทุน 25 คิดเป็น markup 80%', () {
      expect(CostUtil.markupPercent(sellPrice: 45, cost: 25), 80);
    });

    test('ต้นทุน 0 ได้ markup 0 (ไม่หารด้วย 0)', () {
      expect(CostUtil.markupPercent(sellPrice: 45, cost: 0), 0);
    });
  });
}
