import 'package:deuro_wallet/di.dart';
import 'package:deuro_wallet/packages/repository/asset_repository.dart';
import 'package:deuro_wallet/packages/repository/node_repository.dart';
import 'package:deuro_wallet/packages/utils/default_assets.dart';
import 'package:deuro_wallet/packages/utils/default_nodes.dart';

Future<void> setupDefaultAssets() async {
  for(final asset in defaultAssets) {
    await getIt<AssetRepository>().saveAsset(asset);
  }
}

Future<void> setupDefaultNodes() async {
  for(final node in defaultNodes) {
    await getIt<NodeRepository>().saveNode(node);
  }
}
