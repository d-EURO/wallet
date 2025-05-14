import 'dart:async';
import 'dart:developer' as dev;

import 'package:deuro_wallet/packages/contracts/contracts.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/packages/utils/default_assets.dart';
import 'package:equatable/equatable.dart';
import 'package:erc20/erc20.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web3dart/web3dart.dart';

part 'savings_event.dart';
part 'savings_state.dart';

class SavingsBloc extends Bloc<SavingsEvent, SavingsState> {
  SavingsBloc(this._appStore) : super(SavingsState()) {
    on<LoadSavingsBalance>(_onLoadSavingsBalance);
    on<LoadIsEnabled>(_onLoadIsEnabled);

    _client = _appStore.getClient(1);
    _savingsGateway = getSavingsGateway(_client);

    add(LoadSavingsBalance());
    add(LoadIsEnabled());
  }

  @override
  Future<void> close() {
    _feeTimer?.cancel();
    return super.close();
  }

  final AppStore _appStore;
  late final Web3Client _client;
  late final SavingsGateway _savingsGateway;

  Timer? _feeTimer;

  Future<void> _onLoadIsEnabled(
      LoadIsEnabled event, Emitter<SavingsState> emit) async {
    try {
      final dEuro = ERC20(
          address: EthereumAddress.fromHex(dEUROAsset.address),
          client: _client);

      final allowance = await dEuro.allowance(
          _appStore.wallet.primaryAccount.primaryAddress.address,
          EthereumAddress.fromHex(savingsGatewayAddress));
      emit(state.copyWith(isEnabled: allowance > BigInt.zero));
    } catch (e) {
      dev.log("Error during loading enabled", error: e);
    }
  }

  Future<void> _onEnableSavings(
      LoadIsEnabled event, Emitter<SavingsState> emit) async {
    try {
      final dEuro = ERC20(
          address: EthereumAddress.fromHex(dEUROAsset.address),
          client: _client);

      final txId = await dEuro.approve(
          EthereumAddress.fromHex(savingsGatewayAddress),
          BigInt.parse(
              'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
              radix: 16),
          credentials: _appStore.wallet.primaryAccount.primaryAddress);
      dev.log("Infinite approval for Savings Contract: $txId");
      emit(state.copyWith(isEnabled: true));
    } catch (e) {
      dev.log("Error during loading enabled", error: e);
    }
  }

  Future<void> _onLoadSavingsBalance(
      LoadSavingsBalance event, Emitter<SavingsState> emit) async {
    final amount = await _savingsGateway
        .savings(($param19: EthereumAddress.fromHex(_appStore.primaryAddress)));
    final intrest = await _savingsGateway.accruedInterest(
        (accountOwner: EthereumAddress.fromHex(_appStore.primaryAddress)));
    emit(state.copyWith(
        amount: amount.saved.toRadixString(16),
        interest: intrest.toRadixString(16)));
  }
}
