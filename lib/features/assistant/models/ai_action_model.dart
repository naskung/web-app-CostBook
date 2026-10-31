import 'package:equatable/equatable.dart';

class AiChangeModel extends Equatable {
  const AiChangeModel({required this.field, this.from = '', this.to = ''});

  final String field;
  final String from;
  final String to;

  factory AiChangeModel.fromJson(Map<String, dynamic> json) {
    return AiChangeModel(
      field: json['field'] as String? ?? '',
      from: '${json['from'] ?? ''}',
      to: '${json['to'] ?? ''}',
    );
  }

  @override
  List<Object?> get props => [field, from, to];
}

class AiActionModel extends Equatable {
  const AiActionModel({
    required this.id,
    required this.type,
    this.reason = '',
    this.productId = '',
    this.productName = '',
    this.changes = const [],
    this.data = const {},
    this.status = pending,
    this.errorCode = '',
  });

  static const String createProduct = 'create_product';
  static const String updateProduct = 'update_product';
  static const String stockIn = 'stock_in';
  static const String stockOut = 'stock_out';
  static const String addTransaction = 'add_transaction';
  static const String marketCheck = 'market_check';

  static const String pending = 'pending';
  static const String running = 'running';
  static const String done = 'done';
  static const String failed = 'failed';
  static const String cancelled = 'cancelled';

  final String id;
  final String type;
  final String reason;
  final String productId;
  final String productName;
  final List<AiChangeModel> changes;
  final Map<String, dynamic> data;
  final String status;
  final String errorCode;

  bool get isPending => status == pending;

  bool get isRunning => status == running;

  String dataText(String key) => '${data[key] ?? ''}';

  double dataNumber(String key) => (data[key] as num? ?? 0).toDouble();

  String get resultNote {
    final target = productName.isEmpty ? '' : ' $productName';
    if (status == done) return '[ผู้ใช้กดยืนยันงาน $type$target แล้ว ทำสำเร็จ]';
    if (status == failed) return '[ผู้ใช้กดยืนยันงาน $type$target แต่ทำไม่สำเร็จ: $errorCode]';
    return '[ผู้ใช้ไม่เอางาน $type$target]';
  }

  factory AiActionModel.fromJson(Map<String, dynamic> json) {
    final changes = json['changes'] as List? ?? [];
    return AiActionModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      changes: changes.map((item) => AiChangeModel.fromJson(item as Map<String, dynamic>)).toList(),
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }

  AiActionModel copyWith({String? status, String? errorCode}) {
    return AiActionModel(
      id: id,
      type: type,
      reason: reason,
      productId: productId,
      productName: productName,
      changes: changes,
      data: data,
      status: status ?? this.status,
      errorCode: errorCode ?? this.errorCode,
    );
  }

  @override
  List<Object?> get props => [id, type, reason, productId, productName, changes, data, status, errorCode];
}
