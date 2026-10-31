import 'package:equatable/equatable.dart';

class CompanyModel extends Equatable {
  const CompanyModel({
    this.name = '',
    this.address = '',
    this.taxId = '',
    this.branch = '',
    this.phone = '',
    this.hasLogo = false,
    this.vatRegistered = true,
    this.pricesIncludeVat = false,
    this.useCostPage = true,
  });

  final String name;
  final String address;
  final String taxId;
  final String branch;
  final String phone;
  final bool hasLogo;
  final bool vatRegistered;
  final bool pricesIncludeVat;
  final bool useCostPage;

  bool get hasTaxId => taxId.isNotEmpty;

  bool get needsTaxId => vatRegistered && !hasTaxId;

  bool get priceHasVat => vatRegistered && pricesIncludeVat;

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      taxId: json['tax_id'] as String? ?? '',
      branch: json['branch'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      hasLogo: json['has_logo'] as bool? ?? false,
      vatRegistered: json['vat_registered'] as bool? ?? true,
      pricesIncludeVat: json['prices_include_vat'] as bool? ?? false,
      useCostPage: json['use_cost_page'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'tax_id': taxId,
      'branch': branch,
      'phone': phone,
      'has_logo': hasLogo,
      'vat_registered': vatRegistered,
      'prices_include_vat': pricesIncludeVat,
      'use_cost_page': useCostPage,
    };
  }

  @override
  List<Object?> get props => [
    name,
    address,
    taxId,
    branch,
    phone,
    hasLogo,
    vatRegistered,
    pricesIncludeVat,
    useCostPage,
  ];
}
