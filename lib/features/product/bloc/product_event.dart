part of 'product_bloc.dart';

abstract class ProductEvent {}

class ProductsRequested extends ProductEvent {}

class ProductSearchChanged extends ProductEvent {
  ProductSearchChanged(this.query);

  final String query;
}

// category = id ของหมวด ('' = ทุกหมวด)
class ProductCategoryChanged extends ProductEvent {
  ProductCategoryChanged(this.category);

  final String category;
}

// image = รูปใหม่ที่เลือก (null = ไม่เปลี่ยน), removeImage = กดลบรูปเดิม
// kind = '' ทั้งหมด / ProductState.kindForSale สินค้าที่ขาย / ProductState.kindMaterial วัสดุ (ไม่ขาย)
class ProductKindChanged extends ProductEvent {
  ProductKindChanged(this.kind);

  final String kind;
}

// แสดงเฉพาะสินค้าใกล้หมด (นับสต็อก และคงเหลือ ≤ ขั้นต่ำ)
class ProductLowStockFilterChanged extends ProductEvent {
  ProductLowStockFilterChanged({required this.onlyLow});

  final bool onlyLow;
}

class ProductSaved extends ProductEvent {
  ProductSaved(this.product, {this.image, this.removeImage = false});

  final ProductModel product;
  final Uint8List? image;
  final bool removeImage;
}

class ProductDeleted extends ProductEvent {
  ProductDeleted(this.id);

  final String id;
}
