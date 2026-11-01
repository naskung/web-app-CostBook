part of 'category_bloc.dart';

abstract class CategoryEvent {}

class CategoriesRequested extends CategoryEvent {}

// เลื่อนใกล้ล่างสุด / กดลองใหม่ → โหลดหน้าต่อไป
class CategoriesMoreRequested extends CategoryEvent {}

class CategorySaved extends CategoryEvent {
  CategorySaved(this.category);

  final ProductCategoryModel category;
}

class CategoryDeleted extends CategoryEvent {
  CategoryDeleted(this.id);

  final String id;
}
