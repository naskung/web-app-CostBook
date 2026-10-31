import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_routes.dart';

class AppMenuItem {
  const AppMenuItem({required this.route, required this.icon, required this.labelKey});

  final String route;
  final IconData icon;
  final String labelKey;

  String get label => labelKey.tr;

  bool isSelected(String path) {
    if (path == route) return true;
    if (route == AppRoutes.dashboard) return false;
    return path.startsWith('$route/');
  }
}

class AppMenu {
  static const List<AppMenuItem> items = [
    AppMenuItem(route: AppRoutes.dashboard, icon: Icons.space_dashboard_outlined, labelKey: 'menu.dashboard'),
    AppMenuItem(route: AppRoutes.sell, icon: Icons.point_of_sale_outlined, labelKey: 'menu.sell'),
    AppMenuItem(route: AppRoutes.products, icon: Icons.inventory_2_outlined, labelKey: 'menu.products'),
    AppMenuItem(route: AppRoutes.cost, icon: Icons.calculate_outlined, labelKey: 'menu.cost'),
    AppMenuItem(route: AppRoutes.stock, icon: Icons.warehouse_outlined, labelKey: 'menu.stock'),
    AppMenuItem(
      route: AppRoutes.transactions,
      icon: Icons.account_balance_wallet_outlined,
      labelKey: 'menu.transactions',
    ),
    AppMenuItem(route: AppRoutes.invoices, icon: Icons.receipt_long_outlined, labelKey: 'menu.invoices'),
    AppMenuItem(route: AppRoutes.assistant, icon: Icons.auto_awesome_outlined, labelKey: 'menu.assistant'),
    AppMenuItem(route: AppRoutes.settings, icon: Icons.settings_outlined, labelKey: 'menu.settings'),
  ];

  static List<AppMenuItem> itemsFor({required bool useCostPage}) {
    if (useCostPage) return items;
    return items.where((item) => item.route != AppRoutes.cost).toList();
  }

  static String titleOf(String path) {
    for (final item in items) {
      if (item.isSelected(path)) return item.label;
    }
    return 'app.name'.tr;
  }
}
