import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/styles/colors.dart';
import 'package:deuro_wallet/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TransactionSentPage extends StatelessWidget {
  final String transactionId;

  const TransactionSentPage({super.key, required this.transactionId});

  static const _kPadding = EdgeInsets.only(left: 26, right: 26, bottom: 10);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: DEuroColors.dEuroBlue,
                    radius: 32,
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 46,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      S.of(context).transaction_sent,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              )),
              Padding(
                padding: _kPadding,
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => context.pop(),
                    style: kFullwidthGrayButtonStyle,
                    child: Text(
                      S.of(context).done,
                      textAlign: TextAlign.center,
                      style: kTitleTextStyle,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
}
