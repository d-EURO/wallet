import 'package:deuro_wallet/packages/storage/database.dart';
import 'package:deuro_wallet/packages/utils/fast_hash.dart';
import 'package:drift/drift.dart';

extension PriceStorage on AppDatabase {
  Future<int> insertPrice(int assetId, String price, DateTime timeStamp) =>
      into(prices).insert(PricesCompanion.insert(
        id: fastHash("${assetId}_${timeStamp.millisecondsSinceEpoch}"),
        assetId: assetId,
        price: price,
        timeStamp: timeStamp,
      ));

  Future<List<PriceData>> getPrices(int assetId) =>
      (select(prices)..where((row) => row.assetId.equals(assetId))).get();

  Future<PriceData?> getPrice(int assetId, DateTime timeStamp) =>
      (select(prices)
            ..where((row) => row.id.equals(
                fastHash("${assetId}_${timeStamp.millisecondsSinceEpoch}"))))
          .getSingleOrNull();
}

@DataClassName("PriceData")
class Prices extends Table {
  IntColumn get id => integer().unique()();

  IntColumn get assetId => integer()();

  TextColumn get price => text()();

  DateTimeColumn get timeStamp => dateTime()();
}
