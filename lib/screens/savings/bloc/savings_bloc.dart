import 'dart:async';
import 'dart:developer' as developer;

import 'package:deuro_wallet/constants.dart';
import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/models/blockchain.dart';
import 'package:deuro_wallet/packages/contracts/contracts.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/packages/utils/default_assets.dart';
import 'package:deuro_wallet/packages/utils/format_fixed.dart';
import 'package:deuro_wallet/router.dart';
import 'package:deuro_wallet/widgets/confirm_bottom_sheet.dart';
import 'package:deuro_wallet/widgets/error_bottom_sheet.dart';
import 'package:equatable/equatable.dart';
import 'package:erc20/erc20.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:web3dart/web3dart.dart';

part 'savings_event.dart';
part 'savings_state.dart';

class SavingsBloc extends Bloc<SavingsEvent, SavingsState> {
  SavingsBloc(this._appStore) : super(SavingsState()) {
    on<LoadSavingsBalance>(_onLoadSavingsBalance);
    on<EnableSavings>(_onEnableSavings);
    on<LoadIsEnabled>(_onLoadIsEnabled);
    on<CollectInterest>(_onCollectInterest);

    _client = _appStore.getClient(1);
    _savingsGateway = getSavingsGateway(_client);

    add(LoadSavingsBalance());
    add(LoadIsEnabled());
  }

  final AppStore _appStore;
  late final Web3Client _client;
  late final SavingsGateway _savingsGateway;
  final Blockchain _blockchain = Blockchain.ethereum;

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
      developer.log('Error during loading enabled',
          error: e, name: 'SavingsBloc');
    }
  }

  Future<void> _onEnableSavings(
      EnableSavings event, Emitter<SavingsState> emit) async {
    if (state.isActivatingSavings) return;
    if (!(await _checkRequiredEth())) return;

    try {
      emit(state.copyWith(isActivatingSavings: true));
      final dEuro = ERC20(
          address: EthereumAddress.fromHex(dEUROAsset.address),
          client: _client);

      final maxBigInt = BigInt.parse(
        'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
        radix: 16,
      );

      final estimatedFee = await _client.estimateGas(
        sender: _appStore.wallet.primaryAccount.primaryAddress.address,
        to: dEuro.self.address,
        data: dEuro.self.function("approve").encodeCall([
          EthereumAddress.fromHex(savingsGatewayAddress),
          maxBigInt,
        ]),
      );

      final confirmed = await showModalBottomSheet<bool>(
        context: navigatorKey.currentContext!,
        builder: (context) => ConfirmBottomSheet(
          onConfirm: () => context.pop(true),
          title: S.current.savings_enable,
          message: S.current.savings_enable_confirm_content(_blockchain.name),
          fee: "~${formatFixed(estimatedFee, 9)}",
          feeSymbol: _blockchain.nativeSymbol,
        ),
      );

      if (confirmed == true) {
        final txId = await dEuro.approve(
            EthereumAddress.fromHex(savingsGatewayAddress), maxBigInt,
            credentials: _appStore.wallet.primaryAccount.primaryAddress);
        developer.log('Infinite approval for Savings Contract: $txId',
            name: 'SavingsBloc');
        emit(state.copyWith(isEnabled: true, isActivatingSavings: false));
      } else {
        emit(state.copyWith(isActivatingSavings: false));
      }
    } catch (e) {
      developer.log('Error during enabling savings',
          error: e, name: 'SavingsBloc._onEnableSavings');
    }
  }

  Future<void> _onCollectInterest(
      CollectInterest event, Emitter<SavingsState> emit) async {
    if (state.isCollectingInterest) return;
    if (!(await _checkRequiredEth())) return;

    try {
      emit(state.copyWith(isCollectingInterest: true));
      final savingsGateway = getSavingsGateway(_client);
      final ownerAddress = EthereumAddress.fromHex(_appStore.primaryAddress);

      final interestToCollect =
          await savingsGateway.accruedInterest((accountOwner: ownerAddress,));

      final estimatedFee = await _client.estimateGas(
        sender: _appStore.wallet.primaryAccount.primaryAddress.address,
        to: savingsGateway.self.address,
        data: savingsGateway.self.abi.functions[24]
            .encodeCall([ownerAddress, interestToCollect, frontendCode]),
      );

      final confirmed = await showModalBottomSheet<bool>(
        context: navigatorKey.currentContext!,
        builder: (context) => ConfirmBottomSheet(
          onConfirm: () => context.pop(true),
          title: S.current.savings_collect_interest_confirm_title,
          message: S.current
              .savings_collect_interest_confirm_content(_blockchain.name),
          fee: "~${formatFixed(estimatedFee, 9)}",
          feeSymbol: _blockchain.nativeSymbol,
        ),
      );

      if (confirmed == true) {
        final txId = await savingsGateway.withdraw$2((
          amount: interestToCollect,
          frontendCode: frontendCode,
          target: ownerAddress,
        ), credentials: _appStore.wallet.primaryAccount.primaryAddress);
        developer.log('Collect Interest in TX($txId)', name: 'SavingsBloc');
        add(LoadSavingsBalance());
      }
      emit(state.copyWith(isCollectingInterest: false));
    } catch (e) {
      developer.log('Error during collecting interest',
          error: e, name: 'SavingsBloc._onCollectInterest');
      emit(state.copyWith(isCollectingInterest: false));
    }
  }

  Future<void> _onLoadSavingsBalance(
      LoadSavingsBalance event, Emitter<SavingsState> emit) async {
    final interestRate = await _savingsGateway.currentRatePPM();
    final amount = await _savingsGateway
        .savings(($param19: EthereumAddress.fromHex(_appStore.primaryAddress)));
    final intrest = await _savingsGateway.accruedInterest(
        (accountOwner: EthereumAddress.fromHex(_appStore.primaryAddress)));
    emit(state.copyWith(
        amount: amount.saved.toRadixString(16),
        interestRate: interestRate.toRadixString(16),
        accruedInterest: intrest.toRadixString(16)));
  }

  Future<bool> _checkRequiredEth() async {
    final ethBalance = await _client
        .getBalance(_appStore.wallet.primaryAccount.primaryAddress.address);
    if (ethBalance.getInWei < BigInt.from(3000)) {
      final blockchain = Blockchain.ethereum;
      showModalBottomSheet(
          context: navigatorKey.currentContext!,
          builder: (_) => ErrorBottomSheet(
              message: S.current.error_not_enough_money(
                  blockchain.nativeSymbol, blockchain.name)));
      return false;
    }
    return true;
  }
}
