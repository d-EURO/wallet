import 'dart:async';

import 'package:deuro_wallet/models/asset.dart';
import 'package:deuro_wallet/models/blockchain.dart';
import 'package:deuro_wallet/models/transaction.dart';
import 'package:deuro_wallet/packages/repository/asset_repository.dart';
import 'package:deuro_wallet/packages/storage/database.dart';
import 'package:deuro_wallet/packages/storage/transaction_storage.dart';

class TransactionRepository {
  final AppDatabase _appDatabase;
  final AssetRepository _assetRepository;

  const TransactionRepository(this._appDatabase, this._assetRepository);

  Future<int> getLatestHeight() async =>
      (await _appDatabase.getLatestTransactions(limit: 1))
          .firstOrNull
          ?.height ??
      0;

  Future<int> insertTransaction(Transaction transaction) =>
      _appDatabase.insertTransactions(
        transaction.height,
        transaction.txId,
        transaction.chainId,
        transaction.senderAddress,
        transaction.receiverAddress,
        transaction.amount.toRadixString(16),
        transaction.asset.id,
        transaction.type.index,
        transaction.note ?? '',
        transaction.data ?? '',
      );

  Future<bool> exitsTransaction(String txId) =>
      _appDatabase.getTransaction(txId).then((txData) => txData != null);

  // Future<Transaction?> getTransaction(String txId) =>
  //     _appDatabase.getTransaction(txId).then((txData) async {
  //       if (txData == null) return null;
  //       return Transaction(
  //           height: txData.height,
  //           txId: txData.txId,
  //           chainId: txData.chainId,
  //           senderAddress: txData.senderAddress,
  //           receiverAddress: txData.receiverAddress,
  //           amount: BigInt.parse(txData.amount, radix: 16),
  //           asset: asset,
  //           type: TransactionTypes.values[txData.type],
  //           note: txData.note,
  //           data: txData.data);
  //     });

  Future<List<Transaction>> get allTransactions async {
    final assets = await _assetRepository.allAssets;

    return _appDatabase.allTransactions.then((result) => result.map((txData) {
          final blockchain = Blockchain.getFromChainId(txData.chainId);
          final txType = TransactionTypes.values[txData.type];

          final asset = txType == TransactionTypes.transfer
              ? blockchain.nativeAsset
              : assets.firstWhere((e) => e.id == txData.asset,
                  orElse: () => Asset(
                        chainId: blockchain.chainId,
                        address: txData.receiverAddress,
                        name: "Unknown",
                        symbol: "???",
                        decimals: 18,
                      ));
          return Transaction(
            height: txData.height,
            txId: txData.txId,
            chainId: txData.chainId,
            senderAddress: txData.senderAddress,
            receiverAddress: txData.receiverAddress,
            amount: BigInt.parse(txData.amount, radix: 16),
            asset: asset,
            type: txType,
            note: txData.note,
            data: txData.data,
          );
        }).toList());
  }

  Stream<List<Transaction>> watchTransactions() {
    return _appDatabase
        .watchTransactions()
        .transform<List<Transaction>>(_transformer);
  }

  Stream<List<Transaction>> watchTransactionsOfAssets(Iterable<Asset> assets) {
    return _appDatabase
        .watchTransactionsOfAssets(assets.map((e) => e.id))
        .transform<List<Transaction>>(_transformer);
  }

  StreamTransformer<
      List<TransactionData>,
      List<
          Transaction>> get _transformer =>
      StreamTransformer<List<TransactionData>, List<Transaction>>.fromHandlers(
          handleData: (rawTransactions, sink) async {
        final transactions = <Transaction>[];

        final assets = await _assetRepository.allAssets;

        for (final transactionData in rawTransactions) {
          final txType = TransactionTypes.values[transactionData.type];
          final blockchain = Blockchain.getFromChainId(transactionData.chainId);
          final asset = txType == TransactionTypes.transfer
              ? blockchain.nativeAsset
              : assets.firstWhere((e) => e.id == transactionData.asset,
                  orElse: () => Asset(
                        chainId: blockchain.chainId,
                        address: transactionData.receiverAddress,
                        name: "Unknown",
                        symbol: "???",
                        decimals: 18,
                      ));

          transactions.add(Transaction(
            height: transactionData.height,
            txId: transactionData.txId,
            chainId: transactionData.chainId,
            senderAddress: transactionData.senderAddress,
            receiverAddress: transactionData.receiverAddress,
            amount: BigInt.parse(transactionData.amount, radix: 16),
            asset: asset,
            type: txType,
            note: transactionData.note,
            data: transactionData.data,
          ));
        }

        sink.add(transactions);
      });
}
