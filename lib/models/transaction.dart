import 'package:deuro_wallet/models/asset.dart';

enum TransactionTypes { transfer, genericContractCall, tokenTransfer }

class Transaction {
  final int height;
  final String txId;
  final int chainId;
  final String senderAddress;
  final String receiverAddress;
  final BigInt amount;
  final Asset asset;
  final TransactionTypes type;
  final String? note;
  final String? data;

  const Transaction({
    required this.height,
    required this.txId,
    required this.chainId,
    required this.senderAddress,
    required this.receiverAddress,
    required this.amount,
    required this.asset,
    required this.type,
    required this.note,
    required this.data,
  });
}
