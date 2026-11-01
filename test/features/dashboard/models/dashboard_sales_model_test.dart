import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/dashboard/models/dashboard_sales_model.dart';

void main() {
  group('SalesSummaryModel', () {
    test('fromJson อ่านค่าได้ถูกต้อง', () {
      final json = {
        'net_sales': 2186.92,
        'cost': 411.2,
        'gross_profit': 1775.72,
        'gross_margin': 81.2,
        'vat': 153.08,
        'discount': 50,
        'items_sold': 15,
        'average_bill': 1093.46,
      };
      expect(
        SalesSummaryModel.fromJson(json),
        const SalesSummaryModel(
          netSales: 2186.92,
          cost: 411.2,
          grossProfit: 1775.72,
          grossMargin: 81.2,
          vat: 153.08,
          discount: 50,
          itemsSold: 15,
          averageBill: 1093.46,
        ),
      );
    });

    test('ไม่มีข้อมูล ได้ 0 ทุกช่อง', () {
      expect(SalesSummaryModel.fromJson({}), const SalesSummaryModel());
    });
  });

  group('MonthTotalsModel', () {
    test('fromJson อ่านค่าได้ และแปลงเดือนเป็นวันที่ 1 ของเดือน', () {
      final month = MonthTotalsModel.fromJson({
        'month': '2026-10',
        'income': 2340,
        'expense': 5860.5,
        'profit': -3520.5,
        'bills': 2,
        'gross_profit': 1775.72,
      });
      expect([month.income, month.expense, month.profit], [2340, 5860.5, -3520.5]);
      expect([month.bills, month.grossProfit], [2, 1775.72]);
      expect(month.monthDate, DateTime(2026, 10));
    });

    test('fromJson อ่านรายได้ ต้นทุนสินค้า รายจ่าย และ totalCost = ต้นทุน + รายจ่าย', () {
      final month = MonthTotalsModel.fromJson({
        'month': '2026-11',
        'revenue': 1300,
        'cost_of_sales': 600,
        'operating_expense': 350.5,
        'profit': 349.5,
      });
      expect([month.revenue, month.costOfSales, month.operatingExpense], [1300, 600, 350.5]);
      expect(month.totalCost, 950.5);
      expect(month.revenue - month.totalCost, month.profit);
    });

    test('เดือนว่าง monthDate เป็น null', () {
      expect(const MonthTotalsModel().monthDate, null);
    });
  });

  group('DailySalesModel', () {
    test('fromJson อ่านค่าได้ และ day คือวันที่ของเดือน', () {
      final day = DailySalesModel.fromJson({'date': '2026-10-05', 'net_sales': 1355.14, 'bills': 1});
      expect([day.netSales, day.bills, day.day], [1355.14, 1, 5]);
    });

    test('weekdayIndex 0 = อาทิตย์ ... 6 = เสาร์', () {
      expect(const DailySalesModel(date: '2026-10-04').weekdayIndex, 0);
      expect(const DailySalesModel(date: '2026-10-05').weekdayIndex, 1);
      expect(const DailySalesModel(date: '2026-10-10').weekdayIndex, 6);
    });
  });

  group('ProductSalesModel', () {
    test('fromJson อ่านค่าได้ถูกต้อง', () {
      final json = {
        'product_id': 'p1',
        'name': 'เคส',
        'unit': 'ชิ้น',
        'quantity': 4,
        'net_sales': 903.43,
        'cost': 211.2,
        'profit': 692.23,
        'margin': 76.62,
      };
      expect(
        ProductSalesModel.fromJson(json),
        const ProductSalesModel(
          productId: 'p1',
          name: 'เคส',
          unit: 'ชิ้น',
          quantity: 4,
          netSales: 903.43,
          cost: 211.2,
          profit: 692.23,
          margin: 76.62,
        ),
      );
    });
  });

  group('CategoryAmountModel', () {
    test('fromJson อ่านค่าได้ หมวดว่าง = ไม่มีหมวด', () {
      expect(
        CategoryAmountModel.fromJson({'category': '', 'amount': 451.71, 'percent': 20.66}),
        const CategoryAmountModel(category: '', amount: 451.71, percent: 20.66),
      );
    });
  });

  group('StockValueModel', () {
    test('fromJson อ่านค่าได้ถูกต้อง', () {
      expect(
        StockValueModel.fromJson({'cost_value': 8922.4, 'retail_value': 14025, 'out_of_stock': 2}),
        const StockValueModel(costValue: 8922.4, retailValue: 14025, outOfStock: 2),
      );
    });
  });

  group('MarketPositionModel', () {
    test('fromJson อ่านค่าได้ และเวลาเป็นเวลาเครื่อง', () {
      final model = MarketPositionModel.fromJson({
        'product_id': 'p1',
        'name': 'เคส',
        'customer_price': 250,
        'retail_low': 199,
        'retail_high': 390,
        'retail_typical': 259,
        'position': 'within',
        'diff_percent': -3.47,
        'checked_at': '2026-10-31T03:00:00Z',
      });
      expect([model.customerPrice, model.retailLow, model.retailHigh, model.diffPercent], [250, 199, 390, -3.47]);
      expect(model.checkedAt, DateTime.utc(2026, 10, 31, 3).toLocal());
    });

    test('ไม่มี position ถือว่าไม่รู้ (unknown)', () {
      expect(MarketPositionModel.fromJson({'product_id': 'p1', 'name': 'เคส'}).position, 'unknown');
    });
  });
}
