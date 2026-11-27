import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/menu.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('project list refreshes from the API', (tester) async {
    var requestCount = 0;
    final apiClient = ApiClient(
      client: MockClient((request) async {
        requestCount++;
        final title = requestCount == 1 ? 'First project' : 'Updated project';
        return http.Response(
          jsonEncode([
            {'title': title, 'description': 'Project description'},
          ]),
          200,
        );
      }),
    );

    await tester.pumpWidget(
      MaterialApp(home: ProjectListScreen(apiClient: apiClient)),
    );
    await tester.pumpAndSettle();
    expect(find.text('First project'), findsOneWidget);

    await tester.drag(find.byType(RefreshIndicator), const Offset(0, 400));
    await tester.pumpAndSettle();

    expect(requestCount, 2);
    expect(find.text('Updated project'), findsOneWidget);
    apiClient.close();
  });

  testWidgets('opening the add form requires login when signed out', (
    tester,
  ) async {
    final apiClient = ApiClient(
      client: MockClient((request) async {
        expect(request.url.path, '/api-token-auth/');
        return http.Response(jsonEncode({'token': 'test-token'}), 200);
      }),
    );

    await tester.pumpWidget(MyApp(apiClient: apiClient));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('portfolio_menu_button')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add project'));
    await tester.pumpAndSettle();
    expect(find.text('Portfolio Sign In'), findsOneWidget);

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

    expect(find.text('Add Project'), findsOneWidget);
  });

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
    await tester.tap(find.byKey(const Key('login_nav_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('google_auth_button')), findsOneWidget);
    expect(find.byKey(const Key('register_link_button')), findsOneWidget);

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
    Map<String, dynamic>? createdProject;
    final apiClient = ApiClient(
      client: MockClient((request) async {
        if (request.url.path == '/api-token-auth/') {
          return http.Response(jsonEncode({'token': 'test-token'}), 200);
        }
        if (request.url.path == '/api/v1/projects/') {
          expect(request.headers['Authorization'], 'Token test-token');
          if (request.method == 'POST') {
            createdProject = Map<String, dynamic>.from(
              jsonDecode(request.body) as Map,
            )..['id'] = 'project-new';
            return http.Response(jsonEncode(createdProject), 201);
          }
          final projects = <Map<String, dynamic>>[
            {
              'id': 'project-1',
              'title': 'Portfolio Website',
              'description':
                  'A portfolio website for displaying my profile and work.',
              'category': 'Website',
              'tech_stack': 'Flutter, Dart',
              'project_url': 'https://example.com',
              'created_at': '2026-01-01',
            },
            if (createdProject != null) createdProject!,
          ];
          return http.Response(jsonEncode(projects), 200);
        }
        if (request.url.path == '/api/logout/') {
          return http.Response(jsonEncode({'detail': 'Logged out.'}), 200);
        }
        return http.Response('Not found', 404);
      }),
    );
    await tester.pumpWidget(MyApp(apiClient: apiClient));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login_nav_button')));
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
    await tester.ensureVisible(find.text('Explore work'));
    await tester.tap(find.text('Explore work'));
    await tester.pumpAndSettle();
    expect(find.text('SELECTED WORK'), findsOneWidget);
    await tester.tap(find.byKey(const Key('portfolio_menu_button')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('manage_api_projects_button')));
    await tester.pumpAndSettle();
    expect(find.text('My projects'), findsOneWidget);
    expect(find.text('Portfolio Website'), findsOneWidget);
    await tester.tap(find.text('Add project'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('project_name_field')),
      'New project',
    );
    await tester.enterText(
      find.byKey(const Key('project_description_field')),
      'Created through the authenticated form.',
    );
    await tester.ensureVisible(find.text('Save project'));
    await tester.tap(find.text('Save project'));
    await tester.pumpAndSettle();
    expect(find.text('Project Summary'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('New project'), findsOneWidget);

    await tester.tap(find.text('Portfolio Website'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('project_detail_screen')), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Created At'), findsOneWidget);
    expect(find.text('2026-01-01'), findsOneWidget);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('portfolio_menu_button')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login_nav_button')), findsOneWidget);
  });
}
