part of 'market_bloc.dart';

class MarketState extends Equatable {
  const MarketState({
    this.status = AppStatus.initial,
    this.product,
    this.check,
    this.canCheck = false,
    this.errorCode = '',
    this.checkStatus = AppStatus.initial,
    this.checkErrorCode = '',
  });

  final AppStatus status;
  final ProductModel? product;
  final MarketCheckModel? check;
  final bool canCheck;
  final String errorCode;
  final AppStatus checkStatus;
  final String checkErrorCode;

  bool get isChecking => checkStatus == AppStatus.loading;

  MarketState copyWith({
    AppStatus? status,
    ProductModel? product,
    MarketCheckModel? check,
    bool? canCheck,
    String? errorCode,
    AppStatus? checkStatus,
    String? checkErrorCode,
  }) {
    return MarketState(
      status: status ?? this.status,
      product: product ?? this.product,
      check: check ?? this.check,
      canCheck: canCheck ?? this.canCheck,
      errorCode: errorCode ?? this.errorCode,
      checkStatus: checkStatus ?? this.checkStatus,
      checkErrorCode: checkErrorCode ?? this.checkErrorCode,
    );
  }

  @override
  List<Object?> get props => [status, product, check, canCheck, errorCode, checkStatus, checkErrorCode];
}
