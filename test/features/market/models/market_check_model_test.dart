import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/market/models/market_check_model.dart';

void main() {
  final json = {
    'id': 'm1',
    'product_id': 'p1',
    'our_cost_price': 52.8,
    'our_sell_price': 250,
    'summary': 'ราคาส่วนใหญ่ 199–390 บาท',
    'retail_low': 199,
    'retail_high': 390,
    'retail_typical': 259,
    'wholesale_low': 0,
    'wholesale_high': 0,
    'wholesale_note': 'ไม่เจอราคาส่ง',
    'market_cost': 45,
    'cost_items': [
      {'name': 'เส้น PLA', 'amount': 18, 'note': '40 กรัม × 0.45'},
    ],
    'suggested_price': 259,
    'advice': 'ตั้ง 259 บาท',
    'confidence': 'medium',
    'sources': [
      {'title': 'Shopee', 'url': 'https://shopee.co.th/x', 'price': 259, 'kind': 'retail'},
    ],
    'checked_at': '2026-10-01T03:00:00Z',
  };

  group('MarketCheckModel', () {
    test('fromJson อ่านราคาตลาดได้ถูกต้อง', () {
      final check = MarketCheckModel.fromJson(json);
      expect(
        [check.retailLow, check.retailHigh, check.retailTypical, check.marketCost, check.suggestedPrice],
        [199, 390, 259, 45, 259],
      );
      expect([check.ourCostPrice, check.ourSellPrice, check.confidence], [52.8, 250, 'medium']);
    });

    test('fromJson อ่านรายการต้นทุน และแหล่งที่มาได้', () {
      final check = MarketCheckModel.fromJson(json);
      expect(check.costItems, [const MarketCostItemModel(name: 'เส้น PLA', amount: 18, note: '40 กรัม × 0.45')]);
      expect(check.sources, [
        const MarketSourceModel(url: 'https://shopee.co.th/x', title: 'Shopee', price: 259, kind: 'retail'),
      ]);
    });

    test('hasRetail / hasWholesale บอกว่าเจอราคาไหม', () {
      final check = MarketCheckModel.fromJson(json);
      expect([check.hasRetail, check.hasWholesale], [true, false]);
    });

    test('daysOld นับว่าเช็คมาแล้วกี่วัน', () {
      final check = MarketCheckModel.fromJson(json);
      expect(check.daysOld(DateTime.utc(2026, 10, 31, 3).toLocal()), 30);
      expect(const MarketCheckModel(id: 'x', productId: 'p').daysOld(DateTime(2026)), 0);
    });

    test('ไม่มี field ไหนเลย ได้ค่าว่าง ไม่ error', () {
      final check = MarketCheckModel.fromJson({});
      expect([check.id, check.confidence, check.costItems, check.sources], ['', 'low', [], []]);
    });
  });
}
