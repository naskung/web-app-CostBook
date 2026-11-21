import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/invoice/models/invoice_draft_model.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/repository/product_repository.dart';
import 'package:costbook/features/quotation/bloc/quotation_form_bloc.dart';
import 'package:costbook/features/quotation/models/quotation_draft_model.dart';
import 'package:costbook/features/quotation/models/quotation_model.dart';
import 'package:costbook/features/quotation/repository/quotation_repository.dart';
import 'package:costbook/features/settings/models/company_model.dart';
import 'package:costbook/features/settings/repository/settings_repository.dart';

class MockQuotationRepository extends Mock implements QuotationRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockQuotationRepository repository;
  late MockProductRepository productRepository;
  late MockSettingsRepository settingsRepository;

  const quotation = QuotationModel(
    id: 'q1',
    quotationNo: 'QT-2026-0001',
    issueDate: '2026-11-21',
    validUntil: '2026-12-21',
    status: 'issued',
    customerName: 'ลูกค้า',
    total: 107,
  );
  const soldOutTea = ProductModel(id: 'p2', name: 'ชาเย็น', unit: 'แก้ว', sellPrice: 40, stock: 0);
  const company = CompanyModel(name: 'ร้านตัวอย่าง', vatRegistered: true);
  const teaLine = InvoiceDraftItemModel(
    productId: 'p2',
    name: 'ชาเย็น',
    unit: 'แก้ว',
    stock: 0,
    quantity: 1,
    unitPrice: 40,
  );
  const draft = QuotationDraftModel(issueDate: '2026-11-21', validUntil: '2026-12-21', customerName: 'ลูกค้า');
  const ready = QuotationFormState(status: AppStatus.success, products: [soldOutTea], company: company);

  setUpAll(() {
    registerFallbackValue(draft);
  });

  setUp(() {
    repository = MockQuotationRepository();
    productRepository = MockProductRepository();
    settingsRepository = MockSettingsRepository();
  });

  QuotationFormBloc buildBloc() => QuotationFormBloc(repository, productRepository, settingsRepository);

  blocTest<QuotationFormBloc, QuotationFormState>(
    'QuotationFormOpened โหลดสินค้าและข้อมูลร้าน ไม่เอาวัสดุมาให้เลือก',
    build: () {
      const pla = ProductModel(id: 'm1', name: 'เส้น PLA', unit: 'กรัม', forSale: false);
      when(() => productRepository.getProducts()).thenAnswer((_) async => [soldOutTea, pla]);
      when(() => settingsRepository.getCompany()).thenAnswer((_) async => company);
      return buildBloc();
    },
    act: (bloc) => bloc.add(QuotationFormOpened()),
    expect: () => [const QuotationFormState(status: AppStatus.loading), ready],
  );

  blocTest<QuotationFormBloc, QuotationFormState>(
    'QuotationFormOpened โหลดไม่ได้ ได้ failure + error code',
    build: () {
      when(() => productRepository.getProducts()).thenThrow(ApiException('network_error'));
      return buildBloc();
    },
    act: (bloc) => bloc.add(QuotationFormOpened()),
    expect:
        () => [
          const QuotationFormState(status: AppStatus.loading),
          const QuotationFormState(status: AppStatus.failure, errorCode: 'network_error'),
        ],
  );

  blocTest<QuotationFormBloc, QuotationFormState>(
    'QuotationItemAdded สินค้าหมดสต็อกก็ใส่ในใบเสนอราคาได้',
    build: buildBloc,
    seed: () => ready,
    act: (bloc) => bloc.add(QuotationItemAdded('p2')),
    expect:
        () => [
          ready.copyWith(items: const [teaLine]),
        ],
  );

  blocTest<QuotationFormBloc, QuotationFormState>(
    'QuotationItemAdded สินค้าที่ไม่มีในรายการ ไม่ทำอะไร',
    build: buildBloc,
    seed: () => ready,
    act: (bloc) => bloc.add(QuotationItemAdded('p9')),
    expect: () => [],
  );

  blocTest<QuotationFormBloc, QuotationFormState>(
    'QuotationItemChanged แก้จำนวน + ราคา / QuotationItemRemoved ลบออก',
    build: buildBloc,
    seed: () => ready.copyWith(items: const [teaLine]),
    act: (bloc) {
      bloc.add(QuotationItemChanged(productId: 'p2', quantity: 3, unitPrice: 35));
      bloc.add(QuotationItemRemoved('p2'));
    },
    expect:
        () => [
          ready.copyWith(items: [teaLine.copyWith(quantity: 3, unitPrice: 35)]),
          ready.copyWith(items: const []),
        ],
  );

  test('amounts คิด VAT ตามร้าน: 2 แก้ว x 50 ลด 10 → ก่อน VAT 90 VAT 6.30 รวม 96.30', () {
    final state = ready.copyWith(
      items: const [InvoiceDraftItemModel(productId: 'p1', name: 'กาแฟ', quantity: 2, unitPrice: 50)],
      discount: 10,
    );
    final amounts = state.amounts;
    expect([amounts.subtotal, amounts.vat, amounts.total], [90, 6.3, 96.3]);
  });

  blocTest<QuotationFormBloc, QuotationFormState>(
    'QuotationFormSubmitted สำเร็จ ส่งรายการ + ส่วนลดจาก state ไปด้วย',
    build: () {
      when(() => repository.createQuotation(any())).thenAnswer((_) async => quotation);
      return buildBloc();
    },
    seed: () => ready.copyWith(items: const [teaLine], discount: 5),
    act: (bloc) => bloc.add(QuotationFormSubmitted(draft)),
    expect:
        () => [
          ready.copyWith(items: const [teaLine], discount: 5, submitStatus: AppStatus.loading),
          ready.copyWith(
            items: const [teaLine],
            discount: 5,
            submitStatus: AppStatus.success,
            createdQuotation: quotation,
          ),
        ],
    verify:
        (_) => verify(() => repository.createQuotation(draft.copyWith(items: const [teaLine], discount: 5))).called(1),
  );

  blocTest<QuotationFormBloc, QuotationFormState>(
    'QuotationFormSubmitted ล้มเหลว ได้ submitStatus failure + error code',
    build: () {
      when(() => repository.createQuotation(any())).thenThrow(ApiException('quotation_customer_required'));
      return buildBloc();
    },
    seed: () => ready.copyWith(items: const [teaLine]),
    act: (bloc) => bloc.add(QuotationFormSubmitted(draft)),
    skip: 1,
    expect:
        () => [
          ready.copyWith(
            items: const [teaLine],
            submitStatus: AppStatus.failure,
            submitErrorCode: 'quotation_customer_required',
          ),
        ],
  );
}
