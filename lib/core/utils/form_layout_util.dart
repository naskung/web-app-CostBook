import 'package:costbook/core/constants/product_form_block.dart';

class FormLayoutUtil {
  static List<String> order(List<String> saved, List<String> fieldIds) {
    final known = {...ProductFormBlock.all, ...fieldIds};
    final result = <String>[];
    for (final key in saved) {
      if (known.contains(key) && !result.contains(key)) result.add(key);
    }
    if (!result.any(ProductFormBlock.isBlock)) result.insertAll(0, ProductFormBlock.all);
    for (final key in [...ProductFormBlock.all, ...fieldIds]) {
      if (!result.contains(key)) result.add(key);
    }
    return result;
  }

  static List<String> moved(List<String> keys, int oldIndex, int newIndex) {
    final result = [...keys];
    final key = result.removeAt(oldIndex);
    result.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, key);
    return result;
  }
}
