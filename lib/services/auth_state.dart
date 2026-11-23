import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

class AuthState extends ChangeNotifier {
  AuthState(this.apiClient);

  static const _tokenKey = 'api_auth_token';
  final ApiClient apiClient;
  String? _token;
  bool _isLoading = false;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  Future<void> restoreSession() async {
    final preferences = await SharedPreferences.getInstance();
    _token = preferences.getString(_tokenKey);
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _token = await apiClient.login(username, password);
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_tokenKey, _token!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final oldToken = _token;
    _token = null;
    notifyListeners();
    try {
      if (oldToken != null) await apiClient.logout(oldToken);
    } catch (_) {
      // Always clear the local session, even when the server is unreachable.
    } finally {
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove(_tokenKey);
    }
  }
}
