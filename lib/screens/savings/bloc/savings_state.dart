part of 'savings_bloc.dart';

class SavingsState extends Equatable {
  const SavingsState({
    this.amount = "0",
    this.interest = "0",
    this.isEnabled = false,
  });

  final String amount;
  final String interest;
  final bool isEnabled;

  SavingsState copyWith({
    String? amount,
    String? interest,
    bool? isEnabled,
  }) {
    return SavingsState(
      amount: amount ?? this.amount,
      interest: interest ?? this.interest,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  List<Object> get props => [amount, interest, isEnabled];
}
