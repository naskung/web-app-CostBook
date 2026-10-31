import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/invoice/bloc/invoice_form_bloc.dart';
import 'package:costbook/features/invoice/models/invoice_draft_model.dart';
import 'package:costbook/features/invoice/models/invoice_model.dart';
import 'package:costbook/features/invoice/repository/invoice_repository.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/repository/product_repository.dart';
import 'package:costbook/features/settings/models/company_model.dart';
import 'package:costbook/features/settings/repository/settings_repository.dart';

class MockInvoiceRepository extends Mock implements InvoiceRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockInvoiceRepository repository;
  late MockProductRepository productRepository;
  late MockSettingsRepository settingsRepository;

  const invoice = InvoiceModel(
    id: 'i1',
    invoiceNo: 'INV-2026-0001',
    issueDate: '2026-10-31',
    status: 'issued',
    customerName: 'ลูกค้า',
    subtotal: 100,
    vat: 7,
    total: 107,
  );
  const coffee = ProductModel(id: 'p1', name: 'กาแฟเย็น', unit: 'แก้ว', sellPrice: 45, stock: 10);
  const company = CompanyModel(name: 'ร้านตัวอย่าง', taxId: '0105555555555');
  const coffeeLine = InvoiceDraftItemModel(
    productId: 'p1',
    name: 'กาแฟเย็น',
    unit: 'แก้ว',
    stock: 10,
    quantity: 1,
    unitPrice: 45,
  );
  const draft = InvoiceDraftModel(issueDate: '2026-10-31', customerName: 'ลูกค้า');
  const ready = InvoiceFormState(status: AppStatus.success, products: [coffee], company: company);

  setUpAll(() {
    registerFallbackValue(draft);
  });

  setUp(() {
    repository = MockInvoiceRepository();
    productRepository = MockProductRepository();
    settingsRepository = MockSettingsRepository();
  });

  InvoiceFormBloc buildBloc() => InvoiceFormBloc(repository, productRepository, settingsRepository);

  blocTest<InvoiceFormBloc, InvoiceFormState>(
    'InvoiceFormOpened โหลดสินค้าและข้อมูลร้าน',
    build: () {
      when(() => productRepository.getProducts()).thenAnswer((_) async => [coffee]);
      when(() => settingsRepository.getCompany()).thenAnswer((_) async => company);
      return buildBloc();
    },
    act: (bloc) => bloc.add(InvoiceFormOpened()),
    expect: () => [const InvoiceFormState(status: AppStatus.loading), ready],
  );

  blocTest<InvoiceFormBloc, InvoiceFormState>(
    'InvoiceFormOpened ต่อ server ไม่ได้ ได้ failure',
    build: () {
      when(() => productRepository.getProducts()).thenThrow(ApiException('network_error'));
      return buildBloc();
    },
    act: (bloc) => bloc.add(InvoiceFormOpened()),
    expect: () => [
      const InvoiceFormState(status: AppStatus.loading),
      const InvoiceFormState(status: AppStatus.failure, errorCode: 'network_error'),
    ],
  );

  blocTest<InvoiceFormBloc, InvoiceFormState>(
    'เพิ่มสินค้า ได้ 1 ชิ้น ราคาตั้งต้นเป็นราคาขายของสินค้า',
    build: buildBloc,
    seed: () => ready,
    act: (bloc) => bloc.add(InvoiceItemAdded('p1')),
    expect: () => [ready.copyWith(items: [coffeeLine])],
  );

  blocTest<InvoiceFormBloc, InvoiceFormState>(
    'เพิ่มสินค้าเดิมซ้ำ จำนวนเพิ่มเป็น 2 ไม่เพิ่มบรรทัดใหม่',
    build: buildBloc,
    seed: () => ready.copyWith(items: [coffeeLine]),
    act: (bloc) => bloc.add(InvoiceItemAdded('p1')),
    expect: () => [ready.copyWith(items: [coffeeLine.copyWith(quantity: 2)])],
  );

  blocTest<InvoiceFormBloc, InvoiceFormState>(
    'แก้จำนวนและราคา แล้วลบสินค้าออก',
    build: buildBloc,
    seed: () => ready.copyWith(items: [coffeeLine]),
    act: (bloc) => bloc
      ..add(InvoiceItemChanged(productId: 'p1', quantity: 4, unitPrice: 40))
      ..add(InvoiceItemRemoved('p1')),
    expect: () => [
      ready.copyWith(items: [coffeeLine.copyWith(quantity: 4, unitPrice: 40)]),
      ready,
    ],
  );

  test('ยอดรวมในฟอร์ม 2 x 50 = 100 VAT 7 รวม 107', () {
    final state = ready.copyWith(items: [coffeeLine.copyWith(quantity: 2, unitPrice: 50)]);
    expect([state.totals.subtotal, state.totals.vat, state.totals.total], [100, 7, 107]);
  });

  blocTest<InvoiceFormBloc, InvoiceFormState>(
    'InvoiceFormSubmitted สำเร็จ ส่งรายการสินค้าในฟอร์มไปด้วย และได้ใบที่ออกแล้ว',
    build: () {
      when(() => repository.createInvoice(any())).thenAnswer((_) async => invoice);
      return buildBloc();
    },
    seed: () => ready.copyWith(items: [coffeeLine]),
    act: (bloc) => bloc.add(InvoiceFormSubmitted(draft)),
    expect: () => [
      ready.copyWith(items: [coffeeLine], submitStatus: AppStatus.loading),
      ready.copyWith(items: [coffeeLine], submitStatus: AppStatus.success, createdInvoice: invoice),
    ],
    verify: (_) => verify(() => repository.createInvoice(draft.copyWith(items: [coffeeLine]))).called(1),
  );

  blocTest<InvoiceFormBloc, InvoiceFormState>(
    'InvoiceFormSubmitted ของไม่พอ ได้ submitStatus failure พร้อม code',
    build: () {
      when(() => repository.createInvoice(any())).thenThrow(ApiException('stock_not_enough'));
      return buildBloc();
    },
    seed: () => ready.copyWith(items: [coffeeLine]),
    act: (bloc) => bloc.add(InvoiceFormSubmitted(draft)),
    expect: () => [
      ready.copyWith(items: [coffeeLine], submitStatus: AppStatus.loading),
      ready.copyWith(items: [coffeeLine], submitStatus: AppStatus.failure, submitErrorCode: 'stock_not_enough'),
    ],
  );
}
