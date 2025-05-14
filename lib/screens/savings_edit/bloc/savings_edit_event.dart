part of 'savings_edit_bloc.dart';

sealed class SavingsEditEvent extends Equatable {
  const SavingsEditEvent();

  @override
  List<Object> get props => [];
}

class AmountChangedAdd extends SavingsEditEvent {
  const AmountChangedAdd(this.amount);

  final int amount;

  @override
  List<Object> get props => [amount];
}

class AmountChangedDecimal extends SavingsEditEvent {
  const AmountChangedDecimal();
}

class AmountChangedDelete extends SavingsEditEvent {
  const AmountChangedDelete();
}

class FeeChanged extends SavingsEditEvent {
  const FeeChanged(this.fee);

  final String fee;

  @override
  List<Object> get props => [fee];
}

class LoadIsEnabled extends SavingsEditEvent {
  const LoadIsEnabled();
}

class SendSubmitted extends SavingsEditEvent {
  const SendSubmitted();
}
