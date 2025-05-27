part of 'savings_edit_bloc.dart';

enum SendStatus { initial, inProgress, success, failure }

class SavingsEditState extends Equatable {
  const SavingsEditState({
    this.status = SendStatus.initial,
    this.amount = "0",
    this.isEnabled = false,
    this.blockchain = Blockchain.ethereum,
  });

  final SendStatus status;
  final String amount;
  final bool isEnabled;
  final Blockchain blockchain;

  SavingsEditState copyWith({
    SendStatus? status,
    String? amount,
    bool? isValid,
    bool? isEnabled,
    Blockchain? blockchain,
  }) {
    return SavingsEditState(
      status: status ?? this.status,
      amount: amount ?? this.amount,
      isEnabled: isEnabled ?? this.isEnabled,
      blockchain: blockchain ?? this.blockchain,
    );
  }

  @override
  List<Object> get props => [status, amount, isEnabled, blockchain];
}
