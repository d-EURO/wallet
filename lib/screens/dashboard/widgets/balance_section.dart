import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/packages/utils/format_fixed.dart';
import 'package:flutter/material.dart';

class BalanceSection extends StatelessWidget {
  final BigInt balance;

  const BalanceSection({
    super.key,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Text(
              S.of(context).balance,
              style: const TextStyle(
                fontSize: 22,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/coins/dEuro.png',
                  width: 35,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    formatFixed(balance, 18,
                        fractionalDigits: 2, trimZeros: false),
                    style: const TextStyle(
                      fontSize: 35,
                      fontFamily: 'Lato',
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
}
