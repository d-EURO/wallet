part of 'savings_bloc.dart';

class SavingsState extends Equatable {
  const SavingsState({
    this.amount = "0",
    this.interest = "0",
    this.fee = "0.0"
  });

  final String amount;
  final String interest;
  final String fee;

  SavingsState copyWith({
    String? amount,
    String? interest,
    String? fee,
  }) {
    return SavingsState(
      amount: amount ?? this.amount,
      interest: interest ?? this.interest,
      fee: fee ?? this.fee,
    );
  }

  @override
  List<Object> get props => [amount, fee];
}
