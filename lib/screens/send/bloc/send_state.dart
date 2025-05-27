part of 'send_bloc.dart';

enum SendStatus { initial, inProgress, success, failure }

class SendState extends Equatable {
  const SendState({
    this.status = SendStatus.initial,
    this.asset = dEUROAsset,
    this.receiver = "",
    this.amount = "0",
    this.isValid = false,
    this.alias,
  });

  final SendStatus status;
  final Asset asset;
  final String receiver;
  final AliasRecord? alias;
  final String amount;
  final bool isValid;

  Blockchain get blockchain => Blockchain.getFromChainId(asset.chainId);

  SendState copyWith({
    SendStatus? status,
    String? receiver,
    String? amount,
    bool? isValid,
    Asset? asset,
    AliasRecord? alias,
  }) =>
      SendState(
        status: status ?? this.status,
        receiver: receiver ?? this.receiver,
        amount: amount ?? this.amount,
        isValid: isValid ?? this.isValid,
        asset: asset ?? this.asset,
        alias: alias ?? this.alias,
      );

  SendState copyAlias({
    AliasRecord? alias,
  }) =>
      SendState(
          status: status,
          receiver: receiver,
          amount: amount,
          isValid: isValid,
          asset: asset,
          alias: alias);

  @override
  List<Object?> get props => [status, receiver, amount, asset, alias];
}
