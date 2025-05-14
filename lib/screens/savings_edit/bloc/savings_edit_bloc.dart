import 'dart:async';
import 'dart:developer' as dev;

import 'package:deuro_wallet/constants.dart';
import 'package:deuro_wallet/models/asset.dart';
import 'package:deuro_wallet/models/blockchain.dart';
import 'package:deuro_wallet/packages/contracts/contracts.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/packages/utils/default_assets.dart';
import 'package:deuro_wallet/packages/utils/format_fixed.dart';
import 'package:deuro_wallet/packages/utils/parse_fixed.dart';
import 'package:equatable/equatable.dart';
import 'package:erc20/erc20.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web3dart/crypto.dart';
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
      amount: state.amount == "0"
          ? event.amount.toString()
          : "${state.amount}${event.amount}",
    ));
  }

  void _onAmountDecimal(
      AmountChangedDecimal event, Emitter<SavingsEditState> emit) {
    emit(state.copyWith(amount: "${state.amount.replaceAll(".", "")}."));
  }

  void _onAmountRemove(
      AmountChangedDelete event, Emitter<SavingsEditState> emit) {
    emit(state.copyWith(
      amount: state.amount.length > 1
          ? state.amount.substring(0, state.amount.length - 1)
          : "0",
    ));
  }

  void _onFeeChanged(FeeChanged event, Emitter<SavingsEditState> emit) {
    emit(state.copyWith(fee: event.fee));
  }

  Future<void> _onLoadIsEnabled(LoadIsEnabled event, Emitter<SavingsEditState> emit) async {
    try {
      final dEuro = ERC20(
          address: EthereumAddress.fromHex(dEUROAsset.address), client: client);

      final allowance = await dEuro.allowance(_appStore.wallet.primaryAccount.primaryAddress.address,
          EthereumAddress.fromHex(savingsGatewayAddress));
      emit(state.copyWith(isEnabled: allowance > BigInt.zero));
    } catch (e) {
      dev.log("Error during loading enabled", error: e);
    }
  }

  Future<void> _onSubmitted(
      SendSubmitted event, Emitter<SavingsEditState> emit) async {
    emit(state.copyWith(status: SendStatus.inProgress));
    try {
      final savings = getSavingsGateway(client);
      final amount = parseFixed(state.amount, _asset.decimals);

      // final frontendGateway = getFrontendGateway(client);
      // final frontendCode = Uint8List.fromList(sha256.convert(utf8.encode("wallet")).bytes);
      // dev.log(bytesToHex(frontendCode));
      // final txId = await frontendGateway.registerFrontendCode((frontendCode: frontendCode), credentials: _appStore.wallet.primaryAccount.primaryAddress);

      final txId = await (isAdding
          ? savings.save((
              amount: amount,
              frontendCode: frontendCode,
            ), credentials: _appStore.wallet.primaryAccount.primaryAddress)
          : savings.withdraw$2((
              amount: amount,
              frontendCode: frontendCode,
              target: _appStore.wallet.primaryAccount.primaryAddress.address,
            ), credentials: _appStore.wallet.primaryAccount.primaryAddress));

      dev.log(txId);
      emit(state.copyWith(status: SendStatus.success));
    } catch (e) {
      dev.log("Error during send!", error: e);
      emit(state.copyWith(status: SendStatus.failure));
    }
  }

  void _startFeeSync() {
    final priorityFee = 0;
    _feeTimer?.cancel();
    _feeTimer = Timer.periodic(Duration(seconds: 1), (_) async {
      try {
        final gasPrice = await client.getGasPrice();
        final estimatedGas = await client.estimateGas(
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
