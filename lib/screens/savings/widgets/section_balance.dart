import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/packages/utils/default_assets.dart';
import 'package:deuro_wallet/styles/colors.dart';
import 'package:deuro_wallet/styles/styles.dart';
import 'package:deuro_wallet/widgets/action_button.dart';
import 'package:deuro_wallet/widgets/chain_asset_icon.dart';
import 'package:deuro_wallet/widgets/hide_amount_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SectionBalance extends StatelessWidget {
  final BigInt balance;
  final BigInt collectedInterest;

  const SectionBalance({
    super.key,
    required this.balance,
    required this.collectedInterest,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: DEuroColors.dEuroBlue,
        child: SafeArea(
          child: Column(
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
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                    Spacer(),
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: Colors.white.withAlpha(50),
                      child: IconButton(
                        color: Colors.white,
                        onPressed: () => context.push('/settings'),
                        iconSize: 18,
                        icon: const Icon(Icons.settings),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 12, bottom: 12),
                child: Column(
                  children: [
                    Text(
                      "Savings ${S.of(context).balance}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withAlpha(153),
                      ),
                    ),
                    HideAmountText(
                      amount: balance,
                      style: const TextStyle(
                        fontSize: 35,
                        color: Colors.white,
                        fontFamily: "Satoshi Bold",
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ActionButton(
                    icon: Icons.add,
                    label: "Add",
                    onPressed: () {},
                    buttonStyle: kBalanceBarActionButtonStyle,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: ActionButton(
                      icon: Icons.remove,
                      label: "Remove",
                      onPressed: () {},
                      buttonStyle: kBalanceBarActionButtonStyle,
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: 16, right: 16, bottom: 20, top: 36),
                padding: const EdgeInsets.only(
                    left: 16, right: 16, bottom: 20, top: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 54, 65, 198),
                ),
                width: double.infinity,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Interest to be collected",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withAlpha(153),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ChainAssetIcon(asset: dEUROAsset),
                            ),
                            HideAmountText(
                              amount: collectedInterest,
                              leadingSymbol: "",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontFamily: "Satoshi Bold",
                              ),
                            ),
                            Spacer(),
                            ActionButton(
                              icon: Icons.circle_outlined,
                              label: "Collect",
                              onPressed: () {},
                              buttonStyle: kBalanceBarActionButtonStyle,
                            ),
                          ],
                        ),
                      ),
                    ]),
              )
            ],
          ),
        ),
      );
}
