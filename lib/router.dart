import 'package:deuro_wallet/di.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/screens/create_wallet/create_wallet_page.dart';
import 'package:deuro_wallet/screens/dashboard/dashboard_page.dart';
import 'package:deuro_wallet/screens/home/home.dart';
import 'package:deuro_wallet/screens/receive/receive_page.dart';
import 'package:deuro_wallet/screens/restore_wallet/restore_wallet_page.dart';
import 'package:deuro_wallet/screens/savings/savings_page.dart';
import 'package:deuro_wallet/screens/savings_edit/savings_edit_page.dart';
import 'package:deuro_wallet/screens/send/send_page.dart';
import 'package:deuro_wallet/screens/settings/settings_page.dart';
import 'package:deuro_wallet/screens/settings_languages/settings_languages_page.dart';
import 'package:deuro_wallet/screens/welcome/welcome_page.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void setupRouter() {
  getIt.registerSingleton(GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    // observers: [GoRouterObserver()],
    routes: <RouteBase>[
      GoRoute(path: "/", builder: (context, state) => HomePage()),
      GoRoute(path: "/welcome", builder: (context, state) => WelcomePage()),
      GoRoute(
          path: "/wallet/create",
          builder: (context, state) => CreateWalletPage()),
      GoRoute(
          path: "/wallet/restore",
          builder: (context, state) => RestoreWalletPage()),
      GoRoute(
          path: "/dashboard",
          builder: (context, state) => DashboardPage(getIt<AppStore>())),
      GoRoute(path: "/receive", builder: (context, state) => ReceivePage()),
      GoRoute(path: "/send", builder: (context, state) => SendPage()),
      GoRoute(
        path: "/settings",
        routes: [
          GoRoute(
              path: '/languages',
              builder: (context, state) => SettingsLanguagePage()),
        ],
        builder: (context, state) => SettingsPage(),
      ),
      GoRoute(
        path: "/savings",
        routes: [
          GoRoute(
              path: '/add',
              builder: (context, state) => SavingsEditPage(isAdding: true)),
          GoRoute(
              path: '/remove',
              builder: (context, state) => SavingsEditPage(isAdding: false)),
        ],
        builder: (context, state) => SavingsPage(),
      ),
    ],
  ));
}
