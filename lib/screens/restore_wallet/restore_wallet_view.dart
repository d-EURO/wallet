import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/screens/home/bloc/home_bloc.dart';
import 'package:deuro_wallet/screens/restore_wallet/bloc/restore_wallet_cubit.dart';
import 'package:deuro_wallet/screens/restore_wallet/widgets/seed_editing_controller.dart';
import 'package:deuro_wallet/styles/colors.dart';
import 'package:deuro_wallet/styles/styles.dart';
import 'package:deuro_wallet/widgets/text_divider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RestoreWalletView extends StatelessWidget {
  RestoreWalletView({super.key}) : _controller = SeedEditingController();

  final TextEditingController _controller;

  @override
  Widget build(BuildContext context) =>
      BlocListener<RestoreWalletCubit, RestoreWalletState>(
        listener: (context, state) {
          if (state.wallet != null) {
            context.read<HomeBloc>().add(LoadWalletEvent(state.wallet!));
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).restore_wallet,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        S.of(context).restore_wallet_from_seed_description,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Seed",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: DEuroColors.dEuroBlue),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: DEuroColors.dEuroBlue),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        maxLines: null,
                        minLines: 4,
                        onChanged:
                            context.read<RestoreWalletCubit>().validateSeed,
                      ),
                    ),
                    TextDivider(text: S.of(context).or.toUpperCase()),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context
                              .read<RestoreWalletCubit>()
                              .restoreWalletFromSeedQR(context),
                          style: kFullwidthPrimaryButtonStyle,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                S.of(context).restore_wallet_from_seed_qr,
                                textAlign: TextAlign.center,
                                style: kPrimaryButtonTextStyle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    BlocBuilder<RestoreWalletCubit, RestoreWalletState>(
                      builder: (context, state) => Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state.isSeedReady && !state.isLoading
                                ? () => context
                                    .read<RestoreWalletCubit>()
                                    .restoreWallet(_controller.text)
                                : null,
                            style: kFullwidthPrimaryButtonStyle,
                            child: state.isLoading
                                ? CupertinoActivityIndicator(
                                    color: DEuroColors.dEuroGold,
                                  )
                                : Text(S.of(context).create_wallet,
                                    textAlign: TextAlign.center,
                                    style: kPrimaryButtonTextStyle),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
