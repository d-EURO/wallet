import 'dart:async';
import 'dart:developer' as dev;

import 'package:deuro_wallet/models/asset.dart';
import 'package:deuro_wallet/models/blockchain.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/packages/utils/format_fixed.dart';
import 'package:deuro_wallet/packages/utils/parse_fixed.dart';
import 'package:deuro_wallet/packages/wallet/create_transaction.dart';
import 'package:deuro_wallet/packages/wallet/is_evm_address.dart';
import 'package:deuro_wallet/packages/wallet/transaction_priority.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'send_event.dart';
part 'send_state.dart';

class SendBloc extends Bloc<SendEvent, SendState> {
  SendBloc(this._appStore, this._asset) : super(SendState()) {
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
  final Asset _asset;

  Timer? _feeTimer;

  void _onReceiverChanged(ReceiverChanged event, Emitter<SendState> emit) {
    emit(state.copyWith(receiver: event.receiver));
  }

  void _onAmountAdd(AmountChangedAdd event, Emitter<SendState> emit) {
    emit(state.copyWith(
      amount: state.amount == "0"
          ? event.amount.toString()
          : "${state.amount}${event.amount}",
    ));
  }

  void _onAmountDecimal(AmountChangedDecimal event, Emitter<SendState> emit) {
    emit(state.copyWith(amount: "${state.amount.replaceAll(".", "")}."));
  }

  void _onAmountRemove(AmountChangedDelete event, Emitter<SendState> emit) {
    emit(state.copyWith(
      amount: state.amount.length > 1
          ? state.amount.substring(0, state.amount.length - 1)
          : "0",
    ));
  }

  void _onChainChanged(ChainChanged event, Emitter<SendState> emit) {
    emit(state.copyWith(blockchain: event.blockchain));
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
          amount: parseFixed(state.amount, _asset.decimals),
          contractAddress: _asset.address,
          chainId: state.blockchain.chainId,
          priority: TransactionPriority.slow,
        );

        final id = await transaction();
        dev.log(id);
        // ToDo: Perform Send
        emit(state.copyWith(status: SendStatus.success));
      } catch (e) {
        dev.log("Error during send!", error: e);
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
        final feeString = fee < BigInt.parse("1000000000000")
            ? "< 0.000001"
            : formatFixed(fee, 18, fractionalDigits: 6);
        add(FeeChanged(feeString));
      } on StateError catch (_) {}
    });
  }
}
