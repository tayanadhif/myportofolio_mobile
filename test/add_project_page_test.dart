import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/screens/add_project_page.dart';

void main() {
  testWidgets('validates required fields and optional project URL', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                await Navigator.push<void>(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProjectPage()),
                );
              },
              child: const Text('Open form'),
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
    expect(find.text('Add Project'), findsOneWidget);
  });
}
