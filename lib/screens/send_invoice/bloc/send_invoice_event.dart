part of 'send_invoice_bloc.dart';

sealed class SendInvoiceEvent extends Equatable {
  const SendInvoiceEvent();

  @override
  List<Object> get props => [];
}

final class ChainChanged extends SendInvoiceEvent {
  const ChainChanged(this.blockchain);

  final Blockchain blockchain;

  @override
  List<Object> get props => [blockchain];
}

final class CancelInvoice extends SendInvoiceEvent {
  const CancelInvoice();
}

final class SendSubmitted extends SendInvoiceEvent {
  const SendSubmitted();
}
