import 'dart:async';
import 'dart:developer' as developer;

import 'package:deuro_wallet/constants.dart';
import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/models/asset.dart';
import 'package:deuro_wallet/models/blockchain.dart';
import 'package:deuro_wallet/packages/contracts/contracts.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/packages/utils/default_assets.dart';
import 'package:deuro_wallet/packages/utils/format_fixed.dart';
import 'package:deuro_wallet/packages/utils/parse_fixed.dart';
import 'package:deuro_wallet/packages/wallet/transaction_priority.dart';
import 'package:deuro_wallet/router.dart';
import 'package:deuro_wallet/screens/transaction_sent/transaction_sent_page.dart';
import 'package:deuro_wallet/widgets/error_bottom_sheet.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:web3dart/web3dart.dart';

part 'savings_edit_event.dart';
part 'savings_edit_state.dart';

class SavingsEditBloc extends Bloc<SavingsEditEvent, SavingsEditState> {
  SavingsEditBloc(this._appStore, this.isAdding) : super(SavingsEditState()) {
    on<AmountChangedAdd>(_onAmountAdd);
    on<AmountChangedDecimal>(_onAmountDecimal);
    on<AmountChangedDelete>(_onAmountRemove);
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
  final bool isAdding;

  Asset get _asset => dEUROAsset;

  Web3Client get client => _appStore.getClient(Blockchain.ethereum.chainId);

  Timer? _feeTimer;

  void _onAmountAdd(AmountChangedAdd event, Emitter<SavingsEditState> emit) {
    emit(state.copyWith(
      amount: state.amount == '0'
          ? event.amount.toString()
          : '${state.amount}${event.amount}',
    ));
  }

  void _onAmountDecimal(
      AmountChangedDecimal event, Emitter<SavingsEditState> emit) {
    emit(state.copyWith(amount: '${state.amount.replaceAll('.', '')}.'));
  }

  void _onAmountRemove(
      AmountChangedDelete event, Emitter<SavingsEditState> emit) {
    emit(state.copyWith(
      amount: state.amount.length > 1
          ? state.amount.substring(0, state.amount.length - 1)
          : '0',
    ));
  }

  void _onFeeChanged(FeeChanged event, Emitter<SavingsEditState> emit) {
    emit(state.copyWith(fee: event.fee));
  }

  Future<void> _onSubmitted(
      SendSubmitted event, Emitter<SavingsEditState> emit) async {
    emit(state.copyWith(status: SendStatus.inProgress));

    final currentAccount = _appStore.wallet.primaryAccount.primaryAddress;

    final ethBalance = await client.getBalance(currentAccount.address);
    if (ethBalance.getInWei < parseFixed(state.fee, 18)) {
      return showModalBottomSheet(
          context: navigatorKey.currentContext!,
          builder: (_) => ErrorBottomSheet(
              message: S.current.error_not_enough_money(
                  state.blockchain.nativeSymbol, state.blockchain.name)));
    }

    try {
      final savings = getSavingsGateway(client);
      final amount = parseFixed(state.amount, _asset.decimals);
      final priority = TransactionPriority.slow;

      // final frontendGateway = getFrontendGateway(client);
      // final frontendCode = Uint8List.fromList(sha256.convert(utf8.encode('wallet')).bytes);
      // dev.log(bytesToHex(frontendCode));
      // final txId = await frontendGateway.registerFrontendCode((frontendCode: frontendCode), credentials: _appStore.wallet.primaryAccount.primaryAddress);

      final transaction = Transaction(
        from: currentAccount.address,
        to: savings.self.address,
        maxPriorityFeePerGas: state.blockchain.chainId == 1
            ? EtherAmount.fromInt(EtherUnit.gwei, priority.tip)
            : null,
        value: EtherAmount.zero(),
      );

      final txId = await (isAdding
          ? savings.save(
              (
                amount: amount,
                frontendCode: frontendCode,
              ),
              transaction: transaction,
              credentials: currentAccount,
            )
          : savings.withdraw$2(
              (
                amount: amount,
                frontendCode: frontendCode,
                target: currentAccount.address,
              ),
              transaction: transaction,
              credentials: currentAccount,
            ));

      developer.log(txId, name: 'SavingsEditBloc');
      emit(state.copyWith(status: SendStatus.success));

      if (navigatorKey.currentContext != null) {
        navigatorKey.currentContext?.pop();
        showCupertinoSheet(
          context: navigatorKey.currentContext!,
          pageBuilder: (_) => TransactionSentPage(
            title: S.current.transaction_sent,
            transactionId: txId,
            blockchain: state.blockchain,
          ),
        );
      }
    } catch (e) {
      developer.log('Error during send!', error: e, name: 'SavingsEditBloc');
      emit(state.copyWith(status: SendStatus.failure));
    }
  }

  void _startFeeSync() {
    final priorityFee = 0;
    _feeTimer?.cancel();
    _feeTimer = Timer.periodic(Duration(seconds: 1), (_) async {
      try {
        final gasPrice = await client.getGasPrice();
        final estimatedGas = await client.estimateGas();
        final fee =
            (gasPrice.getInWei + BigInt.from(priorityFee)) * estimatedGas;
        final feeString = formatFixed(fee, 18, fractionalDigits: 6);
        add(FeeChanged(feeString));
      } on StateError catch (_) {}
    });
  }
}
