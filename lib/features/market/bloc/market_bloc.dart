import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/features/assistant/repository/ai_repository.dart';
import 'package:costbook/features/market/models/market_check_model.dart';
import 'package:costbook/features/market/repository/market_repository.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/repository/product_repository.dart';

part 'market_event.dart';
part 'market_state.dart';

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  MarketBloc(this.repository, this.productRepository, this.aiRepository, {required this.productId})
    : super(const MarketState()) {
    on<MarketOpened>(_onOpened);
    on<MarketCheckRequested>(_onCheckRequested);
  }

  final MarketRepository repository;
  final ProductRepository productRepository;
  final AiRepository aiRepository;
  final String productId;

  Future<void> _onOpened(MarketOpened event, Emitter<MarketState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final product = await productRepository.getProduct(productId);
      final check = await repository.getLatest(productId);
      final ai = await aiRepository.getStatus();
      emit(MarketState(status: AppStatus.success, product: product, check: check, canCheck: ai.webSearch));
    } catch (error) {
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onCheckRequested(MarketCheckRequested event, Emitter<MarketState> emit) async {
    if (state.isChecking) return;
    emit(state.copyWith(checkStatus: AppStatus.loading, checkErrorCode: ''));
    try {
      final check = await repository.check(productId);
      emit(state.copyWith(checkStatus: AppStatus.success, check: check));
    } catch (error) {
      emit(state.copyWith(checkStatus: AppStatus.failure, checkErrorCode: ErrorUtil.codeOf(error)));
    }
  }
}
