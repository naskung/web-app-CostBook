import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_menu.dart';
import 'package:costbook/core/routes/app_routes.dart';

void main() {
  AppMenuItem itemOf(String route) {
    return AppMenu.items.firstWhere((item) => item.route == route);
  }

  final productGroup = itemOf(AppRoutes.products);

  test('มีเมนูหลัก 7 อัน ตามลำดับ (สินค้า + สต็อกรวมเป็นกลุ่มเดียว / ผู้ช่วย AI เป็นปุ่มลอย ไม่ใช่เมนู)', () {
    final routes = AppMenu.items.map((item) => item.route).toList();
    expect(routes, [
      AppRoutes.dashboard,
      AppRoutes.sell,
      AppRoutes.products,
      AppRoutes.cost,
      AppRoutes.transactions,
      AppRoutes.invoices,
      AppRoutes.settings,
    ]);
  });

  test('กลุ่มสินค้ามีเมนูย่อย รายการสินค้า / ประวัติสต็อก / หมวดหมู่สินค้า', () {
    expect(productGroup.hasChildren, true);
    expect(productGroup.children.map((child) => child.route), [
      AppRoutes.products,
      AppRoutes.stock,
      AppRoutes.productCategories,
    ]);
  });

  test('อยู่หน้าแรก เลือกเมนูภาพรวม', () {
    expect(itemOf(AppRoutes.dashboard).isSelected('/'), true);
  });

  test('อยู่หน้าสินค้า ไม่เลือกเมนูภาพรวม', () {
    expect(itemOf(AppRoutes.dashboard).isSelected('/products'), false);
  });

  test('อยู่หน้า /stock เลือกกลุ่มสินค้า และเมนูย่อยประวัติสต็อก', () {
    expect(productGroup.isSelected('/stock'), true);
    expect(productGroup.selectedChild('/stock')?.route, AppRoutes.stock);
  });

  test('อยู่หน้าหมวดหมู่ เลือกเมนูย่อยหมวดหมู่ ไม่ใช่รายการสินค้า (เอา route ที่ยาวกว่า)', () {
    expect(productGroup.selectedChild('/products/categories')?.route, AppRoutes.productCategories);
  });

  test('อยู่หน้าย่อย /products/1/market ยังเลือกรายการสินค้า', () {
    expect(productGroup.selectedChild('/products/1/market')?.route, AppRoutes.products);
  });

  test('path ที่ขึ้นต้นคล้ายกัน /productsx ไม่เลือกกลุ่มสินค้า', () {
    expect(productGroup.isSelected('/productsx'), false);
  });

  test('titleOf ใช้ชื่อเมนูย่อยของหน้านั้น', () {
    expect(AppMenu.titleOf('/stock'), 'menu.stock_history'.tr);
    expect(AppMenu.titleOf('/sell'), 'menu.sell'.tr);
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
