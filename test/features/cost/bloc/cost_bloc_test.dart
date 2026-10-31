import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/cost/bloc/cost_bloc.dart';
import 'package:costbook/features/cost/models/cost_item_model.dart';
import 'package:costbook/features/cost/models/cost_preset_model.dart';
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
  const beans = CostItemModel(type: 'material', name: 'เมล็ดกาแฟ', quantity: 1, unitPrice: 200);
  const preset = CostPresetModel(id: 'pr1', type: 'material', name: 'เมล็ดกาแฟ', unitPrice: 200);
  const editedPreset = CostPresetModel(id: 'pr1', type: 'material', name: 'เมล็ดกาแฟ', unitPrice: 250);
  const sheet = CostSheetModel(productId: 'p1', productName: 'กาแฟเย็น', batchQuantity: 10);

  setUpAll(() {
    registerFallbackValue(sheet);
    registerFallbackValue(preset);
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
      when(() => repository.getPresets()).thenAnswer((_) async => [preset]);
      when(() => repository.getSheet('p1')).thenAnswer((_) async => sheet);
      return buildBloc();
    },
    act: (bloc) => bloc.add(CostPageOpened()),
    expect:
        () => [
          const CostState(status: AppStatus.loading),
          const CostState(status: AppStatus.success, products: [coffee], presets: [preset]),
          const CostState(
            status: AppStatus.success,
            products: [coffee],
            presets: [preset],
            sheetStatus: AppStatus.loading,
          ),
          const CostState(
            status: AppStatus.success,
            products: [coffee],
            presets: [preset],
            sheetStatus: AppStatus.success,
            sheet: sheet,
          ),
        ],
  );

  blocTest<CostBloc, CostState>(
    'CostPageOpened ไม่มีสินค้า ได้ success รายการว่าง ไม่โหลดใบต้นทุน',
    build: () {
      when(() => productRepository.getProducts()).thenAnswer((_) async => []);
      when(() => repository.getPresets()).thenAnswer((_) async => []);
      return buildBloc();
    },
    act: (bloc) => bloc.add(CostPageOpened()),
    expect: () => [const CostState(status: AppStatus.loading), const CostState(status: AppStatus.success)],
    verify: (_) => verifyNever(() => repository.getSheet(any())),
  );

  blocTest<CostBloc, CostState>(
    'CostPageOpened ต่อ server ไม่ได้ ได้ failure',
    build: () {
      when(() => productRepository.getProducts()).thenThrow(ApiException('network_error'));
      return buildBloc();
    },
    act: (bloc) => bloc.add(CostPageOpened()),
    expect:
        () => [
          const CostState(status: AppStatus.loading),
          const CostState(status: AppStatus.failure, errorCode: 'network_error'),
        ],
  );

  blocTest<CostBloc, CostState>(
    'เพิ่มรายการต้นทุน ใบต้นทุนมีรายการใหม่ และขึ้นว่ายังไม่บันทึก',
    build: buildBloc,
    seed: () => const CostState(status: AppStatus.success, sheet: sheet),
    act: (bloc) => bloc.add(CostItemAdded(beans)),
    expect:
        () => [
          CostState(status: AppStatus.success, sheet: sheet.copyWith(items: [beans]), isDirty: true),
        ],
  );

  blocTest<CostBloc, CostState>(
    'ลบรายการต้นทุนที่ซ้ำกัน ลบออกแค่ 1 รายการ',
    build: buildBloc,
    seed: () => CostState(status: AppStatus.success, sheet: sheet.copyWith(items: [beans, beans])),
    act: (bloc) => bloc.add(CostItemRemoved(beans)),
    expect:
        () => [
          CostState(status: AppStatus.success, sheet: sheet.copyWith(items: [beans]), isDirty: true),
        ],
  );

  blocTest<CostBloc, CostState>(
    'markup 50% จากต้นทุน 20 (200 ÷ 10) ได้ราคาขาย 30',
    build: buildBloc,
    seed: () => CostState(status: AppStatus.success, sheet: sheet.copyWith(items: [beans])),
    act: (bloc) => bloc.add(CostMarkupApplied(50)),
    expect:
        () => [
          CostState(status: AppStatus.success, sheet: sheet.copyWith(items: [beans], sellPrice: 30), isDirty: true),
        ],
  );

  blocTest<CostBloc, CostState>(
    'ร้านตั้งราคารวม VAT: markup 50% จากต้นทุน 20 ได้ 30 บวก VAT เป็นราคาขาย 32.10',
    build: buildBloc,
    seed: () => CostState(status: AppStatus.success, sheet: sheet.copyWith(items: [beans])),
    act: (bloc) => bloc.add(CostMarkupApplied(50, priceHasVat: true)),
    expect:
        () => [
          CostState(status: AppStatus.success, sheet: sheet.copyWith(items: [beans], sellPrice: 32.1), isDirty: true),
        ],
  );

  blocTest<CostBloc, CostState>(
    'แก้จำนวนผลิตต่อรอบ และราคาขาย',
    build: buildBloc,
    seed: () => const CostState(status: AppStatus.success, sheet: sheet),
    act:
        (bloc) =>
            bloc
              ..add(CostBatchQuantityChanged(25))
              ..add(CostSellPriceChanged(45)),
    expect:
        () => [
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
    expect:
        () => [
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
    expect:
        () => [
          const CostState(status: AppStatus.success, sheet: sheet, saveStatus: AppStatus.loading),
          const CostState(
            status: AppStatus.success,
            sheet: sheet,
            saveStatus: AppStatus.failure,
            saveErrorCode: 'cost_batch_quantity_invalid',
          ),
        ],
  );

  blocTest<CostBloc, CostState>(
    'แก้บรรทัดต้นทุน แทนที่บรรทัดเดิมในตำแหน่งเดิม',
    build: buildBloc,
    seed: () => CostState(status: AppStatus.success, sheet: sheet.copyWith(items: [beans])),
    act:
        (bloc) => bloc.add(
          CostItemChanged(
            oldItem: beans,
            newItem: const CostItemModel(type: 'material', name: 'เมล็ดกาแฟ', quantity: 2, unitPrice: 200),
          ),
        ),
    expect:
        () => [
          CostState(
            status: AppStatus.success,
            sheet: sheet.copyWith(
              items: [const CostItemModel(type: 'material', name: 'เมล็ดกาแฟ', quantity: 2, unitPrice: 200)],
            ),
            isDirty: true,
          ),
        ],
  );

  blocTest<CostBloc, CostState>(
    'CostPresetSaved บันทึกแล้วโหลดรายการที่ใช้บ่อยใหม่',
    build: () {
      when(() => repository.savePreset(any())).thenAnswer((_) async {});
      when(() => repository.getPresets()).thenAnswer((_) async => [preset]);
      return buildBloc();
    },
    act: (bloc) => bloc.add(CostPresetSaved(CostPresetModel.fromItem(beans))),
    expect:
        () => [
          const CostState(presets: [preset]),
        ],
  );

  blocTest<CostBloc, CostState>(
    'CostPresetSaved รายการที่มี id = แก้รายการเดิม แล้วได้ราคาใหม่',
    build: () {
      when(() => repository.savePreset(any())).thenAnswer((_) async {});
      when(() => repository.getPresets()).thenAnswer((_) async => [editedPreset]);
      return buildBloc();
    },
    seed: () => const CostState(presets: [preset]),
    act: (bloc) => bloc.add(CostPresetSaved(editedPreset)),
    expect:
        () => [
          const CostState(presets: [editedPreset]),
        ],
    verify: (_) => verify(() => repository.savePreset(editedPreset)).called(1),
  );

  blocTest<CostBloc, CostState>(
    'CostPresetSaved ไม่สำเร็จ ได้ presetErrorCode รายการเดิมยังอยู่',
    build: () {
      when(() => repository.savePreset(any())).thenThrow(ApiException('cost_preset_not_found'));
      return buildBloc();
    },
    seed: () => const CostState(presets: [preset]),
    act: (bloc) => bloc.add(CostPresetSaved(preset)),
    expect:
        () => [
          const CostState(presets: [preset], presetErrorCode: 'cost_preset_not_found'),
        ],
  );

  blocTest<CostBloc, CostState>(
    'CostPresetSaved สำเร็จหลังเคยพัง ล้าง presetErrorCode',
    build: () {
      when(() => repository.savePreset(any())).thenAnswer((_) async {});
      when(() => repository.getPresets()).thenAnswer((_) async => [preset]);
      return buildBloc();
    },
    seed: () => const CostState(presetErrorCode: 'server_error'),
    act: (bloc) => bloc.add(CostPresetSaved(preset)),
    expect:
        () => [
          const CostState(presets: [preset]),
        ],
  );

  blocTest<CostBloc, CostState>(
    'CostPresetDeleted ไม่สำเร็จ ได้ presetErrorCode รายการยังไม่หาย',
    build: () {
      when(() => repository.deletePreset('pr1')).thenThrow(ApiException('server_error'));
      return buildBloc();
    },
    seed: () => const CostState(presets: [preset]),
    act: (bloc) => bloc.add(CostPresetDeleted('pr1')),
    expect:
        () => [
          const CostState(presets: [preset], presetErrorCode: 'server_error'),
        ],
  );

  blocTest<CostBloc, CostState>(
    'CostPresetDeleted ลบแล้วรายการหายไป',
    build: () {
      when(() => repository.deletePreset('pr1')).thenAnswer((_) async {});
      return buildBloc();
    },
    seed: () => const CostState(presets: [preset]),
    act: (bloc) => bloc.add(CostPresetDeleted('pr1')),
    expect: () => [const CostState()],
  );
}
