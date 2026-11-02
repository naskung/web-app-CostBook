part of 'invoice_detail_bloc.dart';

abstract class InvoiceDetailEvent {}

class InvoiceDetailRequested extends InvoiceDetailEvent {}

class InvoiceCancelRequested extends InvoiceDetailEvent {}

class InvoiceDetailDeliveryChanged extends InvoiceDetailEvent {
  InvoiceDetailDeliveryChanged(this.deliveryStatus);

  final DeliveryStatus deliveryStatus;
}
