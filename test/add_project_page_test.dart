import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/project.dart';
import 'package:myportofolio_mobile/screens/add_project_page.dart';

void main() {
  testWidgets('validates required fields and optional project URL', (
    WidgetTester tester,
  ) async {
    Project? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await Navigator.push<Project>(
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

    expect(result?.title, 'Test Project');
    expect(result?.description, 'Test description');
    expect(result?.technologies, isEmpty);
    expect(result?.link, isEmpty);
  });
}
