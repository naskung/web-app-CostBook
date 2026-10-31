import 'package:equatable/equatable.dart';

import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/core/utils/tax_util.dart';
import 'package:costbook/features/product/models/product_model.dart';

class InvoiceDraftItemModel extends Equatable {
  const InvoiceDraftItemModel({
    required this.productId,
    required this.name,
    this.unit = '',
    this.stock = 0,
    this.trackStock = true,
    required this.quantity,
    required this.unitPrice,
  });

  factory InvoiceDraftItemModel.fromProduct(ProductModel product) {
    return InvoiceDraftItemModel(
      productId: product.id,
      name: product.name,
      unit: product.unit,
      stock: product.stock,
      trackStock: product.trackStock,
      quantity: 1,
      unitPrice: product.sellPrice,
    );
  }

  final String productId;
  final String name;
  final String unit;
  final int stock;
  final bool trackStock;
  final int quantity;
  final double unitPrice;

  double get amount => MoneyUtil.round2(quantity * unitPrice);

  bool get isOverStock => trackStock && quantity > stock;

  InvoiceDraftItemModel copyWith({int? quantity, double? unitPrice}) {
    return InvoiceDraftItemModel(
      productId: productId,
      name: name,
      unit: unit,
      stock: stock,
      trackStock: trackStock,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {'product_id': productId, 'quantity': quantity, 'unit_price': unitPrice};
  }

  @override
  List<Object?> get props => [productId, name, unit, stock, trackStock, quantity, unitPrice];
}

class InvoiceDraftModel extends Equatable {
  const InvoiceDraftModel({
    required this.issueDate,
    this.customerName = '',
    this.customerAddress = '',
    this.customerTaxId = '',
    this.customerBranch = '',
    this.note = '',
    this.discount = 0,
    this.items = const [],
  });

  final String issueDate;
  final String customerName;
  final String customerAddress;
  final String customerTaxId;
  final String customerBranch;
  final String note;
  final double discount;
  final List<InvoiceDraftItemModel> items;

  double get itemsTotal => MoneyUtil.sum(items.map((item) => item.amount));

  DocumentAmounts amounts({required bool vatRegistered, required bool pricesIncludeVat}) {
    return TaxUtil.documentAmounts(
      itemsTotal: itemsTotal,
      discount: discount,
      vatRegistered: vatRegistered,
      pricesIncludeVat: pricesIncludeVat,
    );
  }

  InvoiceDraftModel copyWith({List<InvoiceDraftItemModel>? items, double? discount}) {
    return InvoiceDraftModel(
      issueDate: issueDate,
      customerName: customerName,
      customerAddress: customerAddress,
      customerTaxId: customerTaxId,
      customerBranch: customerBranch,
      note: note,
      discount: discount ?? this.discount,
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
      'discount': discount,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    issueDate,
    customerName,
    customerAddress,
    customerTaxId,
    customerBranch,
    note,
    discount,
    items,
  ];
}
