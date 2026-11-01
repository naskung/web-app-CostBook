import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_routes.dart';

// เมนู 1 อัน — มี children = กลุ่มเมนู (กดแล้วกาง / หุบ) ตัวกลุ่มไม่มีหน้าของตัวเอง
class AppMenuItem {
  const AppMenuItem({required this.route, required this.icon, required this.labelKey, this.children = const []});

  final String route;
  final IconData icon;
  final String labelKey;
  final List<AppMenuItem> children;

  String get label => labelKey.tr;

  bool get hasChildren => children.isNotEmpty;

  // เมนูธรรมดา: path ตรง หรืออยู่ใต้ route นี้ / กลุ่ม: มีเมนูย่อยตัวไหนถูกเลือก
  bool isSelected(String path) {
    if (hasChildren) return selectedChild(path) != null;
    if (path == route) return true;
    if (route == AppRoutes.dashboard) return false;
    return path.startsWith('$route/');
  }

  // เมนูย่อยที่ถูกเลือก — ถ้าตรงหลายตัว (เช่น /products กับ /products/categories) เอาตัวที่ route ยาวสุด
  AppMenuItem? selectedChild(String path) {
    AppMenuItem? best;
    for (final child in children) {
      if (!child.isSelected(path)) continue;
      if (best == null || child.route.length > best.route.length) best = child;
    }
    return best;
  }
}

class AppMenu {
  static const List<AppMenuItem> items = [
    AppMenuItem(route: AppRoutes.dashboard, icon: Icons.space_dashboard_outlined, labelKey: 'menu.dashboard'),
    AppMenuItem(route: AppRoutes.sell, icon: Icons.point_of_sale_outlined, labelKey: 'menu.sell'),
    AppMenuItem(
      route: AppRoutes.products,
      icon: Icons.inventory_2_outlined,
      labelKey: 'menu.products',
      children: [
        AppMenuItem(route: AppRoutes.products, icon: Icons.list_alt, labelKey: 'menu.product_list'),
        AppMenuItem(route: AppRoutes.stock, icon: Icons.history, labelKey: 'menu.stock_history'),
        AppMenuItem(
          route: AppRoutes.productCategories,
          icon: Icons.category_outlined,
          labelKey: 'menu.product_categories',
        ),
      ],
    ),
    AppMenuItem(route: AppRoutes.cost, icon: Icons.calculate_outlined, labelKey: 'menu.cost'),
    AppMenuItem(
      route: AppRoutes.transactions,
      icon: Icons.account_balance_wallet_outlined,
      labelKey: 'menu.transactions',
    ),
    AppMenuItem(route: AppRoutes.invoices, icon: Icons.receipt_long_outlined, labelKey: 'menu.invoices'),
    AppMenuItem(route: AppRoutes.settings, icon: Icons.settings_outlined, labelKey: 'menu.settings'),
  ];

  static List<AppMenuItem> itemsFor({required bool useCostPage}) {
    if (useCostPage) return items;
    return items.where((item) => item.route != AppRoutes.cost).toList();
  }

  // ชื่อหน้าบนแถบบน: ใช้ชื่อเมนูย่อยถ้าอยู่ในกลุ่ม
  static String titleOf(String path) {
    for (final item in items) {
      if (!item.isSelected(path)) continue;
      return item.selectedChild(path)?.label ?? item.label;
    }
    return 'app.name'.tr;
  }
}
