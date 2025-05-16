import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/screens/settings_seed/bloc/settings_seed_cubit.dart';
import 'package:deuro_wallet/styles/colors.dart';
import 'package:deuro_wallet/widgets/icons.dart';
import 'package:deuro_wallet/widgets/seed_blur_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class SettingsSeedView extends StatelessWidget {
  const SettingsSeedView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: CupertinoNavigationBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: DEuroColors.anthracite,
              size: 24,
            ),
          ),
          middle: Text(
            S.of(context).seed,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Satoshi',
            ),
          ),
          border: null,
        ),
        body: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: BlocBuilder<SettingsSeedCubit, bool>(
                builder: (context, state) => Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: SvgPicture.asset(
                        "assets/images/backup_seed.svg",
                        width: 155,
                      ),
                    ),
                    Text(
                      S.of(context).create_wallet_title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: DEuroColors.anthracite,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 3, bottom: 20),
                      child: Text(
                        S.of(context).create_wallet_subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 14, color: DEuroColors.neutralGrey),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 10, top: 5),
                            child: RecoveryKeyIcon(size: 20),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Text(
                                    S
                                        .of(context)
                                        .create_wallet_recovery_key_title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: DEuroColors.anthracite,
                                    ),
                                  ),
                                ),
                                Text(
                                  S
                                      .of(context)
                                      .create_wallet_recovery_key_subtitle,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: DEuroColors.neutralGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SeedBlurCard(
                      text: context.read<SettingsSeedCubit>().seed,
                      onTap: context.read<SettingsSeedCubit>().toggleShowSeed,
                      blur: state,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: CupertinoButton(
                        onPressed: () =>
                            _copySeed(context.read<SettingsSeedCubit>().seed),
                        child: Text(
                          S.of(context).copy_seed,
                          style: const TextStyle(
                            fontSize: 16,
                            color: DEuroColors.dEuroBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Future<void> _copySeed(String seed) async =>
      Clipboard.setData(ClipboardData(text: seed));
}
