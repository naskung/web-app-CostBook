import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/features/invoice/models/invoice_draft_model.dart';
import 'package:costbook/features/invoice/models/invoice_model.dart';
import 'package:costbook/features/invoice/models/invoice_summary_model.dart';

class InvoiceRepository {
  InvoiceRepository(this.api);

  final ApiClient api;

  Future<List<InvoiceSummaryModel>> getInvoices(DateTime month) async {
    final data = await api.get('/invoices?month=${DateUtil.toApiMonth(month)}') as List;
    return data.map((item) => InvoiceSummaryModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<InvoiceModel> getInvoice(String id) async {
    final data = await api.get('/invoices/$id') as Map<String, dynamic>;
    return InvoiceModel.fromJson(data);
  }

  Future<InvoiceModel> createInvoice(InvoiceDraftModel draft) async {
    final data = await api.post('/invoices', draft.toJson()) as Map<String, dynamic>;
    return InvoiceModel.fromJson(data);
  }

  Future<InvoiceModel> cancelInvoice(String id) async {
    final data = await api.post('/invoices/$id/cancel', {}) as Map<String, dynamic>;
    return InvoiceModel.fromJson(data);
  }
}
