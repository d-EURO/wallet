import 'dart:convert';

import 'package:bip32/bip32.dart';
import 'package:convert/convert.dart';
import 'package:web3dart/web3dart.dart';

class WalletAccount {
  late final CredentialsWithKnownAddress primaryAddress;
  final List<CredentialsWithKnownAddress> subAddresses = [];

  final int accountIndex;
  final BIP32 root;
  int _lastIndex = 0;

  WalletAccount(this.root, this.accountIndex) {
    primaryAddress = _getPrivateKeyAt(0);
    subAddresses.add(primaryAddress);
    nextAddresses(5);
  }

  String getDerivationPath(int addressIndex) =>
      "m/44'/60'/$accountIndex'/0/$addressIndex";

  void nextAddresses(int limit) {
    final indexes = List<int>.generate(limit, (i) => _lastIndex + i);
    for (final index in indexes) {
      subAddresses.add(_getPrivateKeyAt(index));
    }
    _lastIndex += limit;
  }

  EthPrivateKey _getPrivateKeyAt(int addressIndex) {
    final addressAtIndex = root.derivePath(getDerivationPath(addressIndex));

    return EthPrivateKey.fromHex(hex.encode(addressAtIndex.privateKey!));
  }

  String signMessage(String message, {int addressIndex = 0}) =>
      "0x${hex.encode(_getPrivateKeyAt(addressIndex).signPersonalMessageToUint8List(ascii.encode(message)))}";
}
