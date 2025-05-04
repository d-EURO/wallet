import 'package:deuro_wallet/styles/colors.dart';
import 'package:deuro_wallet/styles/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.textStyle = kActionButtonTextStyle,
    this.buttonStyle,
  });

  final IconData? icon;
  final bool isLoading;
  final String label;
  final VoidCallback? onPressed;
  final TextStyle? textStyle;
  final ButtonStyle? buttonStyle;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 30,
        child: FilledButton.icon(
          style: buttonStyle ?? kFullwidthActionButtonStyle,
          onPressed: isLoading ? null : onPressed,
          icon: icon != null ? Icon(icon) : null,
          label: isLoading
              ? CupertinoActivityIndicator(color: DEuroColors.dEuroGold)
              : Text(label, textAlign: TextAlign.center, style: textStyle),
        ),
      );
}
