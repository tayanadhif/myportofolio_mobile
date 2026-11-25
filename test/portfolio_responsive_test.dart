import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('portfolio is public and renders without overflow on mobile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final apiClient = ApiClient(
      client: MockClient((_) async => http.Response('{}', 200)),
    );
    addTearDown(apiClient.close);

    await tester.pumpWidget(MyApp(apiClient: apiClient));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login_nav_button')), findsOneWidget);
    expect(find.byKey(const Key('register_nav_button')), findsOneWidget);
    expect(find.byKey(const Key('portfolio_menu_button')), findsOneWidget);
    expect(find.text('SELECTED WORK'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
