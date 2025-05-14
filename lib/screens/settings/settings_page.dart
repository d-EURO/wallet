import 'package:deuro_wallet/di.dart';
import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/screens/home/bloc/home_bloc.dart';
import 'package:deuro_wallet/screens/settings/bloc/settings_bloc.dart';
import 'package:deuro_wallet/screens/settings/widgets/settings_section.dart';
import 'package:deuro_wallet/styles/colors.dart';
import 'package:deuro_wallet/styles/icons.dart';
import 'package:deuro_wallet/styles/language.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
            S.of(context).settings,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Satoshi',
            ),
          ),
          border: null,
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                BlocBuilder<SettingsBloc, SettingsState>(
                  bloc: getIt<SettingsBloc>(),
                  builder: (context, state) => SettingsSections(
                    title: S.of(context).settings_general,
                    settings: [
                      SettingOption(
                          title: S.of(context).settings_nodes,
                          leading: NodesIcon(size: 24),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                            color: DEuroColors.anthracite,
                          )),
                      SettingOption(
                        title: S.of(context).settings_languages,
                        leading: LanguagesIcon(
                          size: 24,
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                          color: DEuroColors.anthracite,
                        ),
                        selectedOption: state.language.name,
                        onTap: () => context
                            .read<SettingsBloc>()
                            .add(SetLanguageEvent(Language.de)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 36, bottom: 36),
                  child: TextButton(
                    onPressed: () => context
                        .read<HomeBloc>()
                        .add(DeleteCurrentWalletEvent()),
                    style: TextButton.styleFrom(
                      fixedSize: Size(double.infinity, 46),
                      backgroundColor: DEuroColors.neutralGrey93,
                      padding: EdgeInsets.only(left: 24, right: 24),
                    ),
                    child: Text(
                      S.of(context).sign_out,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
