import 'dart:async';
import 'dart:developer' as developer;

import 'package:deuro_wallet/models/asset.dart';
import 'package:deuro_wallet/models/blockchain.dart';
import 'package:deuro_wallet/packages/open_crypto_pay/models.dart';
import 'package:deuro_wallet/packages/open_crypto_pay/open_crypto_pay_service.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/packages/utils/default_assets.dart';
import 'package:deuro_wallet/packages/utils/format_fixed.dart';
import 'package:deuro_wallet/packages/utils/parse_fixed.dart';
import 'package:deuro_wallet/packages/wallet/create_transaction.dart';
import 'package:deuro_wallet/router.dart';
import 'package:deuro_wallet/screens/send_invoice/bloc/expiry_cubit.dart';
import 'package:deuro_wallet/screens/transaction_sent/transaction_sent_page.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'send_invoice_event.dart';
part 'send_invoice_state.dart';

class SendInvoiceBloc extends Bloc<SendInvoiceEvent, SendInvoiceState> {
  SendInvoiceBloc(this._appStore, this._openCryptoPayService,
      {required OpenCryptoPayRequest invoice})
      : expiryCubit = ExpiryCubit(invoice.expiration),
        super(SendInvoiceState(invoice: invoice)) {
    on<ChainChanged>(_onChainChanged);
    on<FeeChanged>(_onFeeChanged);
    on<CancelInvoice>(_onCancelInvoice);
    on<SendSubmitted>(_onSubmitted);

    _startFeeSync();
  }

  @override
  Future<void> close() {
    _feeTimer?.cancel();
    return super.close();
  }

  final ExpiryCubit expiryCubit;

  final AppStore _appStore;
  final OpenCryptoPayService _openCryptoPayService;

  Timer? _feeTimer;

  void _onChainChanged(ChainChanged event, Emitter<SendInvoiceState> emit) {
    emit(state.copyWith(asset: _getAsset(event.blockchain)));
    _startFeeSync();
  }

  void _onFeeChanged(FeeChanged event, Emitter<SendInvoiceState> emit) {
    emit(state.copyWith(fee: event.fee));
  }

  Future<void> _onCancelInvoice(
      CancelInvoice event, Emitter<SendInvoiceState> emit) async {
    await _openCryptoPayService.cancelOpenCryptoPayRequest(state.invoice);
    _feeTimer?.cancel();
  }

  Future<void> _onSubmitted(
      SendSubmitted event, Emitter<SendInvoiceState> emit) async {
    emit(state.copyWith(status: SendStatus.inProgress));
    try {
      final gasPrice =
          state.invoice.methods[state.blockchain.name]!.first.gasFee;

      final uri = await _openCryptoPayService.getOpenCryptoPayAddress(
          state.invoice, state.asset);

      final transaction = await prepareERC20Transaction(
        _appStore.getClient(state.asset.chainId),
        currentAccount: _appStore.wallet.currentAccount.primaryAddress,
        receiveAddress: uri.address,
        amount: parseFixed(uri.amount, 18),
        contractAddress: state.asset.address,
        chainId: state.asset.chainId,
        gasPrice: gasPrice,
      );

      final id = await _openCryptoPayService.commitOpenCryptoPayRequest(
          '0x$transaction',
          request: state.invoice,
          asset: state.asset);
      developer.log(id, name: 'SendInvoiceBloc');
      emit(state.copyWith(status: SendStatus.success));

      if (navigatorKey.currentContext != null) {
        navigatorKey.currentContext?.pop();
        showCupertinoSheet(
            context: navigatorKey.currentContext!,
            pageBuilder: (_) => TransactionSentPage(transactionId: id));
      }
    } catch (e) {
      developer.log('Error during send!', error: e, name: 'SendInvoiceBloc');
      emit(state.copyWith(status: SendStatus.failure));
    }
  }

  void _startFeeSync() {
    final priorityFee = 0;
    final client = _appStore.getClient(state.asset.chainId);
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
