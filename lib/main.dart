import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/menu.dart';
import 'package:myportofolio_mobile/screens/google_login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  bool _isLoggedIn = false;

  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  void _login() {
    setState(() => _isLoggedIn = true);
  }

  void _logout() {
    setState(() => _isLoggedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPortfolio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD95D39)),
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
      home: _isLoggedIn
          ? MyHomePage(
              isDarkMode: _isDarkMode,
              onThemeToggle: _toggleTheme,
              onLogout: _logout,
            )
          : GoogleLoginPage(
              isDarkMode: _isDarkMode,
              onThemeToggle: _toggleTheme,
              onLoginSuccess: _login,
            ),
    );
  }
}
