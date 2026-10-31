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

    test('ค่าตั้งต้น: จด VAT ราคาไม่รวม VAT และใช้หน้าคำนวณต้นทุน', () {
      const shop = CompanyModel();
      expect([shop.vatRegistered, shop.pricesIncludeVat, shop.useCostPage], [true, false, true]);
    });

    test('อ่านรูปแบบร้านจาก JSON ได้', () {
      final shop = CompanyModel.fromJson({'vat_registered': false, 'prices_include_vat': true, 'use_cost_page': false});
      expect([shop.vatRegistered, shop.pricesIncludeVat, shop.useCostPage], [false, true, false]);
    });

    test('needsTaxId เป็น true เฉพาะร้านที่จด VAT แต่ยังไม่กรอกเลขผู้เสียภาษี', () {
      expect(const CompanyModel(name: 'ร้าน').needsTaxId, true);
      expect(const CompanyModel(name: 'ร้าน', vatRegistered: false).needsTaxId, false);
      expect(company.needsTaxId, false);
    });

    test('priceHasVat เป็น true เฉพาะร้านที่จด VAT และตั้งราคารวม VAT แล้ว', () {
      expect(const CompanyModel(pricesIncludeVat: true).priceHasVat, true);
      expect(const CompanyModel(vatRegistered: false, pricesIncludeVat: true).priceHasVat, false);
      expect(const CompanyModel().priceHasVat, false);
    });
  });
}
