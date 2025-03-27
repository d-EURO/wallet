import 'package:flutter/material.dart';

class AmountInfoRow extends StatelessWidget {
  const AmountInfoRow({
    super.key,
    required this.title,
    required this.amountString,
    required this.currencySymbol,
    this.padding,
  });

  final String amountString;
  final String title;
  final String currencySymbol;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$title:",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: 'Lato',
                color: Colors.white,
              ),
            ),
          ),
          Text(
            amountString,
            style: const TextStyle(
              fontSize: 15,
              fontFamily: 'Lato',
              color: Colors.white,
            ),
          ),
          Text(
            " $currencySymbol",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontFamily: 'Lato',
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
