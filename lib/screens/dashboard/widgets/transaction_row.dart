import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/models/transaction.dart';
import 'package:deuro_wallet/packages/service/transaction_history_service.dart';
import 'package:deuro_wallet/packages/utils/asset_logo.dart';
import 'package:deuro_wallet/packages/utils/format_fixed.dart';
import 'package:deuro_wallet/widgets/chain_asset_icon.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionRow extends StatelessWidget {
  final Transaction transaction;
  final String walletAddress;
  final Color backgroundColor;
  final bool showBlockchainIcon;
  final bool navigateToDetails;

  const TransactionRow({
    super.key,
    required this.transaction,
    required this.walletAddress,
    this.backgroundColor = Colors.white,
    this.showBlockchainIcon = false,
    this.navigateToDetails = true,
  });

  String get leadingImagePath => getAssetImagePath(transaction.asset);

  bool get isOutbound => transaction.isOutbound(walletAddress);

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
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            Spacer(),
                            Text(
                              "${isOutbound ? "-" : ""}${formatFixed(transaction.amount, transaction.asset.decimals, fractionalDigits: 2, trimZeros: false)} ${transaction.asset.symbol}",
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            )
                          ]),
                          Row(children: [
                            Text(
                              "${isOutbound ? S.of(context).to : S.of(context).from} ${isOutbound ? transaction.receiverAddress.asShortAddress : transaction.senderAddress.asShortAddress}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            Spacer(),
                            Text(
                              DateFormat('MMM dd, yyyy')
                                  .format(transaction.timestamp),
                              style: const TextStyle(fontSize: 14),
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
