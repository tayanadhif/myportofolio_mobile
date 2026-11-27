import 'package:google_sign_in/google_sign_in.dart';

import 'api_client.dart';

abstract interface class GoogleIdentityProvider {
  Future<String?> signIn();

  Future<void> signOut();
}

class NativeGoogleIdentityProvider implements GoogleIdentityProvider {
  NativeGoogleIdentityProvider({GoogleSignIn? googleSignIn})
    : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  static const _serverClientId = String.fromEnvironment(
    'GOOGLE_OAUTH_WEB_CLIENT_ID',
  );
  static const _iosClientId = String.fromEnvironment(
    'GOOGLE_OAUTH_IOS_CLIENT_ID',
  );

  final GoogleSignIn _googleSignIn;
  Future<void>? _initialization;

  @override
  Future<String?> signIn() async {
    if (!_googleSignIn.supportsAuthenticate()) {
      throw const ApiException(
        'Login Google native hanya didukung pada Android dan iOS. '
        'Jalankan aplikasi di emulator atau perangkat mobile, bukan browser.',
      );
    }

    if (_serverClientId.isEmpty) {
      throw const ApiException(
        'Google Sign-In belum dikonfigurasi. Jalankan aplikasi dengan '
        '--dart-define=GOOGLE_OAUTH_WEB_CLIENT_ID=<Web OAuth client ID>.',
      );
    }

    _initialization ??= _googleSignIn.initialize(
      clientId: _iosClientId.isEmpty ? null : _iosClientId,
      serverClientId: _serverClientId,
    );
    await _initialization;

    try {
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const ApiException('Google tidak mengembalikan ID token.');
      }
      return idToken;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return null;
      throw ApiException(
        error.description ?? 'Google Sign-In gagal (${error.code.name}).',
      );
    }
  }

  @override
  Future<void> signOut() async {
    if (_initialization != null) await _googleSignIn.signOut();
  }
}
