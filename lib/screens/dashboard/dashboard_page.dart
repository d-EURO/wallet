import 'package:deuro_wallet/di.dart';
import 'package:deuro_wallet/models/balance.dart';
import 'package:deuro_wallet/models/transaction.dart';
import 'package:deuro_wallet/packages/repository/balance_repository.dart';
import 'package:deuro_wallet/packages/repository/transaction_repository.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/packages/utils/default_assets.dart';
import 'package:deuro_wallet/screens/dashboard/bloc/aggregated_balance_cubit.dart';
import 'package:deuro_wallet/screens/dashboard/bloc/blance_cubit.dart';
import 'package:deuro_wallet/screens/dashboard/bloc/transaction_history_cubit.dart';
import 'package:deuro_wallet/screens/dashboard/widgets/cash_holding_box.dart';
import 'package:deuro_wallet/screens/dashboard/widgets/section_balance.dart';
import 'package:deuro_wallet/screens/dashboard/widgets/section_transaction_history.dart';
import 'package:deuro_wallet/screens/settings/bloc/settings_bloc.dart';
import 'package:deuro_wallet/styles/colors.dart';
import 'package:deuro_wallet/styles/styles.dart';
import 'package:deuro_wallet/widgets/action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage(this._appStore, {super.key}) {
    aggregatedDEuro = AggregatedBalanceCubit(getIt<BalanceRepository>(), [
      dEUROAsset.getEmptyBalance(walletAddress),
      dEUROBaseAsset.getEmptyBalance(walletAddress),
      dEUROOptimismAsset.getEmptyBalance(walletAddress),
      dEUROArbitrumAsset.getEmptyBalance(walletAddress),
      dEUROPolygonAsset.getEmptyBalance(walletAddress),
    ]);

    for (final asset in [
      dEUROAsset,
      dEUROBaseAsset,
      dEUROOptimismAsset,
      dEUROArbitrumAsset,
      dEUROPolygonAsset,
    ]) {
      singleCashHoldings.add(BalanceCubit(getIt<BalanceRepository>(),
          asset: asset, walletAddress: walletAddress));
    }

    transactionHistoryCubit =
        TransactionHistoryCubit(getIt<TransactionRepository>(), walletAddress);
  }

  final AppStore _appStore;

  String get walletAddress => _appStore.primaryAddress;

  late final AggregatedBalanceCubit aggregatedDEuro;
  final List<BalanceCubit> singleCashHoldings = [];
  late final TransactionHistoryCubit transactionHistoryCubit;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: aggregatedDEuro),
          BlocProvider.value(value: transactionHistoryCubit),
          ...singleCashHoldings.map((cubit) => BlocProvider.value(value: cubit))
        ],
        child: Scaffold(
          body: SafeArea(
            top: false,
            child: PopScope(
              canPop: false,
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    BlocBuilder<AggregatedBalanceCubit, AggregatedBalance>(
                      bloc: aggregatedDEuro,
                      builder: (context, state) => SectionBalance(
                        balance: state.balance,
                        onHideAmountPress: () => context
                            .read<SettingsBloc>()
                            .add(ToggleHideAmountEvent()),
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
                                    Padding(
                                      padding: EdgeInsets.all(20),
                                      child: BlocBuilder<
                                          TransactionHistoryCubit,
                                          List<Transaction>>(
                                        bloc: transactionHistoryCubit,
                                        builder: (context, state) =>
                                            SectionTransactionHistory(
                                          transactions: state,
                                          walletAddress: walletAddress,
                                          hasShowAll: state.length == 5,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "Cash Holdings",
                                                style: kSubtitleTextStyle,
                                              ),
                                              Spacer(),
                                              // ActionButton(
                                              //   icon: Icons.currency_exchange,
                                              //   label: "Swap",
                                              //   onPressed: () => context
                                              //       .push('/swap/deuro'),
                                              //   textStyle:
                                              //       kActionButtonTextStyle
                                              //           .copyWith(
                                              //     color:
                                              //         DEuroColors.neutralGrey,
                                              //   ),
                                              // ),
                                              ActionButton(
                                                icon: Icons.savings,
                                                label: "Savings",
                                                onPressed: () =>
                                                    context.push('/savings'),
                                                textStyle:
                                                    kActionButtonTextStyle
                                                        .copyWith(
                                                  color:
                                                      DEuroColors.neutralGrey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          ...singleCashHoldings.map(
                                            (holding) => BlocBuilder<
                                                BalanceCubit, Balance>(
                                              bloc: holding,
                                              builder: (context, state) =>
                                                  CashHoldingBox(
                                                asset: holding.asset,
                                                balance: state.balance,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
