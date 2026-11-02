import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/invoice/bloc/invoice_form_bloc.dart';
import 'package:costbook/features/invoice/models/invoice_draft_model.dart';
import 'package:costbook/features/invoice/models/invoice_model.dart';
import 'package:costbook/features/invoice/repository/invoice_repository.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/repository/product_repository.dart';
import 'package:costbook/features/sell/pages/sell_page.dart';
import 'package:costbook/features/sell/widgets/sell_product_tile.dart';
import 'package:costbook/features/settings/models/company_model.dart';
import 'package:costbook/features/settings/repository/settings_repository.dart';

class MockInvoiceRepository extends Mock implements InvoiceRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockInvoiceRepository invoiceRepository;
  late MockProductRepository productRepository;
  late MockSettingsRepository settingsRepository;

  const keychain = ProductModel(
    id: 'p1',
    name: 'พวงกุญแจ',
    unit: 'ชิ้น',
    category: 'งานพิมพ์ 3D',
    sellPrice: 59,
    stock: 20,
  );
  const vase = ProductModel(id: 'p2', name: 'แจกัน', unit: 'ใบ', category: 'ของแต่งบ้าน', sellPrice: 290, stock: 5);
  const shop = CompanyModel(name: 'ร้าน', vatRegistered: false);
  const receipt = InvoiceModel(
    id: 'i1',
    invoiceNo: 'RC-2026-0001',
    issueDate: '2026-11-01',
    status: 'issued',
    customerName: '',
    subtotal: 118,
    vat: 0,
    total: 118,
  );

  setUpAll(() async {
    await AppLang.load('th');
    registerFallbackValue(const InvoiceDraftModel(issueDate: ''));
  });

  setUp(() {
    invoiceRepository = MockInvoiceRepository();
    productRepository = MockProductRepository();
    settingsRepository = MockSettingsRepository();
    when(() => productRepository.getProducts()).thenAnswer((_) async => [keychain, vase]);
    when(() => settingsRepository.getCompany()).thenAnswer((_) async => shop);
    when(() => invoiceRepository.createInvoice(any())).thenAnswer((_) async => receipt);
  });

  Future<void> pumpPage(WidgetTester tester, {Size size = const Size(1280, 900)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: '/sell',
      routes: [
        GoRoute(
          path: '/sell',
          builder:
              (context, state) => Scaffold(
                body: BlocProvider(
                  create:
                      (_) =>
                          InvoiceFormBloc(invoiceRepository, productRepository, settingsRepository)
                            ..add(InvoiceFormOpened()),
                  child: const SellPage(),
                ),
              ),
        ),
        GoRoute(path: '/invoices/:id', builder: (context, state) => const Text('invoice-page')),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light, routerConfig: router));
    await tester.pumpAndSettle();
  }

  Finder payButton() => find.widgetWithText(ElevatedButton, 'sell.pay'.trParams({'total': '118.00'}));

  testWidgets('จอคอม: แตะสินค้า 2 ครั้ง บิลด้านขวามี 2 ชิ้น การ์ดมีเลข 2 ปุ่มรับเงินบอกยอด', (tester) async {
    await pumpPage(tester);
    expect(find.text('sell.cart_empty'.tr), findsOneWidget);

    await tester.tap(find.text('พวงกุญแจ'));
    await tester.tap(find.text('พวงกุญแจ').first);
    await tester.pump();
    expect(find.text('sell.bill_count'.trParams({'count': '2'})), findsOneWidget);
    expect(find.text('118.00'), findsWidgets);
    expect(payButton(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('กดหมวด แสดงเฉพาะสินค้าในหมวดนั้น', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'ของแต่งบ้าน'));
    await tester.pump();
    expect(find.text('แจกัน'), findsOneWidget);
    expect(find.text('พวงกุญแจ'), findsNothing);
  });

  testWidgets('รับเงิน: เปิดหน้าต่างรับเงิน กด 500 → ยืนยัน → ออกใบ แล้วบอกเงินทอน', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('พวงกุญแจ'));
    await tester.tap(find.text('พวงกุญแจ').first);
    await tester.pump();
    await tester.tap(payButton());
    await tester.pumpAndSettle();

    expect(find.text('sell.payment_title'.tr), findsOneWidget);
    await tester.tap(find.widgetWithText(ActionChip, '500'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'sell.confirm_pay'.tr));
    await tester.pumpAndSettle();

    final draft = verify(() => invoiceRepository.createInvoice(captureAny())).captured.single as InvoiceDraftModel;
    expect(draft.items.single.quantity, 2);
    final message = 'sell.sold_message_change'.trParams({
      'no': 'RC-2026-0001',
      'total': '118.00',
      'received': '500.00',
      'change': '382.00',
    });
    expect(find.text(message), findsOneWidget);

    await tester.tap(find.text('sell.next_sale'.tr));
    await tester.pumpAndSettle();
    expect(find.text('sell.cart_empty'.tr), findsOneWidget);
  });

  testWidgets('ร้านจด VAT ยังไม่ใส่ชื่อลูกค้า กดรับเงิน → เตือนที่ช่องชื่อ ไม่เปิดหน้าต่างรับเงิน', (tester) async {
    when(
      () => settingsRepository.getCompany(),
    ).thenAnswer((_) async => const CompanyModel(name: 'ร้าน', vatRegistered: true, taxId: '0105555555555'));
    await pumpPage(tester);
    await tester.tap(find.text('พวงกุญแจ'));
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();
    expect(find.text('validation.required'.tr), findsOneWidget);
    expect(find.text('sell.payment_title'.tr), findsNothing);
  });

  testWidgets('ล้างบิล: ถามยืนยันก่อน แล้วบิลว่าง', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('พวงกุญแจ'));
    await tester.pump();
    await tester.tap(find.text('sell.clear_bill'.tr));
    await tester.pumpAndSettle();
    expect(find.text('sell.clear_title'.tr), findsOneWidget);
    await tester.tap(find.text('sell.clear_bill'.tr).last);
    await tester.pumpAndSettle();
    expect(find.text('sell.cart_empty'.tr), findsOneWidget);
  });

  testWidgets('สินค้าในบิลเยอะ ปุ่มรับเงินยังอยู่ในจอ ไม่ต้องเลื่อนหา', (tester) async {
    final many = [for (var i = 0; i < 15; i++) ProductModel(id: 'x$i', name: 'สินค้า $i', sellPrice: 10, stock: 99)];
    when(() => productRepository.getProducts()).thenAnswer((_) async => many);
    await pumpPage(tester, size: const Size(1280, 720));
    for (var i = 0; i < 15; i++) {
      final tile = find.text('สินค้า $i').first;
      await tester.ensureVisible(tile);
      await tester.pump();
      await tester.tap(tile);
    }
    await tester.pump();
    final pay = find.widgetWithText(ElevatedButton, 'sell.pay'.trParams({'total': '150.00'}));
    expect(tester.getRect(pay).bottom, lessThanOrEqualTo(720));
    expect(tester.takeException(), isNull);
  });

  testWidgets('จอ 2K 2560x1440: การ์ดสินค้าขนาดเท่าจอคอมปกติ (แถวละหลายใบขึ้น ไม่ใช่การ์ดใหญ่ขึ้น)', (tester) async {
    final many = [for (var i = 0; i < 20; i++) ProductModel(id: 'x$i', name: 'สินค้า $i', sellPrice: 10, stock: 99)];
    when(() => productRepository.getProducts()).thenAnswer((_) async => many);
    await pumpPage(tester, size: const Size(2560, 1440));
    final tileWidth = tester.getSize(find.byType(SellProductTile).first).width;
    expect(tileWidth, lessThan(AppSizes.sellTileWidth * 1.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('มือถือ: แถบล่างบอกยอด กดดูบิล บิลเลื่อนขึ้นมา กดรับเงินแล้วเปิดหน้าต่างรับเงิน', (tester) async {
    await pumpPage(tester, size: const Size(375, 800));
    await tester.tap(find.text('พวงกุญแจ'));
    await tester.tap(find.text('พวงกุญแจ').first);
    await tester.pump();
    expect(find.text('sell.bill_count'.trParams({'count': '2'})), findsOneWidget);

    await tester.tap(find.text('sell.view_bill_pay'.tr));
    await tester.pumpAndSettle();
    expect(find.text('sell.bill_title'.tr), findsOneWidget);
    await tester.tap(payButton());
    await tester.pumpAndSettle();
    expect(find.text('sell.bill_title'.tr), findsNothing);
    expect(find.text('sell.payment_title'.tr), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
