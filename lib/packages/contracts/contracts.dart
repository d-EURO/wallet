import 'package:deuro_wallet/packages/contracts/Equity.g.dart';
import 'package:deuro_wallet/packages/contracts/FrontendGateway.g.dart';
import 'package:deuro_wallet/packages/contracts/SavingsGateway.g.dart';
import 'package:deuro_wallet/packages/contracts/StablecoinBridge.g.dart';
import 'package:web3dart/web3dart.dart';

export 'FrontendGateway.g.dart';
export 'SavingsGateway.g.dart';

const String savingsGatewayAddress =
    "0x073493d73258C4BEb6542e8dd3e1b2891C972303";
const String frontendGatewayAddress =
    "0x5c49C00f897bD970d964BFB8c3065ae65a180994";
const String equityAddress =
    "0xc71104001a3ccda1bef1177d765831bd1bfe8ee6";

SavingsGateway getSavingsGateway(Web3Client client) => SavingsGateway(
    address: EthereumAddress.fromHex(savingsGatewayAddress), client: client);

FrontendGateway getFrontendGateway(Web3Client client) => FrontendGateway(
    address: EthereumAddress.fromHex(frontendGatewayAddress), client: client);

StablecoinBridge getStablecoinBridge(Web3Client client) => StablecoinBridge(
    address: EthereumAddress.fromHex(frontendGatewayAddress), client: client);

Equity getEquity(Web3Client client) => Equity(
    address: EthereumAddress.fromHex(equityAddress), client: client);
