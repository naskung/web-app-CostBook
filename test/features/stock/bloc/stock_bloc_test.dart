import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/stock/bloc/stock_bloc.dart';
import 'package:costbook/features/stock/models/movement_model.dart';
import 'package:costbook/features/stock/models/stock_item_model.dart';
import 'package:costbook/features/stock/repository/stock_repository.dart';

class MockStockRepository extends Mock implements StockRepository {}

void main() {
  late MockStockRepository repository;

  const low = StockItemModel(productId: 'p1', name: 'กาแฟเย็น', stock: 1, minStock: 5, isLow: true);
  const ok = StockItemModel(productId: 'p2', name: 'ชาไทย', stock: 20, minStock: 5);
  final movement = MovementModel(
    id: 'm1',
    productId: 'p1',
    productName: 'กาแฟเย็น',
    type: 'in',
    quantity: 10,
    createdAt: DateTime(2026, 10, 31),
  );

  setUp(() {
    repository = MockStockRepository();
  });

  void whenSaveMovement(Future<void> Function() answer) {
    when(
      () => repository.addMovement(
        type: any(named: 'type'),
        productId: any(named: 'productId'),
        quantity: any(named: 'quantity'),
        note: any(named: 'note'),
        unitCost: any(named: 'unitCost'),
        supplier: any(named: 'supplier'),
      ),
    ).thenAnswer((_) => answer());
  }

  blocTest<StockBloc, StockState>(
    'StockRequested สำเร็จ ได้สินค้าที่นับสต็อก + ประวัติ',
    build: () {
      when(() => repository.getStock()).thenAnswer((_) async => [low, ok]);
      when(() => repository.getMovements()).thenAnswer((_) async => [movement]);
      return StockBloc(repository);
    },
    act: (bloc) => bloc.add(StockRequested()),
    expect:
        () => [
          const StockState(status: AppStatus.loading),
          StockState(status: AppStatus.success, items: const [low, ok], movements: [movement]),
        ],
  );

  blocTest<StockBloc, StockState>(
    'StockRequested แบบไม่เอาประวัติ (หน้ารายการสินค้า) ไม่โหลดประวัติ',
    build: () {
      when(() => repository.getStock()).thenAnswer((_) async => [low, ok]);
      return StockBloc(repository, withHistory: false);
    },
    act: (bloc) => bloc.add(StockRequested()),
    expect:
        () => [
          const StockState(status: AppStatus.loading),
          const StockState(status: AppStatus.success, items: [low, ok]),
        ],
    verify: (_) => verifyNever(() => repository.getMovements()),
  );

  blocTest<StockBloc, StockState>(
    'StockRequested ล้มเหลว ได้ failure พร้อม code',
    build: () {
      when(() => repository.getStock()).thenThrow(ApiException('server_error'));
      return StockBloc(repository);
    },
    act: (bloc) => bloc.add(StockRequested()),
    expect:
        () => [
          const StockState(status: AppStatus.loading),
          const StockState(status: AppStatus.failure, errorCode: 'server_error'),
        ],
  );

  blocTest<StockBloc, StockState>(
    'StockMovementSaved สำเร็จ บันทึกแล้วโหลดคงเหลือใหม่',
    build: () {
      whenSaveMovement(() async {});
      when(() => repository.getStock()).thenAnswer((_) async => [ok]);
      return StockBloc(repository, withHistory: false);
    },
    act: (bloc) => bloc.add(StockMovementSaved(type: 'in', productId: 'p2', quantity: 10, note: '')),
    expect:
        () => [
          const StockState(saveStatus: AppStatus.loading, savedType: 'in'),
          const StockState(saveStatus: AppStatus.success, savedType: 'in'),
          const StockState(status: AppStatus.success, items: [ok], saveStatus: AppStatus.success, savedType: 'in'),
        ],
    verify: (_) {
      verify(
        () => repository.addMovement(type: 'in', productId: 'p2', quantity: 10, note: '', unitCost: 0, supplier: ''),
      ).called(1);
    },
  );

  blocTest<StockBloc, StockState>(
    'StockMovementSaved เบิกเกินที่มี ได้ saveStatus failure พร้อม code stock_not_enough',
    build: () {
      whenSaveMovement(() async => throw ApiException('stock_not_enough'));
      return StockBloc(repository);
    },
    act: (bloc) => bloc.add(StockMovementSaved(type: 'out', productId: 'p1', quantity: 99, note: '')),
    expect:
        () => [
          const StockState(saveStatus: AppStatus.loading, savedType: 'out'),
          const StockState(saveStatus: AppStatus.failure, saveErrorCode: 'stock_not_enough', savedType: 'out'),
        ],
  );

  blocTest<StockBloc, StockState>(
    'StockMovementSaved รับเข้าพร้อมต้นทุนต่อหน่วยและผู้ขาย ส่งไปให้ API ครบ',
    build: () {
      whenSaveMovement(() async {});
      when(() => repository.getStock()).thenAnswer((_) async => [ok]);
      return StockBloc(repository, withHistory: false);
    },
    act:
        (bloc) => bloc.add(
          StockMovementSaved(
            type: 'in',
            productId: 'p2',
            quantity: 1000,
            note: '',
            unitCost: 0.45,
            supplier: 'ร้านเส้น',
          ),
        ),
    skip: 3,
    verify: (_) {
      verify(
        () => repository.addMovement(
          type: 'in',
          productId: 'p2',
          quantity: 1000,
          note: '',
          unitCost: 0.45,
          supplier: 'ร้านเส้น',
        ),
      ).called(1);
    },
  );

  blocTest<StockBloc, StockState>(
    'StockMovementSaved สินค้าไม่นับสต็อก ได้ saveStatus failure พร้อม code stock_not_tracked',
    build: () {
      whenSaveMovement(() async => throw ApiException('stock_not_tracked'));
      return StockBloc(repository);
    },
    act: (bloc) => bloc.add(StockMovementSaved(type: 'in', productId: 'p3', quantity: 1, note: '')),
    expect:
        () => [
          const StockState(saveStatus: AppStatus.loading, savedType: 'in'),
          const StockState(saveStatus: AppStatus.failure, saveErrorCode: 'stock_not_tracked', savedType: 'in'),
        ],
  );
}
