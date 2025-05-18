part of 'send_invoice_bloc.dart';

enum SendStatus { initial, inProgress, success, failure }

class SendInvoiceState extends Equatable {
  const SendInvoiceState(
      {required this.invoice,
      this.status = SendStatus.initial,
      this.asset = dEUROAsset,
      this.fee = "0.0"});

  final SendStatus status;
  final OpenCryptoPayRequest invoice;
  final Asset asset;
  final String fee;

  Blockchain get blockchain => Blockchain.getFromChainId(asset.chainId);

  BigInt get dEuroAmount => parseFixed(
      invoice.methods[blockchain.name]!
          .firstWhere((m) => m.symbol.toUpperCase() == "DEURO")
          .amount,
      18);

  SendInvoiceState copyWith({
    OpenCryptoPayRequest? invoice,
    SendStatus? status,
    Asset? asset,
    String? fee,
  }) {
    return SendInvoiceState(
      invoice: invoice ?? this.invoice,
      status: status ?? this.status,
      asset: asset ?? this.asset,
      fee: fee ?? this.fee,
    );
  }

  @override
  List<Object> get props => [status, invoice, asset, fee];
}
