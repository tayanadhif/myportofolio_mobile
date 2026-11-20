// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/menu.dart';

void main() {
  testWidgets('Google login validates the Gmail address', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('google_email_field')),
      'nadhif@outlook.com',
    );
    await tester.tap(find.byKey(const Key('continue_with_google_button')));
    await tester.pumpAndSettle();

    expect(find.text('Use a valid Gmail address.'), findsOneWidget);
  });

  testWidgets('shows the portfolio profile and project list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to my portfolio'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('google_email_field')),
      'nadhif@gmail.com',
    );
    await tester.tap(find.byKey(const Key('continue_with_google_button')));
    await tester.pumpAndSettle();

    expect(find.text('Nadhif Aydin\nAdinandra'), findsOneWidget);
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

    expect(find.text('Welcome to my portfolio'), findsOneWidget);
  });
}
