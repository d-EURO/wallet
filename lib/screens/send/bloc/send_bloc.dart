import 'dart:async';
import 'dart:developer' as developer;

import 'package:deuro_wallet/models/asset.dart';
import 'package:deuro_wallet/models/blockchain.dart';
import 'package:deuro_wallet/packages/service/alias_resolver/alias_resolver.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/packages/utils/default_assets.dart';
import 'package:deuro_wallet/packages/utils/format_fixed.dart';
import 'package:deuro_wallet/packages/utils/parse_fixed.dart';
import 'package:deuro_wallet/packages/wallet/create_transaction.dart';
import 'package:deuro_wallet/packages/wallet/is_evm_address.dart';
import 'package:deuro_wallet/packages/wallet/transaction_priority.dart';
import 'package:deuro_wallet/router.dart';
import 'package:deuro_wallet/screens/transaction_sent/transaction_sent_page.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'send_event.dart';
part 'send_state.dart';

class SendBloc extends Bloc<SendEvent, SendState> {
  SendBloc(this._appStore,
      {required Asset asset, String receiver = '', String amount = '0'})
      : super(SendState(asset: asset, receiver: receiver, amount: amount)) {
    on<SelectAlias>(_onSelectAlias);
    on<ReceiverChanged>(_onReceiverChanged);
    on<AmountChangedAdd>(_onAmountAdd);
    on<AmountChangedDecimal>(_onAmountDecimal);
    on<AmountChangedDelete>(_onAmountRemove);
    on<ChainChanged>(_onChainChanged);
    on<FeeChanged>(_onFeeChanged);
    on<SendSubmitted>(_onSubmitted);

    _startFeeSync();
  }

  @override
  Future<void> close() {
    _feeTimer?.cancel();
    return super.close();
  }

  final AppStore _appStore;

  Timer? _feeTimer;

  Future<void> _onReceiverChanged(
      ReceiverChanged event, Emitter<SendState> emit) async {
    emit(state.copyWith(receiver: event.receiver));
    if (event.receiver.contains(".")) {
      final resolvedAlias = await AliasResolver.resolve(
        _appStore.getClient(1),
        alias: event.receiver,
        ticker: state.asset.symbol,
        tickerFallback: "ETH",
      );
      emit(state.copyAlias(alias: resolvedAlias));
    } else {
      emit(state.copyAlias());
    }
  }

  Future<void> _onSelectAlias(
      SelectAlias event, Emitter<SendState> emit) async {
    emit(state.copyWith(receiver: state.alias?.address));
  }

  void _onAmountAdd(AmountChangedAdd event, Emitter<SendState> emit) {
    emit(state.copyWith(
      amount: state.amount == '0'
          ? event.amount.toString()
          : '${state.amount}${event.amount}',
    ));
  }

  void _onAmountDecimal(AmountChangedDecimal event, Emitter<SendState> emit) {
    emit(state.copyWith(amount: '${state.amount.replaceAll('.', '')}.'));
  }

  void _onAmountRemove(AmountChangedDelete event, Emitter<SendState> emit) {
    emit(state.copyWith(
      amount: state.amount.length > 1
          ? state.amount.substring(0, state.amount.length - 1)
          : '0',
    ));
  }

  void _onChainChanged(ChainChanged event, Emitter<SendState> emit) {
    emit(state.copyWith(asset: _getAsset(event.blockchain)));
    _startFeeSync();
  }

  void _onFeeChanged(FeeChanged event, Emitter<SendState> emit) {
    emit(state.copyWith(fee: event.fee));
  }

  Future<void> _onSubmitted(
      SendSubmitted event, Emitter<SendState> emit) async {
    if (state.receiver.isEthereumAddress) {
      emit(state.copyWith(status: SendStatus.inProgress));
      try {
        final transaction = await createERC20Transaction(
          _appStore.getClient(state.blockchain.chainId),
          currentAccount: _appStore.wallet.currentAccount.primaryAddress,
          receiveAddress: state.receiver,
          amount: parseFixed(state.amount, state.asset.decimals),
          contractAddress: state.asset.address,
          chainId: state.blockchain.chainId,
          priority: TransactionPriority.slow,
        );

        final id = await transaction();
        developer.log(id, name: 'SendBloc');
        emit(state.copyWith(status: SendStatus.success));

        if (navigatorKey.currentContext != null) {
          navigatorKey.currentContext?.pop();
          showCupertinoSheet(
              context: navigatorKey.currentContext!,
              pageBuilder: (_) => TransactionSentPage(transactionId: id));
        }
      } catch (e) {
        developer.log('Error during send!', error: e, name: 'SendBloc');
        emit(state.copyWith(status: SendStatus.failure));
      }
    }
  }

  void _startFeeSync() {
    final priorityFee = 0;
    final client = _appStore.getClient(state.blockchain.chainId);
    _feeTimer?.cancel();
    _feeTimer = Timer.periodic(Duration(seconds: 1), (_) async {
      try {
        final gasPrice = await client.getGasPrice();
        final estimatedGas = await client.estimateGas();
        final fee =
            (gasPrice.getInWei + BigInt.from(priorityFee)) * estimatedGas;
        final feeString = fee < BigInt.parse('1000000000000')
            ? '< 0.000001'
            : formatFixed(fee, 18, fractionalDigits: 6);
        add(FeeChanged(feeString));
      } on StateError catch (_) {}
    });
  }

  Asset _getAsset(Blockchain blockchain) {
    switch (blockchain) {
      case Blockchain.ethereum:
        return dEUROAsset;
      case Blockchain.polygon:
        return dEUROPolygonAsset;
      case Blockchain.arbitrum:
        return dEUROArbitrumAsset;
      case Blockchain.base:
        return dEUROBaseAsset;
      case Blockchain.optimism:
        return dEUROOptimismAsset;
    }
  }
}
