import 'package:deuro_wallet/packages/utils/format_fixed.dart';
import 'package:deuro_wallet/screens/settings/bloc/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HideAmountText extends StatelessWidget {
  const HideAmountText({
    super.key,
    this.style,
    required this.amount,
    this.decimals = 18,
    this.fractionalDigits = 2,
    this.trimZeros = false,
    this.leadingSymbol = "€",
    this.trailingSymbol = "",
    this.textAlign,
  });

  final String leadingSymbol;
  final String trailingSymbol;
  final TextStyle? style;
  final BigInt amount;
  final int decimals;
  final int fractionalDigits;
  final bool trimZeros;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) => Text(
          state.hideAmounts
              ? "${leadingSymbol.isNotEmpty ? "$leadingSymbol " : ""}***.**"
              : "${leadingSymbol.isNotEmpty ? "$leadingSymbol " : ""}${formatFixed(amount, decimals, fractionalDigits: fractionalDigits, trimZeros: trimZeros)} $trailingSymbol",
          style: style,
          textAlign: textAlign,
        ),
      );
}
