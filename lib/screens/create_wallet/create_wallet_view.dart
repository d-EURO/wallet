import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/packages/wallet/wallet.dart';
import 'package:deuro_wallet/screens/create_wallet/bloc/create_wallet_cubit.dart';
import 'package:deuro_wallet/screens/home/bloc/home_bloc.dart';
import 'package:deuro_wallet/styles/colors.dart';
import 'package:deuro_wallet/styles/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateWalletView extends StatelessWidget {
  const CreateWalletView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: BlocBuilder<CreateWalletCubit, Wallet?>(
                builder: (context, state) {
                  if (state != null) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: Image.asset(
                            "assets/images/Flag_of_Europe.png",
                            width: 155,
                          ),
                        ),
                        Text(
                          S.of(context).your_seed,
                          style: const TextStyle(
                              fontSize: 20, color: Colors.white),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 30),
                          child: Text(
                            S.of(context).your_seed_disclaimer,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ),
                        Text(
                          state.seed,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: CupertinoButton(
                            onPressed: () => _copySeed(state.seed),
                            child: Text(
                              S.of(context).copy_seed,
                              style: const TextStyle(
                                fontSize: 16,
                                color: DEuroColors.dEuroBlue,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: ElevatedButton(
                            onPressed: () => context.read<HomeBloc>().add(LoadWalletEvent(state)),
                            style: kFullwidthPrimaryButtonStyle,
                            child: Text(
                              S.of(context).create_wallet,
                              textAlign: TextAlign.center,
                              style: kPrimaryButtonTextStyle,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return const Center(
                    child: CupertinoActivityIndicator(
                      color: DEuroColors.dEuroGold,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

  Future<void> _copySeed(String seed) async =>
      Clipboard.setData(ClipboardData(text: seed));
}
