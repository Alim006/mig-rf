import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  StorageService(this._prefs);

  // Locale
  String? getLocale() => _prefs.getString('locale');
  Future<void> setLocale(String locale) => _prefs.setString('locale', locale);

  // Auth tokens
  Future<void> saveTokens(String access, String refresh) async {
    await _secure.write(key: 'access_token', value: access);
    await _secure.write(key: 'refresh_token', value: refresh);
  }

  Future<String?> getAccessToken() => _secure.read(key: 'access_token');
  Future<String?> getRefreshToken() => _secure.read(key: 'refresh_token');

  Future<void> clearTokens() async {
    await _secure.delete(key: 'access_token');
    await _secure.delete(key: 'refresh_token');
    await _secure.delete(key: 'user_id');
  }

  // User ID for PIN login
  Future<void> saveUserId(String id) => _secure.write(key: 'user_id', value: id);
  Future<String?> getUserId() => _secure.read(key: 'user_id');

  // PIN is stored as hash on server, locally we just flag it's set
  bool hasPinSet() => _prefs.getBool('pin_set') ?? false;
  Future<void> setPinSet(bool val) => _prefs.setBool('pin_set', val);

  // Is logged in
  bool isLoggedIn() => _prefs.getBool('logged_in') ?? false;
  Future<void> setLoggedIn(bool val) => _prefs.setBool('logged_in', val);
}
