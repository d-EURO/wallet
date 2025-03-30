import 'package:deuro_wallet/packages/service/wallet_service.dart';
import 'package:deuro_wallet/packages/wallet/wallet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateWalletCubit extends Cubit<Wallet?> {
  CreateWalletCubit(this._service) : super(null);

  final WalletService _service;

  void createWallet() async {
    final wallet = await _service.createWallet("Obi-Wallet-Kenobi");

    emit(wallet);
  }
}
