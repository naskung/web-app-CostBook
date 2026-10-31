import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_menu.dart';
import 'package:costbook/core/routes/app_routes.dart';

void main() {
  AppMenuItem itemOf(String route) {
    return AppMenu.items.firstWhere((item) => item.route == route);
  }

  test('มีเมนูครบ 8 หน้า ตามลำดับ (ผู้ช่วย AI เป็นปุ่มลอยมุมขวาล่าง ไม่ใช่เมนู)', () {
    final routes = AppMenu.items.map((item) => item.route).toList();
    expect(routes, [
      AppRoutes.dashboard,
      AppRoutes.sell,
      AppRoutes.products,
      AppRoutes.cost,
      AppRoutes.stock,
      AppRoutes.transactions,
      AppRoutes.invoices,
      AppRoutes.settings,
    ]);
  });

  test('อยู่หน้าแรก เลือกเมนูภาพรวม', () {
    expect(itemOf(AppRoutes.dashboard).isSelected('/'), true);
  });

  test('อยู่หน้าสินค้า ไม่เลือกเมนูภาพรวม', () {
    expect(itemOf(AppRoutes.dashboard).isSelected('/products'), false);
  });

  test('อยู่หน้าย่อย /products/1 ยังเลือกเมนูสินค้า', () {
    expect(itemOf(AppRoutes.products).isSelected('/products/1'), true);
  });

  test('path ที่ขึ้นต้นคล้ายกัน /productsx ไม่เลือกเมนูสินค้า', () {
    expect(itemOf(AppRoutes.products).isSelected('/productsx'), false);
  });

  test('titleOf คืนชื่อเมนูของหน้านั้น', () {
    expect(AppMenu.titleOf('/stock'), 'menu.stock'.tr);
  });

  test('titleOf path ที่ไม่มีในเมนู ได้ชื่อแอป', () {
    expect(AppMenu.titleOf('/unknown'), 'app.name'.tr);
  });

  test('ร้านไม่ใช้หน้าคำนวณต้นทุน ซ่อนเมนูคำนวณต้นทุน', () {
    final routes = AppMenu.itemsFor(useCostPage: false).map((item) => item.route);
    expect(routes, isNot(contains(AppRoutes.cost)));
    expect(routes.length, AppMenu.items.length - 1);
  });

  test('ร้านใช้หน้าคำนวณต้นทุน เห็นเมนูครบ', () {
    expect(AppMenu.itemsFor(useCostPage: true), AppMenu.items);
  });
}
