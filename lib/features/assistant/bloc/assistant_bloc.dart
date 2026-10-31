import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/features/assistant/models/ai_action_model.dart';
import 'package:costbook/features/assistant/models/ai_status_model.dart';
import 'package:costbook/features/assistant/models/chat_message_model.dart';
import 'package:costbook/features/assistant/repository/ai_repository.dart';
import 'package:costbook/features/market/repository/market_repository.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/repository/product_repository.dart';
import 'package:costbook/features/stock/repository/stock_repository.dart';
import 'package:costbook/features/transaction/models/transaction_model.dart';
import 'package:costbook/features/transaction/repository/transaction_repository.dart';

part 'assistant_event.dart';
part 'assistant_state.dart';

class AssistantBloc extends Bloc<AssistantEvent, AssistantState> {
  AssistantBloc({
    required this.aiRepository,
    required this.productRepository,
    required this.stockRepository,
    required this.transactionRepository,
    required this.marketRepository,
  }) : super(const AssistantState()) {
    on<AssistantOpened>(_onOpened);
    on<AssistantPanelOpened>(_onPanelOpened);
    on<AssistantPanelClosed>(_onPanelClosed);
    on<AssistantMessageSent>(_onMessageSent);
    on<AssistantRetried>(_onRetried);
    on<AssistantActionConfirmed>(_onActionConfirmed);
    on<AssistantActionCancelled>(_onActionCancelled);
    on<AssistantCleared>(_onCleared);
    on<AssistantKeySaved>(_onKeySaved);
    on<AssistantKeyRemoved>(_onKeyRemoved);
  }

  final AiRepository aiRepository;
  final ProductRepository productRepository;
  final StockRepository stockRepository;
  final TransactionRepository transactionRepository;
  final MarketRepository marketRepository;

  Future<void> _onOpened(AssistantOpened event, Emitter<AssistantState> emit) async {
    if (state.status == AppStatus.success) return;
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final ai = await aiRepository.getStatus();
      emit(state.copyWith(status: AppStatus.success, ai: ai));
    } catch (error) {
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  void _onPanelOpened(AssistantPanelOpened event, Emitter<AssistantState> emit) {
    emit(state.copyWith(isOpen: true, hasUnread: false));
  }

  void _onPanelClosed(AssistantPanelClosed event, Emitter<AssistantState> emit) {
    emit(state.copyWith(isOpen: false));
  }

  Future<void> _onMessageSent(AssistantMessageSent event, Emitter<AssistantState> emit) async {
    final text = event.text.trim();
    if (text.isEmpty || state.isSending) return;
    final messages = [...state.messages, ChatMessageModel(role: ChatMessageModel.user, text: text)];
    await _ask(emit, messages);
  }

  Future<void> _onRetried(AssistantRetried event, Emitter<AssistantState> emit) async {
    if (state.isSending || state.messages.isEmpty || !state.messages.last.isUser) return;
    await _ask(emit, state.messages);
  }

  Future<void> _ask(Emitter<AssistantState> emit, List<ChatMessageModel> messages) async {
    emit(state.copyWith(messages: messages, sendStatus: AppStatus.loading, errorCode: ''));
    try {
      final reply = await aiRepository.chat(messages);
      emit(
        state.copyWith(messages: [...state.messages, reply], sendStatus: AppStatus.success, hasUnread: !state.isOpen),
      );
    } catch (error) {
      emit(state.copyWith(sendStatus: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onActionConfirmed(AssistantActionConfirmed event, Emitter<AssistantState> emit) async {
    final action = state.actionOf(event.actionId);
    if (action == null || !action.isPending) return;
    emit(state.copyWith(messages: _replaceAction(action.copyWith(status: AiActionModel.running))));
    try {
      await _run(action);
      _finish(emit, action.copyWith(status: AiActionModel.done));
    } catch (error) {
      _finish(emit, action.copyWith(status: AiActionModel.failed, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  void _onActionCancelled(AssistantActionCancelled event, Emitter<AssistantState> emit) {
    final action = state.actionOf(event.actionId);
    if (action == null || !action.isPending) return;
    _finish(emit, action.copyWith(status: AiActionModel.cancelled));
  }

  void _onCleared(AssistantCleared event, Emitter<AssistantState> emit) {
    emit(state.copyWith(messages: [], sendStatus: AppStatus.initial, errorCode: ''));
  }

  Future<void> _onKeySaved(AssistantKeySaved event, Emitter<AssistantState> emit) async {
    await _changeKey(emit, () => aiRepository.saveKey(event.apiKey.trim()));
  }

  Future<void> _onKeyRemoved(AssistantKeyRemoved event, Emitter<AssistantState> emit) async {
    await _changeKey(emit, aiRepository.removeKey);
  }

  Future<void> _changeKey(Emitter<AssistantState> emit, Future<AiStatusModel> Function() change) async {
    emit(state.copyWith(keyStatus: AppStatus.loading, keyErrorCode: ''));
    try {
      final ai = await change();
      emit(state.copyWith(keyStatus: AppStatus.success, ai: ai, status: AppStatus.success));
    } catch (error) {
      emit(state.copyWith(keyStatus: AppStatus.failure, keyErrorCode: ErrorUtil.codeOf(error)));
    }
  }

  void _finish(Emitter<AssistantState> emit, AiActionModel action) {
    final note = ChatMessageModel(role: ChatMessageModel.note, text: action.resultNote);
    emit(state.copyWith(messages: [..._replaceAction(action), note]));
  }

  List<ChatMessageModel> _replaceAction(AiActionModel changed) {
    return [
      for (final message in state.messages)
        message.copyWith(actions: [for (final action in message.actions) action.id == changed.id ? changed : action]),
    ];
  }

  Future<void> _run(AiActionModel action) async {
    switch (action.type) {
      case AiActionModel.createProduct:
        await productRepository.saveProduct(ProductModel.fromJson({...action.data, 'id': ''}));
      case AiActionModel.updateProduct:
        await productRepository.saveProduct(ProductModel.fromJson({...action.data, 'id': action.productId}));
      case AiActionModel.stockIn:
      case AiActionModel.stockOut:
        await stockRepository.addMovement(
          type: action.type == AiActionModel.stockIn ? 'in' : 'out',
          productId: action.dataText('product_id'),
          quantity: action.dataNumber('quantity').toInt(),
          note: action.dataText('note'),
          unitCost: action.dataNumber('unit_cost'),
          supplier: action.dataText('supplier'),
        );
      case AiActionModel.addTransaction:
        await transactionRepository.saveTransaction(TransactionModel.fromJson({...action.data, 'id': ''}));
      case AiActionModel.marketCheck:
        await marketRepository.check(action.productId);
      default:
        throw UnsupportedError(action.type);
    }
  }
}
