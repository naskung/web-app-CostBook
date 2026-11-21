import 'package:flutter/material.dart' show DateTimeRange;

import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/features/quotation/models/quotation_draft_model.dart';
import 'package:costbook/features/quotation/models/quotation_model.dart';
import 'package:costbook/features/quotation/models/quotation_summary_model.dart';

class QuotationRepository {
  QuotationRepository(this.api);

  final ApiClient api;

  Future<List<QuotationSummaryModel>> getQuotations(
    DateTimeRange range, {
    int offset = 0,
    int limit = ApiConstants.pageSize,
  }) async {
    return _quotations(await api.get(_listPath(range, offset, limit)));
  }

  List<QuotationSummaryModel>? cachedQuotations(DateTimeRange range) {
    final data = api.cached(_listPath(range, 0, ApiConstants.pageSize));
    if (data == null) return null;
    return _quotations(data);
  }

  String _listPath(DateTimeRange range, int offset, int limit) {
    return '/quotations?${DateUtil.toApiRange(range)}&limit=$limit&offset=$offset';
  }

  List<QuotationSummaryModel> _quotations(dynamic data) {
    return (data as List).map((item) => QuotationSummaryModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<QuotationModel> getQuotation(String id) async {
    final data = await api.get('/quotations/$id') as Map<String, dynamic>;
    return QuotationModel.fromJson(data);
  }

  Future<QuotationModel> createQuotation(QuotationDraftModel draft) async {
    final data = await api.post('/quotations', draft.toJson()) as Map<String, dynamic>;
    return QuotationModel.fromJson(data);
  }

  Future<QuotationModel> cancelQuotation(String id) async {
    final data = await api.post('/quotations/$id/cancel', {}) as Map<String, dynamic>;
    return QuotationModel.fromJson(data);
  }
}
