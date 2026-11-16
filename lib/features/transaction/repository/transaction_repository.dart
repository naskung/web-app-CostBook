import 'package:flutter/material.dart' show DateTimeRange;

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
    DateTimeRange range, {
    int offset = 0,
    int limit = ApiConstants.pageSize,
  }) async {
    return _transactions(await api.get(_listPath(range, offset, limit)));
  }

  Future<TransactionSummaryModel> getSummary(DateTimeRange range) async {
    final data = await api.get(_summaryPath(range)) as Map<String, dynamic>;
    return TransactionSummaryModel.fromJson(data);
  }

  // ของที่เคยโหลด (โชว์ก่อนระหว่างโหลดใหม่) / ไม่เคยโหลด = null
  List<TransactionModel>? cachedTransactions(DateTimeRange range) {
    final data = api.cached(_listPath(range, 0, ApiConstants.pageSize));
    if (data == null) return null;
    return _transactions(data);
  }

  TransactionSummaryModel? cachedSummary(DateTimeRange range) {
    final data = api.cached(_summaryPath(range));
    if (data == null) return null;
    return TransactionSummaryModel.fromJson(data as Map<String, dynamic>);
  }

  String _listPath(DateTimeRange range, int offset, int limit) {
    return '/transactions?${DateUtil.toApiRange(range)}&limit=$limit&offset=$offset';
  }

  String _summaryPath(DateTimeRange range) => '/transactions/summary?${DateUtil.toApiRange(range)}';

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
