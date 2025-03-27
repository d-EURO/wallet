import 'package:deuro_wallet/di.dart';
import 'package:deuro_wallet/models/balance.dart';
import 'package:deuro_wallet/models/blockchain.dart';
import 'package:deuro_wallet/packages/repository/balance_repository.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/packages/utils/default_assets.dart';
import 'package:deuro_wallet/screens/dashboard/bloc/aggregated_balance_cubit.dart';
import 'package:deuro_wallet/screens/dashboard/bloc/blance_cubit.dart';
import 'package:deuro_wallet/screens/dashboard/widgets/balance_section.dart';
import 'package:deuro_wallet/widgets/action_bar.dart';
import 'package:deuro_wallet/widgets/balance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage(this._appStore, {super.key}) {
    aggregatedDEuro = AggregatedBalanceCubit(getIt<BalanceRepository>(), [
      dEUROAsset.getEmptyBalance(walletAddress),
    ]);

    aggregatedDEPS = AggregatedBalanceCubit(getIt<BalanceRepository>(), [
      nDEPSAsset.getEmptyBalance(walletAddress),
      depsAsset.getEmptyBalance(walletAddress),
    ]);

    aggregatedEth = AggregatedBalanceCubit(getIt<BalanceRepository>(), [
      Blockchain.ethereum.nativeAsset.getEmptyBalance(walletAddress),
      Blockchain.base.nativeAsset.getEmptyBalance(walletAddress),
      Blockchain.optimism.nativeAsset.getEmptyBalance(walletAddress),
      Blockchain.arbitrum.nativeAsset.getEmptyBalance(walletAddress),
    ]);

    polBalanceCubit = BalanceCubit(
      getIt<BalanceRepository>(),
      asset: Blockchain.polygon.nativeAsset,
      walletAddress: walletAddress,
    );
  }

  final AppStore _appStore;

  String get walletAddress => _appStore.primaryAddress;

  late final AggregatedBalanceCubit aggregatedDEuro;
  late final AggregatedBalanceCubit aggregatedDEPS;
  late final AggregatedBalanceCubit aggregatedEth;
  late final BalanceCubit polBalanceCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: aggregatedDEuro),
        BlocProvider.value(value: polBalanceCubit),
        BlocProvider.value(value: aggregatedEth),
      ],
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: PopScope(
            canPop: false,
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  BlocBuilder<AggregatedBalanceCubit, AggregatedBalance>(
                    bloc: aggregatedDEuro,
                    builder: (context, state) => BalanceSection(
                      balance: state.balance,
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: [
                        CustomScrollView(
                          slivers: [
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Column(
                                children: <Widget>[
                                  BlocBuilder<AggregatedBalanceCubit,
                                      AggregatedBalance>(
                                    bloc: aggregatedDEPS,
                                    builder: (context, state) => Offstage(
                                      offstage: state.balance != BigInt.zero,
                                      child: BalanceCard(
                                        asset: depsAsset,
                                        balance: state.balance,
                                        action: () {},
                                        actionLabel: "Show more",
                                      ),
                                    ),
                                  ),
                                  BlocBuilder<AggregatedBalanceCubit,
                                      AggregatedBalance>(
                                    bloc: aggregatedEth,
                                    builder: (context, state) => BalanceCard(
                                      asset: Blockchain.ethereum.nativeAsset,
                                      balance: state.balance,
                                    ),
                                  ),
                                  BlocBuilder<BalanceCubit, Balance>(
                                    bloc: polBalanceCubit,
                                    builder: (context, state) => BalanceCard(
                                      asset: polBalanceCubit.asset,
                                      balance: state.balance,
                                    ),
                                  ),
                                  // Offstage(
                                  //   offstage:
                                  //   !(settingsStore.enableAdvancedMode ||
                                  //       widget.balanceVM
                                  //           .fpsBalanceAggregated >
                                  //           BigInt.zero),
                                  //   child: BalanceCard(
                                  //     balance: widget
                                  //         .balanceVM.fpsBalanceAggregated,
                                  //     cryptoCurrency: CryptoCurrency.fps,
                                  //   ),
                                  // ),
                                  // Offstage(
                                  //   offstage:
                                  //   !settingsStore.enableAdvancedMode,
                                  //   child: FullwidthButton(
                                  //     label: S.of(context).more_assets,
                                  //     onPressed: () => Navigator.of(context)
                                  //         .pushNamed(Routes.moreAssets),
                                  //   ),
                                  // ),
                                  const SizedBox(height: 110)
                                ],
                              ),
                            ),
                          ],
                        ),
                        ActionBar()
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
