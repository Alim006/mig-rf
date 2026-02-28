import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _api;
  final StorageService _storage;

  AuthService(this._api, this._storage);

  Future<void> loginWithPassword(String phone, String password) async {
    final data = await _api.loginWithPassword(phone, password);
    await _handleTokens(data);
  }

  Future<void> loginWithSms(String phone, String code) async {
    final data = await _api.loginWithSms(phone, code);
    await _handleTokens(data);
  }

  Future<void> loginWithPin(String pin) async {
    final userId = await _storage.getUserId();
    if (userId == null) throw Exception('No user ID saved');
    final data = await _api.loginWithPin(userId, pin);
    await _handleTokens(data);
  }

  Future<void> registerWithSms(String phone, String code) async {
    final data = await _api.registerWithSms(phone, code);
    await _handleTokens(data);
  }

  Future<void> registerWithPassword(String phone, String password) async {
    final data = await _api.registerWithPassword(phone, password);
    await _handleTokens(data);
  }

  Future<void> setPin(String pin, String pinConfirm) async {
    await _api.setPin(pin, pinConfirm);
    await _storage.setPinSet(true);
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {}
    await _storage.clearTokens();
    await _storage.setLoggedIn(false);
    await _storage.setPinSet(false);
  }

  bool get isLoggedIn => _storage.isLoggedIn();
  bool get hasPinSet => _storage.hasPinSet();

  Future<void> _handleTokens(Map<String, dynamic> data) async {
    await _storage.saveTokens(data['accessToken'], data['refreshToken']);
    await _storage.setLoggedIn(true);
    // Decode user ID from token
    // (simplified - in prod decode JWT properly)
    final profile = await _api.getProfile();
    if (profile['id'] != null) {
      await _storage.saveUserId(profile['id']);
    }
  }
}
