import 'package:equatable/equatable.dart';

class ProductFieldModel extends Equatable {
  const ProductFieldModel({
    this.id = '',
    required this.name,
    required this.type,
    this.options = const [],
    this.showInList = false,
    this.sortOrder = 0,
  });

  static const String text = 'text';
  static const String number = 'number';
  static const String date = 'date';
  static const String select = 'select';
  static const List<String> types = [text, number, date, select];

  final String id;
  final String name;
  final String type;
  final List<String> options;
  final bool showInList;
  final int sortOrder;

  bool get isNew => id.isEmpty;

  factory ProductFieldModel.fromJson(Map<String, dynamic> json) {
    final options = json['options'] as List? ?? [];
    return ProductFieldModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? text,
      options: options.map((option) => option.toString()).toList(),
      showInList: json['show_in_list'] as bool? ?? false,
      sortOrder: (json['sort_order'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'type': type, 'options': options, 'show_in_list': showInList, 'sort_order': sortOrder};
  }

  @override
  List<Object?> get props => [id, name, type, options, showInList, sortOrder];
}
