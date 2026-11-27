import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/screens/add_project_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'api_auth_token': 'test-token'});
  });

  testWidgets('validates required fields and optional project URL', (
    WidgetTester tester,
  ) async {
    var postCount = 0;
    final apiClient = ApiClient(
      client: MockClient((request) async {
        expect(request.url.path, '/api/v1/projects/');
        expect(request.headers['Authorization'], 'Token test-token');
        postCount++;
        return http.Response(
          jsonEncode({
            'id': 42,
            'title': 'Test Project',
            'description': 'Test description',
            'category': 'Other',
            'tech_stack': '',
            'project_url': '',
          }),
          201,
        );
      }),
    );
    final authState = AuthState(apiClient);
    await authState.restoreSession();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: authState,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddProjectPage(apiClient: apiClient),
                    ),
                  );
                },
                child: const Text('Open form'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();

    final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold).last);
    scaffold.openDrawer();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Add project'), findsOneWidget);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Open form'), findsOneWidget);

    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Save project'));
    await tester.tap(find.text('Save project'));
    await tester.pumpAndSettle();
    expect(find.text('Project name is required.'), findsOneWidget);
    expect(find.text('Project description is required.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('project_name_field')),
      '  Test Project  ',
    );
    await tester.enterText(
      find.byKey(const Key('project_description_field')),
      ' Test description ',
    );
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('project_link_field')));
    await tester.enterText(
      find.byKey(const Key('project_link_field')),
      'not-a-url',
    );
    await tester.ensureVisible(find.text('Save project'));
    await tester.tap(find.text('Save project'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid URL (http or https).'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('project_link_field')), '');
    await tester.ensureVisible(find.text('Save project'));
    await tester.tap(find.text('Save project'));
    await tester.pumpAndSettle();

    expect(find.text('Project Summary'), findsOneWidget);
    expect(find.text('Project name: Test Project'), findsOneWidget);
    expect(find.text('Description: Test description'), findsOneWidget);
    expect(find.text('Category: Other'), findsOneWidget);
    expect(find.text('Technologies: -'), findsOneWidget);
    expect(find.text('Project link: -'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Open form'), findsOneWidget);
    expect(postCount, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    authState.dispose();
    apiClient.close();
  });

  testWidgets('a 401 clears the session and requests login again', (
    tester,
  ) async {
    var postCount = 0;
    final apiClient = ApiClient(
      client: MockClient((request) async {
        if (request.url.path == '/api/v1/projects/') {
          postCount++;
          expect(request.headers['Authorization'], 'Token test-token');
          return http.Response(jsonEncode({'detail': 'Invalid token.'}), 401);
        }
        if (request.url.path == '/api/logout/') {
          return http.Response('', 401);
        }
        if (request.url.path == '/api-token-auth/') {
          return http.Response(jsonEncode({'token': 'fresh-token'}), 200);
        }
        return http.Response('Not found', 404);
      }),
    );
    final authState = AuthState(apiClient);
    await authState.restoreSession();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: authState,
        child: MaterialApp(home: AddProjectPage(apiClient: apiClient)),
      ),
    );
    await tester.enterText(
      find.byKey(const Key('project_name_field')),
      'Test Project',
    );
    await tester.enterText(
      find.byKey(const Key('project_description_field')),
      'Test description',
    );
    await tester.ensureVisible(find.text('Save project'));
    await tester.tap(find.text('Save project'));
    await tester.pumpAndSettle();

    expect(postCount, 1);
    expect(authState.token, isNull);
    expect(find.text('Portfolio Sign In'), findsOneWidget);
    expect(find.text('Invalid token.'), findsOneWidget);

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

    expect(authState.token, 'fresh-token');
    expect(find.text('Add Project'), findsOneWidget);
    expect(postCount, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    authState.dispose();
    apiClient.close();
  });
}
