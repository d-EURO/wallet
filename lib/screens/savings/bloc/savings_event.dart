part of 'savings_bloc.dart';

sealed class SavingsEvent extends Equatable {
  const SavingsEvent();

  @override
  List<Object> get props => [];
}

final class FeeChanged extends SavingsEvent {
  const FeeChanged(this.fee);

  final String fee;

  @override
  List<Object> get props => [fee];
}

final class LoadSavingsBalance extends SavingsEvent {
  const LoadSavingsBalance();
}
