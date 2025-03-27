import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  final SharedPreferences _sharedPreferences;

  SettingsRepository(this._sharedPreferences);

  Future<bool> saveCurrentWalletId(int walletId) =>
      _sharedPreferences.setInt("currentWalletId", walletId);

  int? getCurrentWalletId() => _sharedPreferences.getInt("currentWalletId");
}
