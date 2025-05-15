import 'dart:ui';

import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/styles/colors.dart';
import 'package:flutter/material.dart';

class SeedBlurCard extends StatelessWidget {
  final VoidCallback onTap;
  final bool blur;
  final String text;

  const SeedBlurCard(
      {super.key, required this.onTap, required this.blur, required this.text});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 12,
                    bottom: 12,
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      wordSpacing: 8,
                    ),
                  ),
                ),
                if (blur)
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.visibility,
                            size: 16,
                            color: DEuroColors.anthracite,
                          ),
                          Text(
                            S.of(context).tap_here_to_view,
                            style: TextStyle(
                              fontSize: 14,
                              color: DEuroColors.neutralGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}
