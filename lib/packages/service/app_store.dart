import 'dart:developer' as developer;

import 'package:deuro_wallet/models/node.dart';
import 'package:deuro_wallet/packages/repository/node_repository.dart';
import 'package:deuro_wallet/packages/wallet/wallet.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart' as web3;

class AppStore {
  List<Node> _nodes = [];
  final _client = Client();
  Wallet? _wallet;

  set wallet(Wallet wallet_) => _wallet = wallet_;

  Wallet get wallet {
    if (_wallet != null) return _wallet!;
    throw Exception("No Wallet set");
  }

  Future<void> refreshNodes(NodeRepository nodeRepository) async {
    _nodes = await nodeRepository.allNodes;
  }

  String get primaryAddress =>
      wallet.currentAccount.primaryAddress.address.hexEip55;

  web3.Web3Client getClient(int chainId) {
    final node = _nodes.firstWhere(
      (node) => node.chainId == chainId,
      orElse: () {
        developer.log("No node found for $chainId using fallback ETH Node");
        return Node(
          chainId: 1,
          name: "Fallback",
          httpsUrl:
              "https://eth-mainnet.g.alchemy.com/v2/9qEJRkxr1gAyFfwsCU6qODRSqj3TAzjj",
        );
      },
    );

    return web3.Web3Client(node.httpsUrl, _client);
  }
}
