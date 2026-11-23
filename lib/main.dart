import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:myportofolio_mobile/menu.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  final ApiClient? apiClient;

  const MyApp({super.key, this.apiClient});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  late final AuthState _authState;

  @override
  void initState() {
    super.initState();
    _authState = AuthState(widget.apiClient ?? ApiClient());
    unawaited(_authState.restoreSession());
  }

  @override
  void dispose() {
    _authState.apiClient.close();
    _authState.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: _authState)],
      child: Consumer<AuthState>(
        builder: (context, auth, _) => MaterialApp(
          title: 'MyPortfolio',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFD95D39),
            ),
            scaffoldBackgroundColor: const Color(0xFFFAF6F0),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFF59E0B),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: auth.isAuthenticated
              ? MyHomePage(
                  isDarkMode: _isDarkMode,
                  onThemeToggle: _toggleTheme,
                  onLogout: auth.logout,
                  authState: auth,
                )
              : LoginScreen(
                  isDarkMode: _isDarkMode,
                  onThemeToggle: _toggleTheme,
                  onLoginSuccess: auth.login,
                ),
        ),
      ),
    );
  }
}
