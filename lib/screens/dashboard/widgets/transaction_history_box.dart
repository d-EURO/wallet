import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/models/transaction.dart';
import 'package:deuro_wallet/screens/dashboard/widgets/transaction_row.dart';
import 'package:deuro_wallet/styles/colors.dart';
import 'package:flutter/material.dart';

class TransactionHistoryBox extends StatelessWidget {
  const TransactionHistoryBox({
    super.key,
    required this.transactions,
    required this.walletAddress,
    required this.hasShowAll,
  });

  final List<Transaction> transactions;
  final bool hasShowAll;
  final String walletAddress;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Text(
                    S.of(context).transactions,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            ...transactions.map((e) => TransactionRow(
                  transaction: e,
                  walletAddress: walletAddress,
                )),
            if (hasShowAll) ...[
              TextButton(
                onPressed: () {},
                child: Text(
                  S.of(context).show_all,
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: "Satoshi Bold",
                    color: DEuroColors.dEuroGold,
                  ),
                ),
              )
            ]
          ],
        ),
      );
}
