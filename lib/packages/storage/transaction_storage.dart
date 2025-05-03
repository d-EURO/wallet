import 'package:deuro_wallet/packages/storage/database.dart';
import 'package:deuro_wallet/packages/utils/fast_hash.dart';
import 'package:drift/drift.dart';

extension TransactionStorage on AppDatabase {
  Future<int> insertTransactions(
    int height,
    String txId,
    int chainId,
    String senderAddress,
    String receiverAddress,
    String amount,
    int asset,
    int type,
    String note,
    String data,
      DateTime timeStamp,
  ) =>
      into(transactions).insert(TransactionsCompanion.insert(
        height: height,
        txId: txId,
        chainId: chainId,
        senderAddress: senderAddress,
        receiverAddress: receiverAddress,
        amount: amount,
        asset: asset,
        type: type,
        note: note,
        data: data,
        timeStamp: timeStamp,
      ));

  Future<List<TransactionData>> getAllTokenTransactions(
          int chainId, String address) =>
      (select(transactions)
            ..where((row) => row.asset.equals(fastHash("$chainId:$address"))))
          .get();

  Future<List<TransactionData>> get allTransactions => transactions.all().get();

  Stream<List<TransactionData>> watchTransactions() => (select(transactions)
        ..orderBy([
          (u) => OrderingTerm(expression: u.height, mode: OrderingMode.desc)
        ]))
      .watch();

  Stream<List<TransactionData>> watchTransfersOfAssets(
          Iterable<int> assets) =>
      (select(transactions)
            ..where((row) => row.asset.isIn(assets) & row.type.equals(2))
            ..orderBy([
              (u) => OrderingTerm(expression: u.height, mode: OrderingMode.desc)
            ]))
          .watch();

  Stream<List<TransactionData>> watchTransfersOfAssetsLimit(
          Iterable<int> assets, int limit) =>
      (select(transactions)
            ..where((row) => row.asset.isIn(assets) & row.type.equals(2))
            ..orderBy([
              (u) => OrderingTerm(expression: u.height, mode: OrderingMode.desc)
            ])..limit(limit))
          .watch();

  Future<List<TransactionData>> getLatestTransactions({int limit = 1}) =>
      (select(transactions)
            ..orderBy([
              (u) => OrderingTerm(expression: u.height, mode: OrderingMode.desc)
            ])
            ..limit(limit))
          .get();

  Future<TransactionData?> getTransaction(String txId) =>
      (select(transactions)..where((row) => row.txId.equals(txId)))
          .getSingleOrNull();
}

@DataClassName("TransactionData")
class Transactions extends Table {
  IntColumn get height => integer()();

  TextColumn get txId => text().unique()();

  IntColumn get chainId => integer()();

  TextColumn get senderAddress => text()();

  TextColumn get receiverAddress => text()();

  TextColumn get amount => text()();

  IntColumn get asset => integer()();

  IntColumn get type => integer()();

  TextColumn get note => text()();

  TextColumn get data => text()();

  DateTimeColumn get timeStamp => dateTime()();
}
