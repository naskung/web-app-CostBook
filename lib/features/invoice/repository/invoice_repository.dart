import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/core/constants/delivery_status.dart';
import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/features/invoice/models/invoice_draft_model.dart';
import 'package:costbook/features/invoice/models/invoice_model.dart';
import 'package:costbook/features/invoice/models/invoice_summary_model.dart';

class InvoiceRepository {
  InvoiceRepository(this.api);

  final ApiClient api;

  // โหลดทีละหน้า: offset = ข้ามไปกี่ใบ / limit ไม่ส่ง = 1 หน้า (20 ใบ)
  Future<List<InvoiceSummaryModel>> getInvoices(
    DateTime month, {
    int offset = 0,
    int limit = ApiConstants.pageSize,
  }) async {
    return _invoices(await api.get(_listPath(month, offset, limit)));
  }

  // ของที่เคยโหลด (โชว์ก่อนระหว่างโหลดใหม่) / ไม่เคยโหลด = null
  List<InvoiceSummaryModel>? cachedInvoices(DateTime month) {
    final data = api.cached(_listPath(month, 0, ApiConstants.pageSize));
    if (data == null) return null;
    return _invoices(data);
  }

  String _listPath(DateTime month, int offset, int limit) {
    return '/invoices?month=${DateUtil.toApiMonth(month)}&limit=$limit&offset=$offset';
  }

  List<InvoiceSummaryModel> _invoices(dynamic data) {
    return (data as List).map((item) => InvoiceSummaryModel.fromJson(item as Map<String, dynamic>)).toList();
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

  Future<InvoiceModel> updateDelivery(String id, DeliveryStatus status) async {
    final data = await api.put('/invoices/$id/delivery', {'delivery_status': status.name}) as Map<String, dynamic>;
    return InvoiceModel.fromJson(data);
  }
}
