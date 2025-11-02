import 'package:deuro_wallet/models/asset.dart';
import 'package:deuro_wallet/models/blockchain.dart';
import 'package:deuro_wallet/packages/contracts/Equity.g.dart';
import 'package:deuro_wallet/packages/contracts/contracts.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/packages/service/price_service.dart';

class EquityService implements APriceService {
  final AppStore _appStore;
  late final Equity _equityContract;

  EquityService(this._appStore) {
    _equityContract =
        getEquity(_appStore.getClient(Blockchain.ethereum.chainId));
  }

  Future<BigInt> calculateProceeds(BigInt amount) =>
      _equityContract.calculateProceeds((shares: amount));

  @override
  Future<BigInt> getPriceOfAsset(Asset asset) => _equityContract.price();
}
