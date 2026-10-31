class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/';
  static const String sell = '/sell';
  static const String products = '/products';
  static const String cost = '/cost';
  static const String stock = '/stock';
  static const String transactions = '/transactions';
  static const String invoices = '/invoices';
  static const String invoiceCreate = '/invoices/create';
  static const String invoiceDetail = '/invoices/:id';
  static const String settings = '/settings';
  static const String market = '/products/:id/market';

  static String invoiceDetailPath(String id) => '/invoices/$id';

  static String marketPath(String productId) => '/products/$productId/market';
}
