import 'package:deuro_wallet/packages/utils/fast_hash.dart';

class Balance {
  int get id => fastHash("$walletAddress:$chainId:$contractAddress");

  final int chainId;
  final String contractAddress;
  final String walletAddress;
  BigInt balance;

  Balance({
    required this.chainId,
    required this.contractAddress,
    required this.walletAddress,
    required this.balance,
  });

  @override
  int get hashCode => Object.hash(chainId, contractAddress, walletAddress);

  @override
  bool operator ==(Object other) =>
      other is Balance &&
      chainId == other.chainId &&
      contractAddress == other.contractAddress &&
      walletAddress == other.walletAddress;
}
