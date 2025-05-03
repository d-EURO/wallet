import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/packages/utils/format_fixed.dart';
import 'package:deuro_wallet/styles/colors.dart';
import 'package:deuro_wallet/widgets/action_button.dart';
import 'package:deuro_wallet/widgets/qr_scanner.dart';
import 'package:deuro_wallet/widgets/vertical_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BalanceSection extends StatelessWidget {
  final BigInt balance;

  const BalanceSection({
    super.key,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: DEuroColors.dEuroBlue,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 10),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: ActionButton(
                        icon: Icons.credit_card,
                        label: S.of(context).deposit,
                        onPressed: () {},
                      ),
                    ),
                    ActionButton(
                      icon: Icons.account_balance,
                      label: S.of(context).withdraw,
                      onPressed: () {},
                    ),
                    Spacer(),
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: Colors.white.withAlpha(50),
                      child: IconButton(
                        color: Colors.white,
                        onPressed: () => context.push('/settings'),
                        iconSize: 18,
                        icon: Icon(Icons.settings),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 12, bottom: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          S.of(context).balance,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Lato',
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Icon(
                            Icons.remove_red_eye,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "€ ${formatFixed(balance, 18, fractionalDigits: 2, trimZeros: false)}",
                      style: const TextStyle(
                        fontSize: 35,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  VerticalIconButton(
                    onPressed: () => context.push("/receive"),
                    icon: const Icon(Icons.arrow_downward, color: Colors.white),
                    label: S.of(context).receive,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: VerticalIconButton.extended(
                      onPressed: () => presentQRScanner(context),
                      icon: const Icon(Icons.qr_code, color: Colors.white),
                      label: S.of(context).pay_scan,
                    ),
                  ),
                  VerticalIconButton(
                    onPressed: () => context.push("/send"),
                    icon: const Icon(Icons.arrow_upward, color: Colors.white),
                    label: S.of(context).send,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
}
