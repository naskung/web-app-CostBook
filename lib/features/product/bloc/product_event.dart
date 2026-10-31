part of 'product_bloc.dart';

abstract class ProductEvent {}

class ProductsRequested extends ProductEvent {}

class ProductSearchChanged extends ProductEvent {
  ProductSearchChanged(this.query);

  final String query;
}

class ProductCategoryChanged extends ProductEvent {
  ProductCategoryChanged(this.category);

  final String category;
}

// image = รูปใหม่ที่เลือก (null = ไม่เปลี่ยน), removeImage = กดลบรูปเดิม
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
