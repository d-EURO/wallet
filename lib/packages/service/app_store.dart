import 'package:deuro_wallet/packages/wallet/wallet.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart' as web3;

class AppStore {
  final _client = Client();

  Wallet? _wallet;

  set wallet(Wallet wallet_) => _wallet = wallet_;

  Wallet get wallet {
    if (_wallet != null) return _wallet!;
    throw Exception("No Wallet set");
  }

  String get primaryAddress =>
      wallet.currentAccount.primaryAddress.address.hexEip55;

  web3.Web3Client getClient(int chainId) {
    switch (chainId) {
      case 1:
        return web3.Web3Client(
            "https://eth-mainnet.g.alchemy.com/v2/9qEJRkxr1gAyFfwsCU6qODRSqj3TAzjj",
            _client);
      case 137:
        return web3.Web3Client(
            "https://polygon-mainnet.g.alchemy.com/v2/9qEJRkxr1gAyFfwsCU6qODRSqj3TAzjj",
            _client);
      case 8453:
        return web3.Web3Client(
            "https://base-mainnet.g.alchemy.com/v2/9qEJRkxr1gAyFfwsCU6qODRSqj3TAzjj",
            _client);
      case 10:
        return web3.Web3Client(
            "https://opt-mainnet.g.alchemy.com/v2/9qEJRkxr1gAyFfwsCU6qODRSqj3TAzjj",
            _client);
      case 42161:
        return web3.Web3Client(
            "https://arb-mainnet.g.alchemy.com/v2/9qEJRkxr1gAyFfwsCU6qODRSqj3TAzjj",
            _client);

      default:
        return web3.Web3Client(
            "https://eth-mainnet.g.alchemy.com/v2/9qEJRkxr1gAyFfwsCU6qODRSqj3TAzjj",
            _client);
    }
  }
}
