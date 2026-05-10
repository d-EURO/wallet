import 'dart:async';
import 'dart:developer' as developer;

import 'package:deuro_wallet/constants.dart';
import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/models/blockchain.dart';
import 'package:deuro_wallet/packages/contracts/Savings.g.dart';
import 'package:deuro_wallet/packages/contracts/contracts.dart';
import 'package:deuro_wallet/packages/repository/cache_repository.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/packages/utils/default_assets.dart';
import 'package:deuro_wallet/packages/utils/format_fixed.dart';
import 'package:deuro_wallet/packages/wallet/transaction_priority.dart';
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
  SavingsBloc(this._appStore, this._cacheRepository) : super(SavingsState()) {
    on<EnableSavings>(_onEnableSavings);
    on<LoadIsEnabled>(_onLoadIsEnabled);
    on<LoadSavingsBalance>(_onLoadSavingsBalance);
    on<LoadFromCache>(_onLoadFromCache);
    on<CollectInterest>(_onCollectInterest);
    on<CompoundInterest>(_onCompoundInterest);
    on<WithdrawV1Submitted>(_onWithdrawSubmitted);

    _client = _appStore.getClient(1);
    _savings = getSavingsV2(_client);

    add(LoadFromCache());
    add(LoadSavingsBalance());
    add(LoadIsEnabled());
    startSync();
  }

  final AppStore _appStore;
  final CacheRepository _cacheRepository;
  late final Web3Client _client;
  late final Savings _savings;
  final Blockchain _blockchain = Blockchain.ethereum;

  static const String cacheKeySavingsInterestRate = 'savings_interest_rate';
  static const String cacheKeySavingsBalance = 'savings_balance';
  static const String cacheKeySavingsAccruedInterest = 'savings_accrued_interest';

  Timer? _refreshTimer;

  void startSync() {
    _refreshTimer = Timer.periodic(Duration(seconds: 10), (_) => add(LoadSavingsBalance()));
  }

  @override
  Future<void> close() async {
    _refreshTimer?.cancel();
    super.close();
  }

  Future<void> _onLoadIsEnabled(LoadIsEnabled event, Emitter<SavingsState> emit) async {
    try {
      final dEuro = ERC20(address: EthereumAddress.fromHex(dEUROAsset.address), client: _client);

      final allowance = await dEuro.allowance(
          _appStore.wallet.primaryAccount.primaryAddress.address,
          EthereumAddress.fromHex(savingsGatewayV2Address));
      emit(state.copyWith(isEnabled: allowance > BigInt.zero));
    } catch (e) {
      developer.log('Error during loading enabled', error: e, name: 'SavingsBloc');
    }
  }

  Future<void> _onEnableSavings(EnableSavings event, Emitter<SavingsState> emit) async {
    if (state.isActivatingSavings) return;
    if (!(await _checkRequiredEth())) return;

    try {
      emit(state.copyWith(isActivatingSavings: true));
      final dEuro = ERC20(address: EthereumAddress.fromHex(dEUROAsset.address), client: _client);

      final maxBigInt = BigInt.parse(
        'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
        radix: 16,
      );

      final estimatedFee = await _client.estimateGas(
        sender: _appStore.wallet.primaryAccount.primaryAddress.address,
        to: dEuro.self.address,
        data: dEuro.self.function("approve").encodeCall([
          EthereumAddress.fromHex(savingsGatewayV2Address),
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
            EthereumAddress.fromHex(savingsGatewayV2Address), maxBigInt,
            credentials: _appStore.wallet.primaryAccount.primaryAddress);
        developer.log('Infinite approval for Savings Contract: $txId', name: 'SavingsBloc');
        emit(state.copyWith(isEnabled: true, isActivatingSavings: false));
      } else {
        emit(state.copyWith(isActivatingSavings: false));
      }
    } catch (e) {
      developer.log('Error during enabling savings',
          error: e, name: 'SavingsBloc._onEnableSavings');
    }
  }

  Future<void> _onCollectInterest(CollectInterest event, Emitter<SavingsState> emit) async {
    if (state.isCollectingInterest) return;
    if (!(await _checkRequiredEth())) return;

    try {
      emit(state.copyWith(isCollectingInterest: true));
      final savingsGateway = getSavingsV2(_client);
      final ownerAddress = EthereumAddress.fromHex(_appStore.primaryAddress);

      final interestToCollect = await savingsGateway.accruedInterest((accountOwner: ownerAddress,));

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
          message: S.current.savings_collect_interest_confirm_content(_blockchain.name),
          fee: "~${formatFixed(estimatedFee, 9)}",
          feeSymbol: _blockchain.nativeSymbol,
        ),
      );

      if (confirmed == true) {
        final txId = await savingsGateway.withdraw((
          amount: interestToCollect,
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

  Future<void> _onCompoundInterest(CompoundInterest event, Emitter<SavingsState> emit) async {
    if (state.isCollectingInterest) return;
    if (!(await _checkRequiredEth())) return;

    try {
      emit(state.copyWith(isCollectingInterest: true));

      final estimatedFee = await _client.estimateGas(
        sender: _appStore.wallet.primaryAccount.primaryAddress.address,
        to: _savings.self.address,
        data: _savings.self.abi.functions[16].encodeCall([]),
      );

      final confirmed = await showModalBottomSheet<bool>(
        context: navigatorKey.currentContext!,
        builder: (context) => ConfirmBottomSheet(
          onConfirm: () => context.pop(true),
          title: S.current.savings_reinvest,
          message: S.current.savings_compound_interest_confirm_content(_blockchain.name),
          fee: "~${formatFixed(estimatedFee, 9)}",
          feeSymbol: _blockchain.nativeSymbol,
        ),
      );

      if (confirmed == true) {
        final txId = await _savings.refreshMyBalance(
            credentials: _appStore.wallet.primaryAccount.primaryAddress);
        developer.log('Compound Interest in TX($txId)', name: 'SavingsBloc');
        add(LoadSavingsBalance());
      }
      emit(state.copyWith(isCollectingInterest: false));
    } catch (e) {
      developer.log('Error during compounding interest',
          error: e, name: 'SavingsBloc._onCompoundInterest');
      emit(state.copyWith(isCollectingInterest: false));
    }
  }

  Future<void> _onLoadSavingsBalance(LoadSavingsBalance event, Emitter<SavingsState> emit) async {
    final interestRate = await _savings.currentRatePPM();
    final amount =
        await _savings.savings(($param17: EthereumAddress.fromHex(_appStore.primaryAddress)));
    final intrest = await _savings
        .accruedInterest((accountOwner: EthereumAddress.fromHex(_appStore.primaryAddress)));

    final amountV1 = await getSavingsGatewayV1(_client)
        .savings(($param19: EthereumAddress.fromHex(_appStore.primaryAddress)));

    emit(state.copyWith(
      amount: amount.saved.toRadixString(16),
      interestRate: interestRate.toRadixString(16),
      accruedInterest: intrest.toRadixString(16),
      isCached: false,
      amountV1: amountV1.saved > BigInt.zero ? amountV1.saved.toRadixString(16) : null,
      removeV1: amountV1.saved == BigInt.zero,
    ));

    await _cacheRepository.write(cacheKeySavingsInterestRate, interestRate.toRadixString(16));
    await _cacheRepository.write(cacheKeySavingsBalance, amount.saved.toRadixString(16));
    await _cacheRepository.write(cacheKeySavingsAccruedInterest, intrest.toRadixString(16));
  }

  Future<void> _onLoadFromCache(LoadFromCache event, Emitter<SavingsState> emit) async {
    final interestRate = await _cacheRepository.read(cacheKeySavingsInterestRate);
    final amount = await _cacheRepository.read(cacheKeySavingsBalance);

    final intrest = await _cacheRepository.read(cacheKeySavingsAccruedInterest);
    emit(state.copyWith(
      amount: amount,
      interestRate: interestRate,
      accruedInterest: intrest,
      isCached: true,
    ));
  }

  Future<bool> _checkRequiredEth() async {
    final ethBalance =
        await _client.getBalance(_appStore.wallet.primaryAccount.primaryAddress.address);
    if (ethBalance.getInWei < BigInt.from(3000)) {
      final blockchain = Blockchain.ethereum;
      showModalBottomSheet(
          context: navigatorKey.currentContext!,
          builder: (_) => ErrorBottomSheet(
              message: S.current.error_not_enough_money(blockchain.nativeSymbol, blockchain.name)));
      return false;
    }
    return true;
  }

  Future<void> _onWithdrawSubmitted(WithdrawV1Submitted event, Emitter<SavingsState> emit) async {
    final currentAccount = _appStore.wallet.primaryAccount.primaryAddress;
    final blockchain = Blockchain.ethereum;

    final gasPrice = await _client.getGasPrice();
    final estimatedGas = await _client.estimateGas();
    final fee = gasPrice.getInWei * estimatedGas;

    final ethBalance = await _client.getBalance(currentAccount.address);
    if (ethBalance.getInWei < fee) {
      return showModalBottomSheet(
          context: navigatorKey.currentContext!,
          builder: (_) => ErrorBottomSheet(
              message: S.current.error_not_enough_money(blockchain.nativeSymbol, blockchain.name)));
    }

    try {
      final savings = getSavingsGatewayV1(_client);
      final amount = BigInt.parse('100000000000000000000000000');
      final priority = TransactionPriority.slow;

      final transaction = Transaction(
        from: currentAccount.address,
        to: savings.self.address,
        maxPriorityFeePerGas:
            blockchain.chainId == 1 ? EtherAmount.fromInt(EtherUnit.gwei, priority.tip) : null,
        value: EtherAmount.zero(),
      );

      final txId = await (savings.withdraw$2(
        (
          amount: amount,
          frontendCode: frontendCode,
          target: currentAccount.address,
        ),
        transaction: transaction,
        credentials: currentAccount,
      ));

      developer.log(txId, name: 'SavingsEditBloc');
    } catch (e) {
      developer.log('Error during send!', error: e, name: 'SavingsEditBloc');
    }
  }
}
