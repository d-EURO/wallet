import 'dart:developer' as developer;

import 'package:deuro_wallet/di.dart';
import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/packages/service/balance_service.dart';
import 'package:deuro_wallet/screens/home/bloc/home_bloc.dart';
import 'package:deuro_wallet/screens/settings/bloc/settings_bloc.dart';
import 'package:deuro_wallet/styles/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  await setup();

  runApp(const DEuroWallet());
}

class DEuroWallet extends StatefulWidget {
  const DEuroWallet({super.key});

  @override
  State<StatefulWidget> createState() => _DEuroWalletState();
}

class _DEuroWalletState extends State<DEuroWallet> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(onStateChange: _onStateChanged);
  }

  @override
  void dispose() {
    _listener.dispose();

    super.dispose();
  }

  void _onStateChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        _onDetached();
      case AppLifecycleState.resumed:
        _onResumed();
      case AppLifecycleState.inactive:
        _onInactive();
      case AppLifecycleState.hidden:
        _onHidden();
      case AppLifecycleState.paused:
        _onPaused();
    }
  }

  void _onDetached() => debugPrint('detached');

  void _onResumed() {
    getIt<BalanceService>()
        .updateERC20Balances(getIt<AppStore>().primaryAddress);
  }

  void _onInactive() => developer.log('inactive', name: 'AppLifecycleListener');

  void _onHidden() => developer.log('hidden', name: 'AppLifecycleListener');

  void _onPaused() {
    getIt<BalanceService>().cancelSync();
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: getIt<HomeBloc>()),
          BlocProvider.value(value: getIt<SettingsBloc>()),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: darkTheme,
            supportedLocales: S.delegate.supportedLocales,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: Locale(state.language.code),
            routerConfig: getIt<GoRouter>(),
            builder: (context, child) => BlocListener<HomeBloc, HomeState>(
              listener: (context, state) {
                if (!state.isLoadingWallet) {
                  getIt<GoRouter>()
                      .go(state.openWallet != null ? '/dashboard' : '/welcome');
                }
              },
              child: child,
            ),
          ),
        ),
      );
}
