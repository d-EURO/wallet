import 'package:deuro_wallet/models/asset.dart';
import 'package:deuro_wallet/styles/styles.dart';
import 'package:deuro_wallet/widgets/chain_asset_icon.dart';
import 'package:flutter/material.dart';

class CryptoAssetButton extends StatelessWidget {
  final Asset asset;

  const CryptoAssetButton({super.key, required this.asset});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () {},
        child: Container(
          margin: EdgeInsets.all(12),
          width: 165,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: ChainAssetIcon(asset: asset),
              ),
              Text(
                asset.name,
                style: kPageTitleTextStyle,
              ),
            ],
          ),
        ),
      );
}
