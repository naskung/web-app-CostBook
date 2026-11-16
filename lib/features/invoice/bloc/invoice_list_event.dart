part of 'invoice_list_bloc.dart';

abstract class InvoiceListEvent {}

class InvoicesRequested extends InvoiceListEvent {}

// เลื่อนใกล้ล่างสุด / กดลองใหม่ → โหลดหน้าต่อไป
class InvoicesMoreRequested extends InvoiceListEvent {}

class InvoiceRangeChanged extends InvoiceListEvent {
  InvoiceRangeChanged(this.range);

  final DateTimeRange range;
}

class InvoiceDeliveryChanged extends InvoiceListEvent {
  InvoiceDeliveryChanged({required this.invoiceId, required this.deliveryStatus});

  final String invoiceId;
  final DeliveryStatus deliveryStatus;
}
