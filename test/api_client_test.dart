import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

void main() {
  test('GET section reads a public API list', () async {
    final apiClient = ApiClient(
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/skills/');
        expect(request.headers['Authorization'], isNull);
        return http.Response(
          jsonEncode({
            'results': [
              {'name': 'Dart', 'level': 'Intermediate'},
            ],
          }),
          200,
        );
      }),
    );

    expect(await apiClient.getSection('skills'), [
      {'name': 'Dart', 'level': 'Intermediate'},
    ]);
    apiClient.close();
  });

  test('POST section sends JSON with token authentication', () async {
    final apiClient = ApiClient(
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/projects/');
        expect(request.headers['Authorization'], 'Token test-token');
        expect(request.headers['Content-Type'], 'application/json');
        expect(jsonDecode(request.body), {'title': 'Portfolio'});
        return http.Response(jsonEncode({'id': 42, 'title': 'Portfolio'}), 201);
      }),
    );

    expect(
      await apiClient.postSection('projects', {
        'title': 'Portfolio',
      }, 'test-token'),
      {'id': 42, 'title': 'Portfolio'},
    );
    apiClient.close();
  });

  test('Google login exchanges an ID token for a DRF API token', () async {
    final apiClient = ApiClient(
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/auth/google/');
        expect(request.headers['Content-Type'], 'application/json');
        expect(jsonDecode(request.body), {
          'id_token': 'signed-google-id-token',
        });
        return http.Response(jsonEncode({'token': 'api-token'}), 200);
      }),
    );

    expect(
      await apiClient.loginWithGoogle('signed-google-id-token'),
      'api-token',
    );
    apiClient.close();
  });

  test('registration creates an account and returns its API token', () async {
    final apiClient = ApiClient(
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/auth/register/');
        expect(request.headers['Content-Type'], 'application/json');
        expect(jsonDecode(request.body), {
          'full_name': 'Mobile User',
          'username': 'mobile-user',
          'email': 'mobile@example.com',
          'password1': 'correct-horse-battery-17',
          'password2': 'correct-horse-battery-17',
        });
        return http.Response(
          jsonEncode({'token': 'registration-api-token'}),
          201,
        );
      }),
    );

    expect(
      await apiClient.register(
        fullName: 'Mobile User',
        username: 'mobile-user',
        email: 'mobile@example.com',
        password: 'correct-horse-battery-17',
        passwordConfirmation: 'correct-horse-battery-17',
      ),
      'registration-api-token',
    );
    apiClient.close();
  });
}
