part of 'market_bloc.dart';

class MarketState extends Equatable {
  const MarketState({
    this.status = AppStatus.initial,
    this.product,
    this.check,
    this.aiEnabled = false,
    this.errorCode = '',
    this.checkStatus = AppStatus.initial,
    this.checkErrorCode = '',
  });

  final AppStatus status;
  final ProductModel? product;
  final MarketCheckModel? check;
  final bool aiEnabled;
  final String errorCode;
  final AppStatus checkStatus;
  final String checkErrorCode;

  bool get isChecking => checkStatus == AppStatus.loading;

  MarketState copyWith({
    AppStatus? status,
    ProductModel? product,
    MarketCheckModel? check,
    bool? aiEnabled,
    String? errorCode,
    AppStatus? checkStatus,
    String? checkErrorCode,
  }) {
    return MarketState(
      status: status ?? this.status,
      product: product ?? this.product,
      check: check ?? this.check,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      errorCode: errorCode ?? this.errorCode,
      checkStatus: checkStatus ?? this.checkStatus,
      checkErrorCode: checkErrorCode ?? this.checkErrorCode,
    );
  }

  @override
  List<Object?> get props => [status, product, check, aiEnabled, errorCode, checkStatus, checkErrorCode];
}
