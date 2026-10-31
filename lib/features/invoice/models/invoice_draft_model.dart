import 'package:equatable/equatable.dart';

import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/core/utils/tax_util.dart';

class InvoiceDraftItemModel extends Equatable {
  const InvoiceDraftItemModel({
    required this.productId,
    required this.name,
    this.unit = '',
    this.stock = 0,
    required this.quantity,
    required this.unitPrice,
  });

  final String productId;
  final String name;
  final String unit;
  final int stock;
  final int quantity;
  final double unitPrice;

  double get amount => MoneyUtil.round2(quantity * unitPrice);

  bool get isOverStock => quantity > stock;

  InvoiceDraftItemModel copyWith({int? quantity, double? unitPrice}) {
    return InvoiceDraftItemModel(
      productId: productId,
      name: name,
      unit: unit,
      stock: stock,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {'product_id': productId, 'quantity': quantity, 'unit_price': unitPrice};
  }

  @override
  List<Object?> get props => [productId, name, unit, stock, quantity, unitPrice];
}

class InvoiceDraftModel extends Equatable {
  const InvoiceDraftModel({
    required this.issueDate,
    required this.customerName,
    this.customerAddress = '',
    this.customerTaxId = '',
    this.customerBranch = '',
    this.note = '',
    this.items = const [],
  });

  final String issueDate;
  final String customerName;
  final String customerAddress;
  final String customerTaxId;
  final String customerBranch;
  final String note;
  final List<InvoiceDraftItemModel> items;

  double get subtotal => MoneyUtil.sum(items.map((item) => item.amount));

  double get vat => TaxUtil.vat(subtotal);

  double get total => TaxUtil.totalWithVat(subtotal);

  InvoiceDraftModel copyWith({List<InvoiceDraftItemModel>? items}) {
    return InvoiceDraftModel(
      issueDate: issueDate,
      customerName: customerName,
      customerAddress: customerAddress,
      customerTaxId: customerTaxId,
      customerBranch: customerBranch,
      note: note,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'issue_date': issueDate,
      'customer_name': customerName,
      'customer_address': customerAddress,
      'customer_tax_id': customerTaxId,
      'customer_branch': customerBranch,
      'note': note,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [issueDate, customerName, customerAddress, customerTaxId, customerBranch, note, items];
}
