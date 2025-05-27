import 'dart:async';
import 'dart:developer' as developer;

import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/models/asset.dart';
import 'package:deuro_wallet/models/blockchain.dart';
import 'package:deuro_wallet/packages/service/alias_resolver/alias_resolver.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/packages/utils/default_assets.dart';
import 'package:deuro_wallet/packages/utils/parse_fixed.dart';
import 'package:deuro_wallet/packages/wallet/create_transaction.dart';
import 'package:deuro_wallet/packages/wallet/is_evm_address.dart';
import 'package:deuro_wallet/packages/wallet/transaction_priority.dart';
import 'package:deuro_wallet/router.dart';
import 'package:deuro_wallet/screens/send/bloc/gas_fee_cubit.dart';
import 'package:deuro_wallet/screens/transaction_sent/transaction_sent_page.dart';
import 'package:deuro_wallet/widgets/error_bottom_sheet.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'send_event.dart';
part 'send_state.dart';

class SendBloc extends Bloc<SendEvent, SendState> {
  SendBloc(this._appStore,
      {required Asset asset, String receiver = '', String amount = '0'})
      : gasFeeCubit =
            GasFeeCubit(_appStore, Blockchain.getFromChainId(asset.chainId)),
        super(SendState(asset: asset, receiver: receiver, amount: amount)) {
    on<SelectAlias>(_onSelectAlias);
    on<ReceiverChanged>(_onReceiverChanged);
    on<AmountChangedAdd>(_onAmountAdd);
    on<AmountChangedDecimal>(_onAmountDecimal);
    on<AmountChangedDelete>(_onAmountRemove);
    on<ChainChanged>(_onChainChanged);
    on<SendSubmitted>(_onSubmitted);
  }

  @override
  Future<void> close() async {
    await gasFeeCubit.close();
    return super.close();
  }

  final GasFeeCubit gasFeeCubit;
  final AppStore _appStore;

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
    gasFeeCubit.blockchain = event.blockchain;
  }

  Future<void> _onSubmitted(
      SendSubmitted event, Emitter<SendState> emit) async {
    if (state.receiver.isEthereumAddress) {
      final client = _appStore.getClient(state.blockchain.chainId);
      final ethBalance = await client
          .getBalance(_appStore.wallet.currentAccount.primaryAddress.address);
      if (ethBalance.getInWei < gasFeeCubit.state.gasFee) {
        return showModalBottomSheet(
          context: navigatorKey.currentContext!,
          builder: (_) => ErrorBottomSheet(
            message: S.current.error_not_enough_money(
                state.blockchain.nativeSymbol, state.blockchain.name),
          ),
        );
      }

      emit(state.copyWith(status: SendStatus.inProgress));
      try {
        final transaction = await createERC20Transaction(
          client,
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
            pageBuilder: (_) => TransactionSentPage(
              title: S.current.transaction_sent,
              transactionId: id,
              blockchain: state.blockchain,
            ),
          );
        }
      } catch (e) {
        developer.log('Error during send!', error: e, name: 'SendBloc');
        emit(state.copyWith(status: SendStatus.failure));
      }
    }
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
