import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/models/transaction.dart';
import 'package:deuro_wallet/packages/service/transaction_history_service.dart';
import 'package:deuro_wallet/packages/utils/asset_logo.dart';
import 'package:deuro_wallet/styles/colors.dart';
import 'package:deuro_wallet/widgets/chain_asset_icon.dart';
import 'package:deuro_wallet/widgets/hide_amount_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionRow extends StatelessWidget {
  final Transaction transaction;
  final String walletAddress;
  final Color backgroundColor;
  final Color firstRowTextColor;
  final Color secondRowTextColor;
  final bool showBlockchainIcon;
  final bool navigateToDetails;

  const TransactionRow({
    super.key,
    required this.transaction,
    required this.walletAddress,
    this.backgroundColor = Colors.white,
    this.firstRowTextColor = DEuroColors.anthracite,
    this.secondRowTextColor = DEuroColors.titanGray60,
    this.showBlockchainIcon = false,
    this.navigateToDetails = true,
  });

  String get leadingImagePath => getAssetImagePath(transaction.asset);

  bool get isOutbound => transaction.isOutbound(walletAddress);

  TextStyle get _firstRowTextStyle => TextStyle(
      fontSize: 14, fontWeight: FontWeight.w700, color: firstRowTextColor);

  TextStyle get _secondRowTextStyle =>
      TextStyle(fontSize: 12, color: secondRowTextColor);

  @override
  Widget build(BuildContext context) => InkWell(
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: backgroundColor,
          ),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ChainAssetIcon(asset: transaction.asset),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(
                              transaction.asset.name,
                              style: _firstRowTextStyle,
                            ),
                            Spacer(),
                            HideAmountText(
                              leadingSymbol: isOutbound ? "-" : "",
                              amount: transaction.amount,
                              decimals: transaction.asset.decimals,
                              fractionalDigits: 2,
                              trimZeros: false,
                              trailingSymbol: transaction.asset.symbol,
                              style: _firstRowTextStyle,
                            )
                          ]),
                          Row(children: [
                            Text(
                              "${isOutbound ? S.of(context).to : S.of(context).from} ${isOutbound ? transaction.receiverAddress.asShortAddress : transaction.senderAddress.asShortAddress}",
                              style: _secondRowTextStyle,
                            ),
                            Spacer(),
                            Text(
                              DateFormat('MMM dd, yyyy')
                                  .format(transaction.timestamp),
                              style: _secondRowTextStyle,
                            )
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
