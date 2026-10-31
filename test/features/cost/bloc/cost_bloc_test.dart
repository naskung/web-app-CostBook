import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/cost/bloc/cost_bloc.dart';
import 'package:costbook/features/cost/models/cost_item_model.dart';
import 'package:costbook/features/cost/models/cost_sheet_model.dart';
import 'package:costbook/features/cost/repository/cost_repository.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/repository/product_repository.dart';

class MockCostRepository extends Mock implements CostRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockCostRepository repository;
  late MockProductRepository productRepository;

  const coffee = ProductModel(id: 'p1', name: 'กาแฟเย็น');
  const beans = CostItemModel(type: 'material', name: 'เมล็ดกาแฟ', amount: 200);
  const sheet = CostSheetModel(productId: 'p1', productName: 'กาแฟเย็น', batchQuantity: 10);

  setUpAll(() {
    registerFallbackValue(sheet);
  });

  setUp(() {
    repository = MockCostRepository();
    productRepository = MockProductRepository();
  });

  CostBloc buildBloc() => CostBloc(repository, productRepository);

  blocTest<CostBloc, CostState>(
    'CostPageOpened โหลดสินค้า แล้วเปิดใบต้นทุนของสินค้าตัวแรก',
    build: () {
      when(() => productRepository.getProducts()).thenAnswer((_) async => [coffee]);
      when(() => repository.getSheet('p1')).thenAnswer((_) async => sheet);
      return buildBloc();
    },
    act: (bloc) => bloc.add(CostPageOpened()),
    expect: () => [
      const CostState(status: AppStatus.loading),
      const CostState(status: AppStatus.success, products: [coffee]),
      const CostState(status: AppStatus.success, products: [coffee], sheetStatus: AppStatus.loading),
      const CostState(status: AppStatus.success, products: [coffee], sheetStatus: AppStatus.success, sheet: sheet),
    ],
  );

  blocTest<CostBloc, CostState>(
    'CostPageOpened ไม่มีสินค้า ได้ success รายการว่าง ไม่โหลดใบต้นทุน',
    build: () {
      when(() => productRepository.getProducts()).thenAnswer((_) async => []);
      return buildBloc();
    },
    act: (bloc) => bloc.add(CostPageOpened()),
    expect: () => [
      const CostState(status: AppStatus.loading),
      const CostState(status: AppStatus.success),
    ],
    verify: (_) => verifyNever(() => repository.getSheet(any())),
  );

  blocTest<CostBloc, CostState>(
    'CostPageOpened ต่อ server ไม่ได้ ได้ failure',
    build: () {
      when(() => productRepository.getProducts()).thenThrow(ApiException('network_error'));
      return buildBloc();
    },
    act: (bloc) => bloc.add(CostPageOpened()),
    expect: () => [
      const CostState(status: AppStatus.loading),
      const CostState(status: AppStatus.failure, errorCode: 'network_error'),
    ],
  );

  blocTest<CostBloc, CostState>(
    'เพิ่มรายการต้นทุน ใบต้นทุนมีรายการใหม่ และขึ้นว่ายังไม่บันทึก',
    build: buildBloc,
    seed: () => const CostState(status: AppStatus.success, sheet: sheet),
    act: (bloc) => bloc.add(CostItemAdded(beans)),
    expect: () => [
      CostState(status: AppStatus.success, sheet: sheet.copyWith(items: [beans]), isDirty: true),
    ],
  );

  blocTest<CostBloc, CostState>(
    'ลบรายการต้นทุนที่ซ้ำกัน ลบออกแค่ 1 รายการ',
    build: buildBloc,
    seed: () => CostState(status: AppStatus.success, sheet: sheet.copyWith(items: [beans, beans])),
    act: (bloc) => bloc.add(CostItemRemoved(beans)),
    expect: () => [
      CostState(status: AppStatus.success, sheet: sheet.copyWith(items: [beans]), isDirty: true),
    ],
  );

  blocTest<CostBloc, CostState>(
    'markup 50% จากต้นทุน 20 (200 ÷ 10) ได้ราคาขาย 30',
    build: buildBloc,
    seed: () => CostState(status: AppStatus.success, sheet: sheet.copyWith(items: [beans])),
    act: (bloc) => bloc.add(CostMarkupApplied(50)),
    expect: () => [
      CostState(status: AppStatus.success, sheet: sheet.copyWith(items: [beans], sellPrice: 30), isDirty: true),
    ],
  );

  blocTest<CostBloc, CostState>(
    'แก้จำนวนผลิตต่อรอบ และราคาขาย',
    build: buildBloc,
    seed: () => const CostState(status: AppStatus.success, sheet: sheet),
    act: (bloc) => bloc
      ..add(CostBatchQuantityChanged(25))
      ..add(CostSellPriceChanged(45)),
    expect: () => [
      CostState(status: AppStatus.success, sheet: sheet.copyWith(batchQuantity: 25), isDirty: true),
      CostState(status: AppStatus.success, sheet: sheet.copyWith(batchQuantity: 25, sellPrice: 45), isDirty: true),
    ],
  );

  blocTest<CostBloc, CostState>(
    'CostSheetSaved สำเร็จ ได้ใบต้นทุนจาก API และไม่ขึ้นว่ายังไม่บันทึก',
    build: () {
      when(() => repository.saveSheet(any())).thenAnswer((_) async => sheet.copyWith(items: [beans]));
      return buildBloc();
    },
    seed: () => CostState(status: AppStatus.success, sheet: sheet.copyWith(items: [beans]), isDirty: true),
    act: (bloc) => bloc.add(CostSheetSaved()),
    expect: () => [
      CostState(
        status: AppStatus.success,
        sheet: sheet.copyWith(items: [beans]),
        isDirty: true,
        saveStatus: AppStatus.loading,
      ),
      CostState(status: AppStatus.success, sheet: sheet.copyWith(items: [beans]), saveStatus: AppStatus.success),
    ],
  );

  blocTest<CostBloc, CostState>(
    'CostSheetSaved จำนวนผลิต 0 ได้ saveStatus failure พร้อม code',
    build: () {
      when(() => repository.saveSheet(any())).thenThrow(ApiException('cost_batch_quantity_invalid'));
      return buildBloc();
    },
    seed: () => const CostState(status: AppStatus.success, sheet: sheet),
    act: (bloc) => bloc.add(CostSheetSaved()),
    expect: () => [
      const CostState(status: AppStatus.success, sheet: sheet, saveStatus: AppStatus.loading),
      const CostState(
        status: AppStatus.success,
        sheet: sheet,
        saveStatus: AppStatus.failure,
        saveErrorCode: 'cost_batch_quantity_invalid',
      ),
    ],
  );
}
