part of 'home_bloc.dart';

final class HomeState {
  const HomeState({this.openWallet, this.isLoadingWallet = false});

  final Wallet? openWallet;
  final bool isLoadingWallet;

  HomeState copyWith({
    Wallet? openWallet,
    bool? isLoadingWallet,
  }) {
    return HomeState(
      openWallet: openWallet ?? this.openWallet,
      isLoadingWallet: isLoadingWallet ?? this.isLoadingWallet,
    );
  }
}
