import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/settings/models/company_model.dart';

void main() {
  const company = CompanyModel(
    name: 'ร้านตัวอย่าง',
    address: '1 ถนนสุขุมวิท',
    taxId: '0105555555555',
    branch: 'สำนักงานใหญ่',
    phone: '02-000-0000',
    hasLogo: true,
  );

  group('CompanyModel', () {
    test('fromJson อ่านค่าได้ถูกต้อง', () {
      final json = {
        'name': 'ร้านตัวอย่าง',
        'address': '1 ถนนสุขุมวิท',
        'tax_id': '0105555555555',
        'branch': 'สำนักงานใหญ่',
        'phone': '02-000-0000',
        'has_logo': true,
      };
      expect(CompanyModel.fromJson(json), company);
    });

    test('toJson แล้ว fromJson กลับมา ได้ค่าเดิม', () {
      expect(CompanyModel.fromJson(company.toJson()), company);
    });

    test('ไม่มี field ไหนเลย ได้ค่าว่าง ไม่ error', () {
      expect(CompanyModel.fromJson({}), const CompanyModel());
    });

    test('hasTaxId เป็น false เมื่อยังไม่กรอกเลขผู้เสียภาษี', () {
      expect(const CompanyModel(name: 'ร้าน').hasTaxId, false);
      expect(company.hasTaxId, true);
    });
  });
}
