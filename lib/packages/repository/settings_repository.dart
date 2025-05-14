import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  final SharedPreferences _sharedPreferences;

  SettingsRepository(this._sharedPreferences);

  Future<bool> saveCurrentWalletId(int walletId) =>
      _sharedPreferences.setInt("currentWalletId", walletId);

  int? get currentWalletId => _sharedPreferences.getInt("currentWalletId");

  String get language => _sharedPreferences.getString("language") ?? "en";

  set language(String langCode) =>
      _sharedPreferences.setString("language", langCode);
}
