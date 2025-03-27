import 'package:deuro_wallet/di.dart';
import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/screens/home/bloc/home_bloc.dart';
import 'package:deuro_wallet/styles/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  await setup();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: getIt<HomeBloc>())
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: darkTheme,
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
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
      );
}
