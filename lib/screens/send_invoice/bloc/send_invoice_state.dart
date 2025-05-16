part of 'send_invoice_bloc.dart';

enum SendStatus { initial, inProgress, success, failure }

class SendInvoiceState extends Equatable {
  const SendInvoiceState(
      {required this.invoice,
      this.status = SendStatus.initial,
      this.blockchain = Blockchain.ethereum,
      this.fee = "0.0"});

  final SendStatus status;
  final OpenCryptoPayRequest invoice;
  final Blockchain blockchain;
  final String fee;

  BigInt get dEuroAmount => parseFixed(invoice.methods[blockchain.name]!
      .firstWhere((m) => m.symbol.toUpperCase() == "DEURO")
      .amount, 18);

  SendInvoiceState copyWith({
    OpenCryptoPayRequest? invoice,
    SendStatus? status,
    Blockchain? blockchain,
    String? fee,
  }) {
    return SendInvoiceState(
      invoice: invoice ?? this.invoice,
      status: status ?? this.status,
      blockchain: blockchain ?? this.blockchain,
      fee: fee ?? this.fee,
    );
  }

  @override
  List<Object> get props => [status, invoice, blockchain, fee];
}
