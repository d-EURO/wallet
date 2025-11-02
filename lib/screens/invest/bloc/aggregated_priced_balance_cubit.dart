import 'dart:async';

import 'package:deuro_wallet/models/balance.dart';
import 'package:deuro_wallet/packages/repository/balance_repository.dart';
import 'package:deuro_wallet/packages/service/price_service.dart';
import 'package:deuro_wallet/packages/utils/default_assets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AggregatedPricedBalance {
  final List<Balance> balances;
  final BigInt price;

  BigInt get balance {
    BigInt aggregate = BigInt.zero;
    for (final bla in balances) {
      aggregate += bla.balance;
    }
    return aggregate;
  }

  BigInt get value =>
      BigInt.from((price * balance) / BigInt.parse("1000000000000000000"));

  const AggregatedPricedBalance({required this.balances, required this.price});

  AggregatedPricedBalance copyWith({List<Balance>? balances, BigInt? price}) =>
      AggregatedPricedBalance(
        balances: balances ?? this.balances,
        price: price ?? this.price,
      );
}

class AggregatedPricedBalanceCubit extends Cubit<AggregatedPricedBalance> {
  AggregatedPricedBalanceCubit(
    this._repository,
    this._priceService,
    this._balances,
  ) : super(AggregatedPricedBalance(
          balances: _balances,
          price: BigInt.zero,
        )) {
    for (final balance in _balances) {
      _subscriptions
          .add(_repository.watchBalance(balance).listen(_updateBalances));
    }
  }

  final List<StreamSubscription<Balance>> _subscriptions = [];
  final List<Balance> _balances;
  final BalanceRepository _repository;
  final APriceService _priceService;

  @override
  Future<void> close() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    return super.close();
  }

  Future<void> _updateDEuroValue() async {
    if (state.price > BigInt.zero) return;

    final price = await _priceService.getPriceOfAsset(nDEPSAsset);
    emit(state.copyWith(price: price));
  }

  void _updateBalances(Balance balance) {
    _balances.firstWhere((row) => row == balance).balance = balance.balance;
    emit(state.copyWith(balances: _balances));
    _updateDEuroValue();
  }
}
