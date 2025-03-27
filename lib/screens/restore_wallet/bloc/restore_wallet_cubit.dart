import 'package:bip39/src/wordlists/english.dart' as wordlist;
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/packages/service/balance_service.dart';
import 'package:deuro_wallet/packages/service/wallet_service.dart';
import 'package:deuro_wallet/packages/wallet/wallet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RestoreWalletState {
  final bool isSeedReady;
  final bool isLoading;
  final bool isRestored;
  final Wallet? wallet;

  RestoreWalletState(this.isSeedReady, this.isLoading, this.isRestored,
      [this.wallet]);
}

class RestoreWalletCubit extends Cubit<RestoreWalletState> {
  RestoreWalletCubit(this._appStore, this._walletService, this._balanceService)
      : super(RestoreWalletState(false, false, false));

  final AppStore _appStore;
  final WalletService _walletService;
  final BalanceService _balanceService;

  void restoreWallet(String seed) async {
    emit(RestoreWalletState(state.isSeedReady, true, false));

    final normalizedSeed =
        seed.split(" ").where((element) => element.isNotEmpty).join(" ");

    final wallet =
        await _walletService.restoreWallet("Obi-Wallet-Kenobi", normalizedSeed);

    emit(RestoreWalletState(true, false, true, wallet));
  }

  void validateSeed(String seed) {
    final seedWords = seed.split(" ").where((element) => element.isNotEmpty);

    if (seedWords.length == 12 && _containsAll(wordlist.WORDLIST, seedWords)) {
      emit(RestoreWalletState(true, state.isLoading, false));
    } else {
      emit(RestoreWalletState(false, state.isLoading, false));
    }
  }

  bool _containsAll(Iterable a, Iterable b) {
    for (final element in b) {
      if (!a.contains(element)) return false;
    }
    return true;
  }
}
