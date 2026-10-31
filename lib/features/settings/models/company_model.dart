import 'package:equatable/equatable.dart';

class CompanyModel extends Equatable {
  const CompanyModel({
    this.name = '',
    this.address = '',
    this.taxId = '',
    this.branch = '',
    this.phone = '',
    this.hasLogo = false,
  });

  final String name;
  final String address;
  final String taxId;
  final String branch;
  final String phone;
  final bool hasLogo;

  bool get hasTaxId => taxId.isNotEmpty;

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      taxId: json['tax_id'] as String? ?? '',
      branch: json['branch'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      hasLogo: json['has_logo'] as bool? ?? false,
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
    };
  }

  @override
  List<Object?> get props => [name, address, taxId, branch, phone, hasLogo];
}
