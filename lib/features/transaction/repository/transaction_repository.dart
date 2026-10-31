import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/features/transaction/models/transaction_model.dart';
import 'package:costbook/features/transaction/models/transaction_summary_model.dart';

class TransactionRepository {
  TransactionRepository(this.api);

  final ApiClient api;

  Future<List<TransactionModel>> getTransactions(DateTime month) async {
    final data = await api.get('/transactions?month=${DateUtil.toApiMonth(month)}') as List;
    return data.map((item) => TransactionModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<TransactionSummaryModel> getSummary(DateTime month) async {
    final data = await api.get('/transactions/summary?month=${DateUtil.toApiMonth(month)}') as Map<String, dynamic>;
    return TransactionSummaryModel.fromJson(data);
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
