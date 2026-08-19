import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  String? getToken() {
    return _prefs.getString('auth_token');
  }

  Future<void> removeToken() async {
    await _prefs.remove('auth_token');
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }
}
