import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/assistant/bloc/assistant_bloc.dart';
import 'package:costbook/features/assistant/models/ai_action_model.dart';
import 'package:costbook/features/assistant/models/ai_status_model.dart';
import 'package:costbook/features/assistant/models/chat_message_model.dart';
import 'package:costbook/features/assistant/repository/ai_repository.dart';
import 'package:costbook/features/market/models/market_check_model.dart';
import 'package:costbook/features/market/repository/market_repository.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/repository/product_repository.dart';
import 'package:costbook/features/stock/repository/stock_repository.dart';
import 'package:costbook/features/transaction/models/transaction_model.dart';
import 'package:costbook/features/transaction/repository/transaction_repository.dart';

class MockAiRepository extends Mock implements AiRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockStockRepository extends Mock implements StockRepository {}

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockMarketRepository extends Mock implements MarketRepository {}

void main() {
  late MockAiRepository aiRepository;
  late MockProductRepository productRepository;
  late MockStockRepository stockRepository;
  late MockTransactionRepository transactionRepository;
  late MockMarketRepository marketRepository;

  const ask = ChatMessageModel(role: ChatMessageModel.user, text: 'รับเคสเข้า 10 ชิ้น');
  const stockIn = AiActionModel(
    id: 't1',
    type: AiActionModel.stockIn,
    productId: 'p1',
    productName: 'เคส',
    data: {'product_id': 'p1', 'quantity': 10, 'unit_cost': 50, 'supplier': 'ร้านเส้น', 'note': ''},
  );
  const reply = ChatMessageModel(role: ChatMessageModel.assistant, text: 'กดยืนยันได้เลย', actions: [stockIn]);
  const free = AiStatusModel(enabled: true, provider: AiStatusModel.gemini, freeAvailable: true);
  const claude = AiStatusModel(
    enabled: true,
    provider: AiStatusModel.claude,
    webSearch: true,
    hasOwnKey: true,
    keyHint: '…a1B2',
  );
  const ready = AssistantState(status: AppStatus.success, ai: free);
  const proposed = AssistantState(status: AppStatus.success, ai: free, messages: [ask, reply]);

  setUpAll(() {
    registerFallbackValue(<ChatMessageModel>[]);
    registerFallbackValue(const ProductModel(name: ''));
    registerFallbackValue(const TransactionModel(type: 'expense', category: 'rent', amount: 1, date: '2026-10-31'));
  });

  setUp(() {
    aiRepository = MockAiRepository();
    productRepository = MockProductRepository();
    stockRepository = MockStockRepository();
    transactionRepository = MockTransactionRepository();
    marketRepository = MockMarketRepository();
  });

  AssistantBloc buildBloc() => AssistantBloc(
    aiRepository: aiRepository,
    productRepository: productRepository,
    stockRepository: stockRepository,
    transactionRepository: transactionRepository,
    marketRepository: marketRepository,
  );

  ChatMessageModel noteOf(AiActionModel action) {
    return ChatMessageModel(role: ChatMessageModel.note, text: action.resultNote);
  }

  void whenAddMovement(Future<void> Function() answer) {
    when(
      () => stockRepository.addMovement(
        type: any(named: 'type'),
        productId: any(named: 'productId'),
        quantity: any(named: 'quantity'),
        note: any(named: 'note'),
        unitCost: any(named: 'unitCost'),
        supplier: any(named: 'supplier'),
      ),
    ).thenAnswer((_) => answer());
  }

  blocTest<AssistantBloc, AssistantState>(
    'AssistantOpened เช็คว่าเปิด AI ได้ไหม',
    build: () {
      when(() => aiRepository.getStatus()).thenAnswer((_) async => free);
      return buildBloc();
    },
    act: (bloc) => bloc.add(AssistantOpened()),
    expect: () => [const AssistantState(status: AppStatus.loading), ready],
  );

  blocTest<AssistantBloc, AssistantState>(
    'AssistantOpened ต่อ server ไม่ได้ ได้ failure',
    build: () {
      when(() => aiRepository.getStatus()).thenThrow(ApiException('network_error'));
      return buildBloc();
    },
    act: (bloc) => bloc.add(AssistantOpened()),
    expect:
        () => [
          const AssistantState(status: AppStatus.loading),
          const AssistantState(status: AppStatus.failure, errorCode: 'network_error'),
        ],
  );

  blocTest<AssistantBloc, AssistantState>(
    'กลับมาหน้าแชทอีกครั้ง ไม่โหลดใหม่ (แชทเดิมยังอยู่)',
    build: buildBloc,
    seed: () => proposed,
    act: (bloc) => bloc.add(AssistantOpened()),
    expect: () => [],
  );

  blocTest<AssistantBloc, AssistantState>(
    'ส่งคำถาม ได้คำตอบ + งานที่ AI เสนอ',
    build: () {
      when(() => aiRepository.chat(any())).thenAnswer((_) async => reply);
      return buildBloc();
    },
    seed: () => ready,
    act: (bloc) => bloc.add(AssistantMessageSent('  รับเคสเข้า 10 ชิ้น  ')),
    expect:
        () => [
          ready.copyWith(messages: [ask], sendStatus: AppStatus.loading),
          ready.copyWith(messages: [ask, reply], sendStatus: AppStatus.success, hasUnread: true),
        ],
    verify: (_) => verify(() => aiRepository.chat([ask])).called(1),
  );

  blocTest<AssistantBloc, AssistantState>(
    'ส่งไม่สำเร็จ ได้ error คำถามยังอยู่ กดลองใหม่แล้วส่งคำถามเดิม',
    build: () {
      var calls = 0;
      when(() => aiRepository.chat(any())).thenAnswer((_) async {
        calls++;
        if (calls == 1) throw ApiException('ai_busy');
        return reply;
      });
      return buildBloc();
    },
    seed: () => ready,
    act: (bloc) async {
      bloc.add(AssistantMessageSent('รับเคสเข้า 10 ชิ้น'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(AssistantRetried());
    },
    expect:
        () => [
          ready.copyWith(messages: [ask], sendStatus: AppStatus.loading),
          ready.copyWith(messages: [ask], sendStatus: AppStatus.failure, errorCode: 'ai_busy'),
          ready.copyWith(messages: [ask], sendStatus: AppStatus.loading),
          ready.copyWith(messages: [ask, reply], sendStatus: AppStatus.success, hasUnread: true),
        ],
  );

  blocTest<AssistantBloc, AssistantState>(
    'ข้อความว่าง ไม่ส่ง',
    build: buildBloc,
    seed: () => ready,
    act: (bloc) => bloc.add(AssistantMessageSent('   ')),
    expect: () => [],
  );

  blocTest<AssistantBloc, AssistantState>(
    'กดยืนยันรับเข้า: เรียก API รับเข้าด้วยข้อมูลที่ AI เสนอ แล้วจดผลไว้บอก AI',
    build: () {
      whenAddMovement(() async {});
      return buildBloc();
    },
    seed: () => proposed,
    act: (bloc) => bloc.add(AssistantActionConfirmed('t1')),
    expect: () {
      final running = stockIn.copyWith(status: AiActionModel.running);
      final done = stockIn.copyWith(status: AiActionModel.done);
      return [
        proposed.copyWith(
          messages: [
            ask,
            reply.copyWith(actions: [running]),
          ],
        ),
        proposed.copyWith(
          messages: [
            ask,
            reply.copyWith(actions: [done]),
            noteOf(done),
          ],
        ),
      ];
    },
    verify: (_) {
      verify(
        () => stockRepository.addMovement(
          type: 'in',
          productId: 'p1',
          quantity: 10,
          note: '',
          unitCost: 50,
          supplier: 'ร้านเส้น',
        ),
      ).called(1);
    },
  );

  blocTest<AssistantBloc, AssistantState>(
    'กดยืนยันแล้วทำไม่สำเร็จ ได้สถานะ failed พร้อม code',
    build: () {
      whenAddMovement(() async => throw ApiException('stock_not_tracked'));
      return buildBloc();
    },
    seed: () => proposed,
    act: (bloc) => bloc.add(AssistantActionConfirmed('t1')),
    skip: 1,
    expect: () {
      final failed = stockIn.copyWith(status: AiActionModel.failed, errorCode: 'stock_not_tracked');
      return [
        proposed.copyWith(
          messages: [
            ask,
            reply.copyWith(actions: [failed]),
            noteOf(failed),
          ],
        ),
      ];
    },
  );

  blocTest<AssistantBloc, AssistantState>(
    'กดยืนยันแก้สินค้า: บันทึกสินค้าด้วย id ของสินค้าเดิม (แก้ ไม่ใช่เพิ่มใหม่)',
    build: () {
      when(() => productRepository.saveProduct(any())).thenAnswer((_) async => const ProductModel(name: 'เคส'));
      return buildBloc();
    },
    seed: () {
      const update = AiActionModel(
        id: 't2',
        type: AiActionModel.updateProduct,
        productId: 'p1',
        data: {'name': 'เคส', 'sell_price': 290, 'unit': 'ชิ้น'},
      );
      return proposed.copyWith(
        messages: [
          ask,
          reply.copyWith(actions: [update]),
        ],
      );
    },
    act: (bloc) => bloc.add(AssistantActionConfirmed('t2')),
    verify: (_) {
      final saved = verify(() => productRepository.saveProduct(captureAny())).captured.single as ProductModel;
      expect([saved.id, saved.sellPrice, saved.isNew], ['p1', 290, false]);
    },
  );

  blocTest<AssistantBloc, AssistantState>(
    'กดยืนยันเพิ่มสินค้าใหม่ / บันทึกรายจ่าย / เช็คตลาด เรียก repository ที่ถูกตัว',
    build: () {
      when(() => productRepository.saveProduct(any())).thenAnswer((_) async => const ProductModel(name: 'ใหม่'));
      when(() => transactionRepository.saveTransaction(any())).thenAnswer((_) async {});
      when(
        () => marketRepository.check('p1'),
      ).thenAnswer((_) async => const MarketCheckModel(id: 'm1', productId: 'p1'));
      return buildBloc();
    },
    seed: () {
      const actions = [
        AiActionModel(id: 'a', type: AiActionModel.createProduct, data: {'name': 'พวงกุญแจ', 'sell_price': 89}),
        AiActionModel(
          id: 'b',
          type: AiActionModel.addTransaction,
          data: {'type': 'expense', 'category': 'rent', 'amount': 5000, 'date': '2026-10-31', 'note': ''},
        ),
        AiActionModel(id: 'c', type: AiActionModel.marketCheck, productId: 'p1'),
      ];
      return proposed.copyWith(messages: [ask, reply.copyWith(actions: actions)]);
    },
    act: (bloc) async {
      for (final id in ['a', 'b', 'c']) {
        bloc.add(AssistantActionConfirmed(id));
        await Future<void>.delayed(Duration.zero);
      }
    },
    verify: (bloc) {
      final product = verify(() => productRepository.saveProduct(captureAny())).captured.single as ProductModel;
      expect([product.isNew, product.name], [true, 'พวงกุญแจ']);
      final saved = verify(() => transactionRepository.saveTransaction(captureAny())).captured.single;
      expect((saved as TransactionModel).amount, 5000);
      verify(() => marketRepository.check('p1')).called(1);
      expect(bloc.state.messages.where((message) => message.isNote).length, 3);
    },
  );

  blocTest<AssistantBloc, AssistantState>(
    'กดไม่เอา: ได้สถานะ cancelled ไม่เรียก API',
    build: buildBloc,
    seed: () => proposed,
    act: (bloc) => bloc.add(AssistantActionCancelled('t1')),
    expect: () {
      final cancelled = stockIn.copyWith(status: AiActionModel.cancelled);
      return [
        proposed.copyWith(
          messages: [
            ask,
            reply.copyWith(actions: [cancelled]),
            noteOf(cancelled),
          ],
        ),
      ];
    },
  );

  blocTest<AssistantBloc, AssistantState>(
    'กดยืนยันงานที่ทำไปแล้วซ้ำ ไม่ทำซ้ำ',
    build: buildBloc,
    seed:
        () => proposed.copyWith(
          messages: [
            ask,
            reply.copyWith(actions: [stockIn.copyWith(status: AiActionModel.done)]),
          ],
        ),
    act: (bloc) => bloc.add(AssistantActionConfirmed('t1')),
    expect: () => [],
  );

  test('visibleMessages ไม่แสดงข้อความ note', () {
    const state = AssistantState(messages: [ask, reply, ChatMessageModel(role: ChatMessageModel.note, text: 'x')]);
    expect(state.visibleMessages, [ask, reply]);
  });

  blocTest<AssistantBloc, AssistantState>(
    'เริ่มแชทใหม่ ล้างข้อความทั้งหมด',
    build: buildBloc,
    seed: () => proposed,
    act: (bloc) => bloc.add(AssistantCleared()),
    expect: () => [ready],
  );

  blocTest<AssistantBloc, AssistantState>(
    'เปิดหน้าต่างแชท ล้างจุดแดง (ข้อความใหม่) / ย่อหน้าต่าง แชทเดิมยังอยู่',
    build: buildBloc,
    seed: () => proposed.copyWith(hasUnread: true),
    act:
        (bloc) =>
            bloc
              ..add(AssistantPanelOpened())
              ..add(AssistantPanelClosed()),
    expect: () => [proposed.copyWith(isOpen: true), proposed],
  );

  blocTest<AssistantBloc, AssistantState>(
    'หน้าต่างเปิดอยู่ตอนได้คำตอบ ไม่ขึ้นจุดแดง',
    build: () {
      when(() => aiRepository.chat(any())).thenAnswer((_) async => reply);
      return buildBloc();
    },
    seed: () => ready.copyWith(isOpen: true),
    act: (bloc) => bloc.add(AssistantMessageSent('รับเคสเข้า 10 ชิ้น')),
    skip: 1,
    expect:
        () => [
          ready.copyWith(isOpen: true, messages: [ask, reply], sendStatus: AppStatus.success),
        ],
  );

  blocTest<AssistantBloc, AssistantState>(
    'ใส่ key ของ Claude สำเร็จ เปลี่ยนเป็น Claude (ตัดช่องว่างก่อนส่ง)',
    build: () {
      when(() => aiRepository.saveKey('sk-ant-api03-key')).thenAnswer((_) async => claude);
      return buildBloc();
    },
    seed: () => ready,
    act: (bloc) => bloc.add(AssistantKeySaved('  sk-ant-api03-key  ')),
    expect:
        () => [ready.copyWith(keyStatus: AppStatus.loading), ready.copyWith(keyStatus: AppStatus.success, ai: claude)],
  );

  blocTest<AssistantBloc, AssistantState>(
    'key ใช้ไม่ได้ ได้ keyStatus failure พร้อม code AI เดิมไม่เปลี่ยน',
    build: () {
      when(() => aiRepository.saveKey(any())).thenThrow(ApiException('ai_key_invalid'));
      return buildBloc();
    },
    seed: () => ready,
    act: (bloc) => bloc.add(AssistantKeySaved('sk-ant-wrong')),
    expect:
        () => [
          ready.copyWith(keyStatus: AppStatus.loading),
          ready.copyWith(keyStatus: AppStatus.failure, keyErrorCode: 'ai_key_invalid'),
        ],
  );

  blocTest<AssistantBloc, AssistantState>(
    'ลบ key กลับไปใช้ AI ฟรี',
    build: () {
      when(() => aiRepository.removeKey()).thenAnswer((_) async => free);
      return buildBloc();
    },
    seed: () => ready.copyWith(ai: claude),
    act: (bloc) => bloc.add(AssistantKeyRemoved()),
    expect:
        () => [ready.copyWith(ai: claude, keyStatus: AppStatus.loading), ready.copyWith(keyStatus: AppStatus.success)],
  );
}
