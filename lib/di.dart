import 'package:deuro_wallet/packages/repository/asset_repository.dart';
import 'package:deuro_wallet/packages/repository/balance_repository.dart';
import 'package:deuro_wallet/packages/repository/settings_repository.dart';
import 'package:deuro_wallet/packages/repository/transaction_repository.dart';
import 'package:deuro_wallet/packages/repository/wallet_repository.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/packages/service/balance_service.dart';
import 'package:deuro_wallet/packages/service/transaction_history_service.dart';
import 'package:deuro_wallet/packages/service/wallet_service.dart';
import 'package:deuro_wallet/packages/storage/database.dart';
import 'package:deuro_wallet/router.dart';
import 'package:deuro_wallet/screens/home/bloc/home_bloc.dart';
import 'package:deuro_wallet/screens/restore_wallet/bloc/restore_wallet_cubit.dart';
import 'package:deuro_wallet/setup.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  setupRouter();
  await setupStorage();
  setupRepositories();
  setupServices();
  setupBlocs();

  await setupDefaultAssets();
}

Future<void> setupStorage() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton(sharedPreferences);
  getIt.registerSingleton(AppDatabase());
  getIt.registerSingleton(AppStore());
}

void setupRepositories() {
  getIt.registerFactory(() => WalletRepository(getIt<AppDatabase>()));
  getIt.registerFactory(() => BalanceRepository(getIt<AppDatabase>()));
  getIt.registerFactory(() => AssetRepository(getIt<AppDatabase>()));
  getIt.registerFactory(() => SettingsRepository(getIt<SharedPreferences>()));
  getIt.registerFactory(() =>
      TransactionRepository(getIt<AppDatabase>(), getIt<AssetRepository>()));
}

void setupServices() {
  getIt.registerFactory(() =>
      WalletService(getIt<WalletRepository>(), getIt<SettingsRepository>()));

  getIt.registerSingleton(BalanceService(
      getIt<BalanceRepository>(), getIt<AssetRepository>(), getIt<AppStore>()));

  getIt.registerFactory(() => TransactionHistoryService(getIt<AppStore>(),
      getIt<AssetRepository>(), getIt<TransactionRepository>()));
}

void setupBlocs() {
  getIt.registerSingleton(HomeBloc(
      getIt<WalletService>(), getIt<BalanceService>(), getIt<AppStore>()));

  getIt.registerFactory(() => RestoreWalletCubit(getIt<WalletService>()));
}
