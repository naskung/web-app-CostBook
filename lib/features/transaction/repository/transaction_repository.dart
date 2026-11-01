import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/features/transaction/models/transaction_model.dart';
import 'package:costbook/features/transaction/models/transaction_summary_model.dart';

class TransactionRepository {
  TransactionRepository(this.api);

  final ApiClient api;

  // โหลดทีละหน้า: offset = ข้ามไปกี่รายการ / limit ไม่ส่ง = 1 หน้า (20 รายการ)
  Future<List<TransactionModel>> getTransactions(
    DateTime month, {
    int offset = 0,
    int limit = ApiConstants.pageSize,
  }) async {
    return _transactions(await api.get(_listPath(month, offset, limit)));
  }

  Future<TransactionSummaryModel> getSummary(DateTime month) async {
    final data = await api.get(_summaryPath(month)) as Map<String, dynamic>;
    return TransactionSummaryModel.fromJson(data);
  }

  // ของที่เคยโหลด (โชว์ก่อนระหว่างโหลดใหม่) / ไม่เคยโหลด = null
  List<TransactionModel>? cachedTransactions(DateTime month) {
    final data = api.cached(_listPath(month, 0, ApiConstants.pageSize));
    if (data == null) return null;
    return _transactions(data);
  }

  TransactionSummaryModel? cachedSummary(DateTime month) {
    final data = api.cached(_summaryPath(month));
    if (data == null) return null;
    return TransactionSummaryModel.fromJson(data as Map<String, dynamic>);
  }

  String _listPath(DateTime month, int offset, int limit) {
    return '/transactions?month=${DateUtil.toApiMonth(month)}&limit=$limit&offset=$offset';
  }

  String _summaryPath(DateTime month) => '/transactions/summary?month=${DateUtil.toApiMonth(month)}';

  List<TransactionModel> _transactions(dynamic data) {
    return (data as List).map((item) => TransactionModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> saveTransaction(TransactionModel transaction) async {
    if (transaction.isNew) {
      await api.post('/transactions', transaction.toJson());
      return;
    }
    await api.put('/transactions/${transaction.id}', transaction.toJson());
  }

  Future<void> deleteTransaction(String id) async {
    await api.delete('/transactions/$id');
  }
}
