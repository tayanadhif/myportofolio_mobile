import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('login displays an API authentication error', (tester) async {
    final apiClient = ApiClient(
      client: MockClient((request) async {
        expect(request.url.path, '/api-token-auth/');
        return http.Response(
          jsonEncode({'detail': 'Invalid username or password.'}),
          400,
        );
      }),
    );
    await tester.pumpWidget(MyApp(apiClient: apiClient));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('login_username_field')),
      'nadhif',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'wrong-password',
    );
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.text('Invalid username or password.'), findsOneWidget);
  });

  testWidgets('token login opens the portfolio and loads API projects', (
    tester,
  ) async {
    final apiClient = ApiClient(
      client: MockClient((request) async {
        if (request.url.path == '/api-token-auth/') {
          return http.Response(jsonEncode({'token': 'test-token'}), 200);
        }
        if (request.url.path == '/api/v1/projects/') {
          expect(request.headers['Authorization'], 'Token test-token');
          return http.Response(
            jsonEncode([
              {
                'id': 'project-1',
                'title': 'Portfolio Website',
                'description':
                    'A portfolio website for displaying my profile and work.',
                'category': 'Website',
                'tech_stack': 'Flutter, Dart',
                'project_url': 'https://example.com',
              },
            ]),
            200,
          );
        }
        if (request.url.path == '/api/logout/') {
          return http.Response(jsonEncode({'detail': 'Logged out.'}), 200);
        }
        return http.Response('Not found', 404);
      }),
    );
    await tester.pumpWidget(MyApp(apiClient: apiClient));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('login_username_field')),
      'nadhif',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'password',
    );
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.text(MyHomePage.npm), findsOneWidget);
    await tester.tap(find.text('Explore work'));
    await tester.pumpAndSettle();
    expect(find.text('My projects'), findsOneWidget);
    expect(find.text('Portfolio Website'), findsOneWidget);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes, leave'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in to your portfolio'), findsOneWidget);
  });
}
