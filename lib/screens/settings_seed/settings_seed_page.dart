import 'package:deuro_wallet/di.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/screens/settings_seed/bloc/settings_seed_cubit.dart';
import 'package:deuro_wallet/screens/settings_seed/settings_seed_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsSeedPage extends StatelessWidget {
  const SettingsSeedPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => SettingsSeedCubit(getIt<AppStore>().wallet.seed),
        child: SettingsSeedView(),
      );
}
