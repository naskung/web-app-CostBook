class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/';
  static const String products = '/products';
  static const String cost = '/cost';
  static const String stock = '/stock';
  static const String transactions = '/transactions';
  static const String invoices = '/invoices';
  static const String invoiceCreate = '/invoices/create';
  static const String invoiceDetail = '/invoices/:id';
  static const String settings = '/settings';

  static String invoiceDetailPath(String id) => '/invoices/$id';
}
