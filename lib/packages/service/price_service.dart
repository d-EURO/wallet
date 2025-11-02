import 'package:deuro_wallet/models/asset.dart';

abstract class APriceService {
  Future<BigInt> getPriceOfAsset(Asset asset);
}
