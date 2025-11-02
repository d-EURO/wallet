import 'dart:async';

import 'package:deuro_wallet/models/asset.dart';
import 'package:deuro_wallet/models/price_point.dart';
import 'package:deuro_wallet/packages/storage/database.dart';
import 'package:deuro_wallet/packages/storage/price_storage.dart';

class PriceRepository {
  final AppDatabase _appDatabase;

  const PriceRepository(this._appDatabase);

  Future<int> insertPrice(PricePoint pricePoint) => _appDatabase.insertPrice(
        pricePoint.asset.id,
        pricePoint.price.toRadixString(16),
        pricePoint.time,
      );

  Future<List<PricePoint>> getPrices(Asset asset) =>
      _appDatabase.getPrices(asset.id).then((prices) => prices
          .map((e) => PricePoint(
                asset: asset,
                price: BigInt.parse(e.price, radix: 16),
                time: e.timeStamp,
              ))
          .toList());

  Future<bool> exitsPrice(PricePoint pricePoint) => _appDatabase
      .getPrice(pricePoint.asset.id, pricePoint.time)
      .then((e) => e != null);
}
