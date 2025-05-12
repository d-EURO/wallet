import 'package:deuro_wallet/styles/colors.dart';
import 'package:flutter/material.dart';

const kPrimaryButtonTextStyle = TextStyle(fontSize: 16, color: Colors.white);

const kActionButtonTextStyle = TextStyle(fontSize: 12, color: Colors.white);

final kFullwidthPrimaryButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.white.withAlpha(50),
  fixedSize: Size(double.infinity, 55),
  elevation: 0.0,
);

final kBalanceBarActionButtonStyle = FilledButton.styleFrom(
  backgroundColor: Colors.white.withAlpha(50),
  textStyle: kPrimaryButtonTextStyle,
  padding: EdgeInsets.only(top:5, bottom: 5, left: 10, right: 10),
);

final kFullwidthActionButtonStyle = FilledButton.styleFrom(
  backgroundColor: DEuroColors.neutralGrey.withAlpha(50),
  padding: EdgeInsets.only(top:5, bottom: 5, left: 10, right: 10),
  iconColor: DEuroColors.neutralGrey
);
