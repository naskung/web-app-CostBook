class ProductFormBlock {
  static const String image = 'image';
  static const String name = 'name';
  static const String codeCategory = 'code_category';
  static const String unit = 'unit';
  static const String prices = 'prices';
  static const String saleStock = 'sale_stock';
  static const String description = 'description';

  static const List<String> all = [image, name, codeCategory, unit, prices, saleStock, description];

  static bool isBlock(String key) => all.contains(key);
}
