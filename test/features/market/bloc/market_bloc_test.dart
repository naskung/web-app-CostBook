import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/assistant/repository/ai_repository.dart';
import 'package:costbook/features/market/bloc/market_bloc.dart';
import 'package:costbook/features/market/models/market_check_model.dart';
import 'package:costbook/features/market/repository/market_repository.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/repository/product_repository.dart';

class MockMarketRepository extends Mock implements MarketRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockAiRepository extends Mock implements AiRepository {}

void main() {
  late MockMarketRepository repository;
  late MockProductRepository productRepository;
  late MockAiRepository aiRepository;

  const phoneCase = ProductModel(id: 'p1', name: 'เคสโทรศัพท์', costPrice: 52.8, sellPrice: 250);
  const oldCheck = MarketCheckModel(id: 'm1', productId: 'p1', retailTypical: 259);
  const newCheck = MarketCheckModel(id: 'm2', productId: 'p1', retailTypical: 279);
  const loaded = MarketState(status: AppStatus.success, product: phoneCase, check: oldCheck, aiEnabled: true);

  setUp(() {
    repository = MockMarketRepository();
    productRepository = MockProductRepository();
    aiRepository = MockAiRepository();
  });

  MarketBloc buildBloc() => MarketBloc(repository, productRepository, aiRepository, productId: 'p1');

  blocTest<MarketBloc, MarketState>(
    'MarketOpened โหลดสินค้า + ผลเช็คล่าสุด + สถานะ AI',
    build: () {
      when(() => productRepository.getProduct('p1')).thenAnswer((_) async => phoneCase);
      when(() => repository.getLatest('p1')).thenAnswer((_) async => oldCheck);
      when(() => aiRepository.isEnabled()).thenAnswer((_) async => true);
      return buildBloc();
    },
    act: (bloc) => bloc.add(MarketOpened()),
    expect: () => [const MarketState(status: AppStatus.loading), loaded],
  );

  blocTest<MarketBloc, MarketState>(
    'ยังไม่เคยเช็ค ได้ check เป็น null (ไม่ใช่ error)',
    build: () {
      when(() => productRepository.getProduct('p1')).thenAnswer((_) async => phoneCase);
      when(() => repository.getLatest('p1')).thenAnswer((_) async => null);
      when(() => aiRepository.isEnabled()).thenAnswer((_) async => false);
      return buildBloc();
    },
    act: (bloc) => bloc.add(MarketOpened()),
    expect:
        () => [
          const MarketState(status: AppStatus.loading),
          const MarketState(status: AppStatus.success, product: phoneCase),
        ],
  );

  blocTest<MarketBloc, MarketState>(
    'ไม่มีสินค้านี้ ได้ failure พร้อม code',
    build: () {
      when(() => productRepository.getProduct('p1')).thenThrow(ApiException('product_not_found'));
      return buildBloc();
    },
    act: (bloc) => bloc.add(MarketOpened()),
    expect:
        () => [
          const MarketState(status: AppStatus.loading),
          const MarketState(status: AppStatus.failure, errorCode: 'product_not_found'),
        ],
  );

  blocTest<MarketBloc, MarketState>(
    'เช็คใหม่สำเร็จ ได้ผลใหม่แทนผลเดิม',
    build: () {
      when(() => repository.check('p1')).thenAnswer((_) async => newCheck);
      return buildBloc();
    },
    seed: () => loaded,
    act: (bloc) => bloc.add(MarketCheckRequested()),
    expect:
        () => [
          loaded.copyWith(checkStatus: AppStatus.loading),
          loaded.copyWith(checkStatus: AppStatus.success, check: newCheck),
        ],
  );

  blocTest<MarketBloc, MarketState>(
    'เช็คใหม่ไม่สำเร็จ ได้ checkStatus failure ผลเดิมยังอยู่',
    build: () {
      when(() => repository.check('p1')).thenThrow(ApiException('ai_not_configured'));
      return buildBloc();
    },
    seed: () => loaded,
    act: (bloc) => bloc.add(MarketCheckRequested()),
    expect:
        () => [
          loaded.copyWith(checkStatus: AppStatus.loading),
          loaded.copyWith(checkStatus: AppStatus.failure, checkErrorCode: 'ai_not_configured'),
        ],
  );

  blocTest<MarketBloc, MarketState>(
    'กดเช็คซ้ำระหว่างกำลังเช็ค ไม่ส่งซ้ำ',
    build: buildBloc,
    seed: () => loaded.copyWith(checkStatus: AppStatus.loading),
    act: (bloc) => bloc.add(MarketCheckRequested()),
    expect: () => [],
  );
}
