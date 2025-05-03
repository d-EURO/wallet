import 'package:deuro_wallet/models/asset.dart';
import 'package:deuro_wallet/packages/utils/format_fixed.dart';
import 'package:deuro_wallet/widgets/chain_asset_icon.dart';
import 'package:flutter/material.dart';

class CashHoldingBox extends StatelessWidget {
  final Asset asset;
  final BigInt balance;
  final Color backgroundColor;
  final bool showBlockchainIcon;
  final bool navigateToDetails;

  const CashHoldingBox({
    super.key,
    required this.asset,
    required this.balance,
    this.backgroundColor = Colors.white,
    this.showBlockchainIcon = false,
    this.navigateToDetails = true,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        child: Container(
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: backgroundColor,
          ),
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ChainAssetIcon(asset: asset),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            asset.symbol,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(asset.name)
                        ],
                      ),
                    ),
                  ),
                  Text(
                    formatFixed(balance, asset.decimals,
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
