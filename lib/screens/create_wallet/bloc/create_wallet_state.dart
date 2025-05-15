part of 'create_wallet_cubit.dart';

final class CreateWalletState {
  const CreateWalletState({this.hideSeed = true, this.wallet});

  final bool hideSeed;
  final Wallet? wallet;

  CreateWalletState copyWith({
    bool? hideSeed,
    Wallet? wallet,
  }) =>
      CreateWalletState(
        hideSeed: hideSeed ?? this.hideSeed,
        wallet: wallet ?? this.wallet,
      );
}
