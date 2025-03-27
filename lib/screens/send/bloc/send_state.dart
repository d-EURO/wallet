part of 'send_bloc.dart';

enum SendStatus { initial, inProgress, success, failure }

class SendState extends Equatable {
  const SendState({
    this.status = SendStatus.initial,
    this.receiver = "",
    this.amount = "0",
    this.isValid = false,
    this.blockchain = Blockchain.ethereum,
    this.fee = "0.0"
  });

  final SendStatus status;
  final String receiver;
  final String amount;
  final bool isValid;
  final Blockchain blockchain;
  final String fee;

  SendState copyWith({
    SendStatus? status,
    String? receiver,
    String? amount,
    bool? isValid,
    Blockchain? blockchain,
    String? fee,
  }) {
    return SendState(
      status: status ?? this.status,
      receiver: receiver ?? this.receiver,
      amount: amount ?? this.amount,
      isValid: isValid ?? this.isValid,
      blockchain: blockchain ?? this.blockchain,
      fee: fee ?? this.fee,
    );
  }

  @override
  List<Object> get props => [status, receiver, amount, blockchain, fee];
}
