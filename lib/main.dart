import 'dart:async';

import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:myportofolio_mobile/menu.dart';
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
  bool _isDarkMode = true;
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
          title: 'Nadhif Aydin Adinandra - Portfolio',
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: MyHomePage(
            isDarkMode: _isDarkMode,
            onThemeToggle: _toggleTheme,
            onLogout: auth.logout,
            authState: auth,
          ),
        ),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: isDark
          ? const Color(0xFFFF5B4E)
          : const Color(0xFFC93E36),
      brightness: brightness,
    ).copyWith(
      surface: isDark ? const Color(0xFF11141A) : const Color(0xFFFFFAF1),
      primary: isDark ? const Color(0xFFFF5B4E) : const Color(0xFFC93E36),
      secondary: isDark ? const Color(0xFFFFC247) : const Color(0xFFC93E36),
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF050609)
          : const Color(0xFFEEE8DC),
      textTheme: GoogleFonts.spaceGroteskTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ),
      useMaterial3: true,
    );
  }
}
