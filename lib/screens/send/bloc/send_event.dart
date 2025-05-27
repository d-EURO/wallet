part of 'send_bloc.dart';

sealed class SendEvent extends Equatable {
  const SendEvent();

  @override
  List<Object> get props => [];
}

final class AmountChangedAdd extends SendEvent {
  const AmountChangedAdd(this.amount);

  final int amount;

  @override
  List<Object> get props => [amount];
}

final class AmountChangedDecimal extends SendEvent {
  const AmountChangedDecimal();
}

final class AmountChangedDelete extends SendEvent {
  const AmountChangedDelete();
}

final class ReceiverChanged extends SendEvent {
  const ReceiverChanged(this.receiver);

  final String receiver;

  @override
  List<Object> get props => [receiver];
}

final class SelectAlias extends SendEvent {
  const SelectAlias();
}

final class ChainChanged extends SendEvent {
  const ChainChanged(this.blockchain);

  final Blockchain blockchain;

  @override
  List<Object> get props => [blockchain];
}

final class SendSubmitted extends SendEvent {
  const SendSubmitted();
}
