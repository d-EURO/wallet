import 'package:deuro_wallet/packages/service/wallet_service.dart';
import 'package:deuro_wallet/packages/wallet/wallet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'create_wallet_state.dart';

class CreateWalletCubit extends Cubit<CreateWalletState> {
  CreateWalletCubit(this._service) : super(CreateWalletState());

  final WalletService _service;

  void createWallet() async {
    final wallet = await _service.createWallet("Obi-Wallet-Kenobi");

    emit(state.copyWith(wallet: wallet));
  }

  void toggleShowSeed() {
    emit(state.copyWith(hideSeed: !state.hideSeed));
  }
}
