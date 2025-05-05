import 'dart:async';
import 'dart:developer' as dev;

import 'package:deuro_wallet/models/asset.dart';
import 'package:deuro_wallet/models/blockchain.dart';
import 'package:deuro_wallet/packages/contracts/SavingsGateway.g.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/packages/utils/format_fixed.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

part 'savings_event.dart';

part 'savings_state.dart';

class SavingsBloc extends Bloc<SavingsEvent, SavingsState> {
  SavingsBloc(this._appStore) : super(SavingsState()) {
    on<LoadSavingsBalance>(_onLoadSavingsBalance);
    on<FeeChanged>(_onFeeChanged);

    _savingsGatewayAddress =
        EthereumAddress.fromHex("0x073493d73258C4BEb6542e8dd3e1b2891C972303");
    _client = _appStore.getClient(1);
    _savingsGateway = SavingsGateway(
      address: _savingsGatewayAddress,
      client: _client,
    );

    add(LoadSavingsBalance());
    _startFeeSync();
  }

  @override
  Future<void> close() {
    _feeTimer?.cancel();
    return super.close();
  }

  final AppStore _appStore;
  late final Web3Client _client;
  late final EthereumAddress _savingsGatewayAddress;
  late final SavingsGateway _savingsGateway;

  Timer? _feeTimer;

  Future<void> _onLoadSavingsBalance(LoadSavingsBalance event,
      Emitter<SavingsState> emit) async {
    final amount = await _savingsGateway.savings(
        ($param19: EthereumAddress.fromHex(_appStore.primaryAddress)));
    final intrest = await _savingsGateway.accruedInterest((accountOwner: EthereumAddress.fromHex(_appStore.primaryAddress)));
    emit(state.copyWith(amount: amount.saved.toRadixString(16), interest: intrest.toRadixString(16)));
  }

  void _onFeeChanged(FeeChanged event, Emitter<SavingsState> emit) {
    emit(state.copyWith(fee: event.fee));
  }

  void _startFeeSync() {
    final priorityFee = 0;
    _feeTimer?.cancel();
    _feeTimer = Timer.periodic(Duration(seconds: 1), (_) async {
      try {
        final gasPrice = await _client.getGasPrice();
        final estimatedGas = await _client.estimateGas(
            data: hexToBytes(
                "0x753ef93c0000000000000000000000000000000000000000000000008ac7230489e80000000000000000000000000000000000000000004265596f75724f776e42616e6b"));
        final fee =
            (gasPrice.getInWei + BigInt.from(priorityFee)) * estimatedGas;
        final feeString = formatFixed(fee, 18, fractionalDigits: 6);
        add(FeeChanged(feeString));
      } on StateError catch (_) {}
    });
  }
}
