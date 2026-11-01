import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/dashboard/models/dashboard_model.dart';
import 'package:costbook/features/dashboard/models/dashboard_sales_model.dart';

void main() {
  final json = {
    'month': '2026-10',
    'income': 2340,
    'expense': 5860.5,
    'profit': -4084.78,
    'revenue': 2186.92,
    'operating_expense': 5860.5,
    'material_expense': 0,
    'invoice_count': 2,
    'invoice_total': 2340,
    'product_count': 4,
    'low_stock_count': 1,
    'low_stock': [
      {'product_id': 'p1', 'name': 'กาแฟเย็น', 'unit': 'แก้ว', 'stock': 2, 'min_stock': 5},
    ],
    'sales': {'net_sales': 2186.92, 'cost': 411.2, 'gross_profit': 1775.72, 'gross_margin': 81.2, 'items_sold': 15},
    'previous': {
      'month': '2026-09',
      'revenue': 415.89,
      'cost_of_sales': 100,
      'operating_expense': 1250,
      'profit': -934.11,
    },
    'monthly_trend': [
      {'month': '2026-09', 'revenue': 415.89, 'cost_of_sales': 100, 'operating_expense': 1250, 'profit': -934.11},
      {'month': '2026-10', 'revenue': 2186.92, 'cost_of_sales': 411.2, 'operating_expense': 5860.5, 'profit': -4084.78},
    ],
    'daily_sales': [
      {'date': '2026-10-05', 'net_sales': 1355.14, 'bills': 1},
      {'date': '2026-10-12', 'net_sales': 200, 'bills': 1},
      {'date': '2026-10-04', 'net_sales': 89.5, 'bills': 1},
    ],
    'previous_daily_sales': [
      {'date': '2026-09-15', 'net_sales': 415.89, 'bills': 1},
    ],
    'top_products': [
      {
        'product_id': 'p2',
        'name': 'เคส',
        'unit': 'ชิ้น',
        'quantity': 4,
        'net_sales': 903.43,
        'cost': 211.2,
        'profit': 692.23,
        'margin': 76.62,
      },
    ],
    'category_sales': [
      {'category': 'งานพิมพ์ 3D', 'amount': 1735.21, 'percent': 70},
      {'category': 'งานบริการ', 'amount': 451.71, 'percent': 20},
      {'category': 'วัสดุ', 'amount': 150, 'percent': 6},
      {'category': '', 'amount': 100, 'percent': 4},
    ],
    'expense_by_category': [
      {'category': 'rent', 'amount': 5000, 'percent': 85.32},
    ],
    'stock': {'cost_value': 8922.4, 'retail_value': 14025, 'out_of_stock': 0},
    'market': [
      {
        'product_id': 'p2',
        'name': 'เคส',
        'customer_price': 250,
        'retail_low': 199,
        'retail_high': 390,
        'retail_typical': 259,
        'position': 'within',
        'diff_percent': -3.47,
        'checked_at': '2026-10-31T03:00:00Z',
      },
    ],
  };

  group('DashboardModel', () {
    test('fromJson อ่านตัวเลขหลักและสินค้าใกล้หมดได้ถูกต้อง', () {
      final dashboard = DashboardModel.fromJson(json);
      expect(
        [dashboard.income, dashboard.expense, dashboard.profit, dashboard.invoiceCount],
        [2340, 5860.5, -4084.78, 2],
      );
      expect([dashboard.revenue, dashboard.operatingExpense, dashboard.materialExpense], [2186.92, 5860.5, 0]);
      expect(dashboard.lowStock, [
        const LowStockItemModel(productId: 'p1', name: 'กาแฟเย็น', unit: 'แก้ว', stock: 2, minStock: 5),
      ]);
    });

    test('fromJson อ่านยอดขาย / เดือนก่อน / มูลค่าสต็อก ได้ถูกต้อง', () {
      final dashboard = DashboardModel.fromJson(json);
      expect(dashboard.sales.grossMargin, 81.2);
      expect(dashboard.previous.month, '2026-09');
      expect(dashboard.stock, const StockValueModel(costValue: 8922.4, retailValue: 14025));
    });

    test('fromJson อ่านทุก list ได้ครบ', () {
      final dashboard = DashboardModel.fromJson(json);
      expect(
        [
          dashboard.monthlyTrend.length,
          dashboard.dailySales.length,
          dashboard.previousDailySales.length,
          dashboard.topProducts.length,
          dashboard.categorySales.length,
          dashboard.expenseByCategory.length,
          dashboard.market.length,
        ],
        [2, 3, 1, 1, 4, 1, 1],
      );
      expect(dashboard.topProducts.first.margin, 76.62);
      expect(dashboard.market.first.position, 'within');
    });

    test('ไม่มี field ไหนเลย (API เก่า) ได้ค่าว่างทุกช่อง ไม่ error', () {
      expect(DashboardModel.fromJson({}), const DashboardModel());
    });

    test('hasSales เป็น true เมื่อมีเอกสารขาย', () {
      expect(DashboardModel.fromJson(json).hasSales, true);
      expect(const DashboardModel().hasSales, false);
    });

    test('weekdaySales รวมยอดตามวันในสัปดาห์ (0 = อาทิตย์): 5 และ 12 ต.ค. 2026 เป็นวันจันทร์', () {
      final totals = DashboardModel.fromJson(json).weekdaySales;
      expect(totals, [89.5, 1555.14, 0, 0, 0, 0, 0]);
    });

    test('topCategories เอาแค่ 3 หมวดแรก', () {
      final categories = DashboardModel.fromJson(json).topCategories;
      expect(categories.map((item) => item.category), ['งานพิมพ์ 3D', 'งานบริการ', 'วัสดุ']);
    });

    test('hasTrend เป็น false เมื่อ 6 เดือนไม่มีรายได้ / ต้นทุน / รายจ่ายเลย', () {
      expect(DashboardModel.fromJson(json).hasTrend, true);
      const empty = DashboardModel(monthlyTrend: [MonthTotalsModel(month: '2026-10')]);
      expect(empty.hasTrend, false);
    });
  });
}
