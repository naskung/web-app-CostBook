import 'package:equatable/equatable.dart';

class CostItemModel extends Equatable {
  const CostItemModel({this.id = '', required this.type, required this.name, required this.amount});

  static const String material = 'material';
  static const String labor = 'labor';
  static const String overhead = 'overhead';
  static const List<String> types = [material, labor, overhead];

  final String id;
  final String type;
  final String name;
  final double amount;

  factory CostItemModel.fromJson(Map<String, dynamic> json) {
    return CostItemModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? material,
      name: json['name'] as String? ?? '',
      amount: (json['amount'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'name': name, 'amount': amount};
  }

  @override
  List<Object?> get props => [id, type, name, amount];
}
