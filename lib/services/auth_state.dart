import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';
import 'google_sign_in_service.dart';

class AuthState extends ChangeNotifier {
  AuthState(this.apiClient, {GoogleIdentityProvider? googleIdentityProvider})
    : _googleIdentityProvider =
          googleIdentityProvider ?? NativeGoogleIdentityProvider();

  static const _tokenKey = 'api_auth_token';
  final ApiClient apiClient;
  final GoogleIdentityProvider _googleIdentityProvider;
  String? _token;
  bool _isLoading = false;
  Future<void>? _restoreSessionFuture;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  Future<void> restoreSession() =>
      _restoreSessionFuture ??= _loadRestoredSession();

  Future<void> _loadRestoredSession() async {
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

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      final idToken = await _googleIdentityProvider.signIn();
      if (idToken == null) return false;

      final token = await apiClient.loginWithGoogle(idToken);
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_tokenKey, token);
      _token = token;
      return true;
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
      try {
        await _googleIdentityProvider.signOut();
      } finally {
        final preferences = await SharedPreferences.getInstance();
        await preferences.remove(_tokenKey);
      }
    }
  }
}
