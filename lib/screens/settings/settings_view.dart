import 'package:deuro_wallet/screens/home/bloc/home_bloc.dart';
import 'package:deuro_wallet/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => context.read<HomeBloc>().add(DeleteCurrentWalletEvent()),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(double.infinity, 55),
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                  ),
                  child: Text(
                    "Delete Wallet",
                    style: kPrimaryButtonTextStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
