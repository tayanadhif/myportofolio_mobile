// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/menu.dart';

void main() {
  testWidgets('shows the portfolio profile and project list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Nadhif Aydin\nAdinandra'), findsOneWidget);
    expect(find.text(MyHomePage.npm), findsOneWidget);

    await tester.tap(find.text('Jelajahi karya'));
    await tester.pumpAndSettle();
    expect(find.text('Proyek saya'), findsOneWidget);
    expect(find.text('Portfolio Website'), findsOneWidget);
  });
}
