class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/';
  static const String sell = '/sell';
  static const String products = '/products';
  static const String productCategories = '/products/categories';
  // หน้ารายการสินค้าแบบกรองเฉพาะใกล้หมด
  static const String lowStockProducts = '/products?low=1';
  static const String cost = '/cost';
  static const String stock = '/stock';
  static const String transactions = '/transactions';
  static const String invoices = '/invoices';
  static const String invoiceCreate = '/invoices/create';
  static const String invoiceDetail = '/invoices/:id';
  static const String settings = '/settings';
  static const String market = '/products/:id/market';
  static const String profile = '/profile';
  // จัดการผู้ใช้ (เจ้าของร้าน) อยู่ใต้หน้าโปรไฟล์ — เมนูข้างไฮไลต์แถวผู้ใช้ให้
  static const String users = '/profile/users';

  static String invoiceDetailPath(String id) => '/invoices/$id';

  static String marketPath(String productId) => '/products/$productId/market';
}
