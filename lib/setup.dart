import 'package:deuro_wallet/di.dart';
import 'package:deuro_wallet/packages/repository/asset_repository.dart';
import 'package:deuro_wallet/packages/utils/default_assets.dart';

Future<void> setupDefaultAssets() async {
  for(final asset in defaultAssets) {
    await getIt<AssetRepository>().saveAsset(asset);
  }
}
