part of 'savings_bloc.dart';

class SavingsState extends Equatable {
  const SavingsState({
    this.amount = "0",
    this.interestRate = "0",
    this.accruedInterest = "0",
    this.isEnabled = false,
    this.isActivatingSavings = false,
    this.isCollectingInterest = false,
  });

  final String amount;
  final String interestRate;
  final String accruedInterest;
  final bool isEnabled;
  final bool isActivatingSavings;
  final bool isCollectingInterest;

  SavingsState copyWith({
    String? amount,
    String? interestRate,
    String? accruedInterest,
    bool? isEnabled,
    bool? isActivatingSavings,
    bool? isCollectingInterest,
  }) {
    return SavingsState(
      amount: amount ?? this.amount,
      interestRate: interestRate ?? this.interestRate,
      accruedInterest: accruedInterest ?? this.accruedInterest,
      isEnabled: isEnabled ?? this.isEnabled,
      isActivatingSavings: isActivatingSavings ?? this.isActivatingSavings,
      isCollectingInterest: isCollectingInterest ?? this.isCollectingInterest,
    );
  }

  @override
  List<Object> get props => [
        amount,
        accruedInterest,
        isEnabled,
        isActivatingSavings,
        isCollectingInterest,
      ];
}
