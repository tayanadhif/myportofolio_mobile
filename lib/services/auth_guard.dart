import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../screens/login_screen.dart';
import 'auth_state.dart';

Future<bool> ensureLoggedIn(BuildContext context) async {
  final authState = context.read<AuthState>();
  final navigator = Navigator.of(context);
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  await authState.restoreSession();
  if (!context.mounted) return false;
  if (authState.isAuthenticated) return true;

  final loggedIn = await navigator.push<bool>(
    MaterialPageRoute<bool>(
      builder: (_) => LoginScreen(
        isDarkMode: isDarkMode,
        onLoginSuccess: authState.login,
      ),
    ),
  );
  return loggedIn == true && authState.isAuthenticated;
}
