import 'package:deuro_wallet/models/asset.dart';
import 'package:deuro_wallet/packages/utils/asset_logo.dart';
import 'package:flutter/material.dart';

class ChainAssetIcon extends StatelessWidget {
  final Asset asset;
  final bool hideChainIcon;

  const ChainAssetIcon({
    super.key,
    required this.asset,
    this.hideChainIcon = false,
  });

  @override
  Widget build(BuildContext context) => hideChainIcon
      ? Image.asset(
          getAssetImagePath(asset),
          width: 32,
          height: 32,
        )
      : SizedBox(
          width: 32,
          height: 32,
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              Image.asset(getAssetImagePath(asset)),
              Positioned(
                bottom: 0,
                right: 0,
                width: 13,
                child: Image.asset(getChainImagePath(asset.chainId)),
              ),
            ],
          ),
        );
}
