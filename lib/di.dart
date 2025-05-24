import 'dart:io';

import 'package:deuro_wallet/packages/open_crypto_pay/open_crypto_pay_service.dart';
import 'package:deuro_wallet/packages/repository/asset_repository.dart';
import 'package:deuro_wallet/packages/repository/balance_repository.dart';
import 'package:deuro_wallet/packages/repository/node_repository.dart';
import 'package:deuro_wallet/packages/repository/settings_repository.dart';
import 'package:deuro_wallet/packages/repository/transaction_repository.dart';
import 'package:deuro_wallet/packages/repository/wallet_repository.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/packages/service/balance_service.dart';
import 'package:deuro_wallet/packages/service/dfx/dfx_service.dart';
import 'package:deuro_wallet/packages/service/transaction_history_service.dart';
import 'package:deuro_wallet/packages/service/wallet_service.dart';
import 'package:deuro_wallet/packages/storage/database.dart';
import 'package:deuro_wallet/packages/storage/secure_storage.dart';
import 'package:deuro_wallet/router.dart';
import 'package:deuro_wallet/screens/home/bloc/home_bloc.dart';
import 'package:deuro_wallet/screens/restore_wallet/bloc/restore_wallet_cubit.dart';
import 'package:deuro_wallet/screens/savings/bloc/savings_bloc.dart';
import 'package:deuro_wallet/screens/settings/bloc/settings_bloc.dart';
import 'package:deuro_wallet/setup.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<String> setupEssentials() async {
  setupRouter();

  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton(sharedPreferences);

  getIt.registerFactory(() => SettingsRepository(getIt<SharedPreferences>()));
  getIt.registerSingleton(SettingsBloc(getIt<SettingsRepository>()));

  final secureStorage = const SecureStorage();
  getIt.registerSingleton(secureStorage);

  final encryptionKey = await secureStorage.getEncryptionKey();

  if (encryptionKey == null) {
    if (await _existsDatabaseFile()) {
      return 'drift.example.unsafe_password';
    }
    final freshEncryptionKey = SecureStorage.getNewEncryptionKey();
    await secureStorage.setEncryptionKey(freshEncryptionKey);

    return freshEncryptionKey;
  }

  return encryptionKey;
}

Future<void> finishSetup(String encryptionKey) async {
  getIt.registerSingleton(AppDatabase(encryptionKey));
  getIt.registerSingleton(AppStore());

  setupRepositories();
  setupServices();
  setupBlocs();

  await setupDefaultAssets();
  await setupDefaultNodes();
  await getIt<AppStore>().refreshNodes(getIt<NodeRepository>());
}

void setupRepositories() {
  getIt.registerFactory(() => WalletRepository(getIt<AppDatabase>()));
  getIt.registerFactory(() => BalanceRepository(getIt<AppDatabase>()));
  getIt.registerFactory(() => AssetRepository(getIt<AppDatabase>()));
  getIt.registerFactory(() => NodeRepository(getIt<AppDatabase>()));
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

  getIt.registerFactory(() => OpenCryptoPayService());
  getIt.registerFactory(() => DFXService(getIt<AppStore>(),
      getIt<SettingsRepository>(), getIt<AssetRepository>()));
}

void setupBlocs() {
  getIt.registerSingleton(HomeBloc(
    getIt<WalletService>(),
    getIt<BalanceService>(),
    getIt<TransactionHistoryService>(),
    getIt<AppStore>(),
  ));

  getIt.registerFactory(() => RestoreWalletCubit(getIt<WalletService>()));

  getIt.registerFactory(() => SavingsBloc(getIt<AppStore>()));
}

Future<bool> _existsDatabaseFile() async =>
    File(await AppDatabase.getDatabasePath()).exists();
