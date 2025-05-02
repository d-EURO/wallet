import 'package:deuro_wallet/models/transaction.dart';
import 'package:deuro_wallet/packages/utils/asset_logo.dart';
import 'package:deuro_wallet/packages/utils/format_fixed.dart';
import 'package:deuro_wallet/widgets/chain_asset_icon.dart';
import 'package:deuro_wallet/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class TransactionRow extends StatelessWidget {
  final Transaction transaction;
  final Color backgroundColor;
  final bool showBlockchainIcon;
  final bool navigateToDetails;

  const TransactionRow({
    super.key,
    required this.transaction,
    this.backgroundColor = Colors.white,
    this.showBlockchainIcon = false,
    this.navigateToDetails = true,
  });

  String get leadingImagePath => getAssetImagePath(transaction.asset);

  @override
  Widget build(BuildContext context) => InkWell(
    child: Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: backgroundColor,
      ),
      // padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ChainAssetIcon(asset: transaction.asset,),//Image.asset(leadingImagePath, width: 40),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.asset.name,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            transaction.type.name,
                          )
                        ],
                      ))),
              Text(
                formatFixed(transaction.amount, transaction.asset.decimals,
                    fractionalDigits: 4, trimZeros: false),
                style: const TextStyle(fontSize: 16),
              )
            ],
          ),
        ],
      ),
    ),
  );
}
