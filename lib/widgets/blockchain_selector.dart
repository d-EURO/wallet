import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/models/blockchain.dart';
import 'package:deuro_wallet/packages/utils/asset_logo.dart';
import 'package:flutter/material.dart';

class BlockchainSelector extends StatelessWidget {
  const BlockchainSelector({
    super.key,
    this.blockchain = Blockchain.ethereum,
    this.onPressed,
    this.padding,
  });

  final Blockchain blockchain;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding ?? const EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "${S.of(context).blockchain}:",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            InkWell(
              onTap: onPressed,
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              enableFeedback: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 7, bottom: 7, left: 7),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundImage:
                            AssetImage(getChainImagePath(blockchain.chainId)),
                      ),
                    ),
                    Text(
                      blockchain.name,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
