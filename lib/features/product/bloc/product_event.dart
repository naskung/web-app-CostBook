part of 'product_bloc.dart';

abstract class ProductEvent {}

class ProductsRequested extends ProductEvent {}

class ProductSearchChanged extends ProductEvent {
  ProductSearchChanged(this.query);

  final String query;
}

class ProductSaved extends ProductEvent {
  ProductSaved(this.product);

  final ProductModel product;
}

class ProductDeleted extends ProductEvent {
  ProductDeleted(this.id);

  final String id;
}
