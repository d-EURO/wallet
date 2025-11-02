import 'package:deuro_wallet/di.dart';
import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/models/balance.dart';
import 'package:deuro_wallet/models/price_point.dart';
import 'package:deuro_wallet/packages/ponder/ponder.dart';
import 'package:deuro_wallet/packages/repository/balance_repository.dart';
import 'package:deuro_wallet/packages/repository/price_repository.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/packages/service/equity_service.dart';
import 'package:deuro_wallet/packages/utils/default_assets.dart';
import 'package:deuro_wallet/screens/dashboard/bloc/blance_cubit.dart';
import 'package:deuro_wallet/screens/invest/bloc/aggregated_priced_balance_cubit.dart';
import 'package:deuro_wallet/screens/invest/bloc/price_cubit.dart';
import 'package:deuro_wallet/screens/invest/widgets/price_chart.dart';
import 'package:deuro_wallet/styles/colors.dart';
import 'package:deuro_wallet/styles/styles.dart';
import 'package:deuro_wallet/widgets/chain_asset_icon.dart';
import 'package:deuro_wallet/widgets/hide_amount_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class InvestView extends StatelessWidget {
  InvestView(this._appStore, {super.key}) {
    aggregatedDEPS = AggregatedPricedBalanceCubit(
      getIt<BalanceRepository>(),
      getIt<EquityService>(),
      [
        nDEPSAsset.getEmptyBalance(walletAddress),
        depsAsset.getEmptyBalance(walletAddress),
      ],
    );

    for (final asset in [nDEPSAsset, depsAsset]) {
      cryptoHoldings.add(BalanceCubit(
        getIt<BalanceRepository>(),
        asset: asset,
        walletAddress: walletAddress,
      ));
    }
  }

  late final AggregatedPricedBalanceCubit aggregatedDEPS;
  final List<BalanceCubit> cryptoHoldings = [];
  final AppStore _appStore;

  String get walletAddress => _appStore.primaryAddress;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          width: double.infinity,
          color: DEuroColors.dEuroBlue,
          child: SafeArea(
              child: BlocBuilder<AggregatedPricedBalanceCubit,
                  AggregatedPricedBalance>(
            bloc: aggregatedDEPS,
            builder: (context, aggregatedBalance) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 17,
                        backgroundColor: Colors.white.withAlpha(50),
                        child: IconButton(
                          color: Colors.white,
                          onPressed: () => context.pop(),
                          iconSize: 18,
                          icon: const Icon(Icons.arrow_back_ios_new),
                        ),
                      ),
                      Spacer(),
                      CircleAvatar(
                        radius: 17,
                        backgroundColor: Colors.white.withAlpha(50),
                        child: IconButton(
                          color: Colors.white,
                          // onPressed: () => context.push('/settings'),
                          onPressed: () async {
                            final prices = await Ponder().getTradeChart();
                            for (final price in prices) {
                              if (await getIt<PriceRepository>()
                                  .exitsPrice(price)) {
                                continue;
                              }
                              getIt<PriceRepository>().insertPrice(price);
                            }
                          },
                          iconSize: 18,
                          icon: const Icon(Icons.settings),
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    BlocBuilder<PriceCubit, List<PricePoint>>(
                      builder: (context, state) => SizedBox(
                        height: 220,
                        child: PriceChart(
                          prices: state,
                        ),
                      ),
                    ),
                    Center(
                        child: Column(
                      children: [
                        Text(
                          "nDEPS Price",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withAlpha(153),
                          ),
                        ),
                        HideAmountText(
                          amount: aggregatedBalance.price,
                          style: const TextStyle(
                            fontSize: 35,
                            color: Colors.white,
                            fontFamily: "Satoshi Bold",
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).invest_your_total_invest,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withAlpha(153),
                        ),
                      ),
                      HideAmountText(
                        amount: aggregatedBalance.value,
                        style: const TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontFamily: "Satoshi Bold",
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        S.of(context).invest_positions,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withAlpha(153),
                        ),
                      ),
                      ...cryptoHoldings.map(
                        (holding) => BlocBuilder<BalanceCubit, Balance>(
                          bloc: holding,
                          builder: (context, state) => Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: ChainAssetIcon(
                                    asset: state.asset,
                                    hideChainIcon: true,
                                  ),
                                ),
                                HideAmountText(
                                  amount: state.balance,
                                  leadingSymbol: "",
                                  trailingSymbol: state.asset.symbol,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontFamily: "Satoshi Bold",
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: TextButton(
                            onPressed: () => context.go('/invest/buy'),
                            style: kFullwidthPrimaryButtonStyle,
                            child: Text(
                              S.of(context).invest_buy,
                              style: kPrimaryButtonTextStyle,
                            ),
                          ),
                        ),
                      ),
                      if (aggregatedBalance.balance > BigInt.zero)
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: TextButton(
                              onPressed: () => context.go('/invest/sell'),
                              style: kFullwidthPrimaryButtonInvertedStyle,
                              child: Text(
                                S.of(context).invest_sell,
                                textAlign: TextAlign.center,
                                style: kPrimaryButtonTextStyle,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
          )),
        ),
      );
}
