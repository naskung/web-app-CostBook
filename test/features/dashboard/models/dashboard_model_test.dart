import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/dashboard/models/dashboard_model.dart';

void main() {
  const dashboard = DashboardModel(
    income: 12500,
    expense: 4300.5,
    profit: 8199.5,
    invoiceCount: 8,
    invoiceTotal: 10700,
    productCount: 24,
    lowStockCount: 1,
    lowStock: [LowStockItemModel(productId: 'p1', name: 'กาแฟเย็น', unit: 'แก้ว', stock: 2, minStock: 5)],
  );

  group('DashboardModel', () {
    test('fromJson อ่านค่าและสินค้าใกล้หมดได้ถูกต้อง', () {
      final json = {
        'month': '2026-10',
        'income': 12500,
        'expense': 4300.5,
        'profit': 8199.5,
        'invoice_count': 8,
        'invoice_total': 10700,
        'product_count': 24,
        'low_stock_count': 1,
        'low_stock': [
          {'product_id': 'p1', 'name': 'กาแฟเย็น', 'unit': 'แก้ว', 'stock': 2, 'min_stock': 5},
        ],
      };
      expect(DashboardModel.fromJson(json), dashboard);
    });

    test('toJson แล้ว fromJson กลับมา ได้ค่าเดิม', () {
      expect(DashboardModel.fromJson(dashboard.toJson()), dashboard);
    });

    test('ไม่มี field ไหนเลย ได้ 0 ทุกช่อง ไม่ error', () {
      expect(DashboardModel.fromJson({}), const DashboardModel());
    });
  });
}
