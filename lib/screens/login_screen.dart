import 'package:material_ui/material_ui.dart';

class LoginScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;
  final Future<void> Function(String username, String password) onLoginSuccess;
  final VoidCallback? onRegister;
  final VoidCallback? onGoogleSignIn;

  const LoginScreen({
    super.key,
    required this.isDarkMode,
    this.onThemeToggle,
    required this.onLoginSuccess,
    this.onRegister,
    this.onGoogleSignIn,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await widget.onLoginSuccess(
        _usernameController.text.trim(),
        _passwordController.text,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Sign In'),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: widget.onThemeToggle == null
            ? null
            : [
                IconButton(
                  tooltip: widget.isDarkMode
                      ? 'Enable light mode'
                      : 'Enable dark mode',
                  onPressed: widget.onThemeToggle,
                  icon: Icon(
                    widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  ),
                ),
              ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        'P',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 46,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Sign in to your portfolio',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use your Django account to continue.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      key: const Key('login_username_field'),
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        return value == null || value.trim().isEmpty
                            ? 'Username wajib diisi.'
                            : null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('login_password_field'),
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Password wajib diisi.'
                          : null,
                      onFieldSubmitted: (_) => _signIn(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: TextStyle(color: colorScheme.error)),
                    ],
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      key: const Key('login_button'),
                      onPressed: _isLoading ? null : _signIn,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        side: BorderSide(color: colorScheme.outline),
                      ),
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login, size: 24),
                      label: Text(_isLoading ? 'Signing in...' : 'Sign in'),
                    ),
                    if (widget.onGoogleSignIn != null) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        key: const Key('google_auth_button'),
                        onPressed: widget.onGoogleSignIn,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          side: BorderSide(color: colorScheme.outline),
                        ),
                        icon: const Text(
                          'G',
                          style: TextStyle(
                            color: Color(0xFF4285F4),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        label: const Text('Continue with Google'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Google authentication opens the portfolio website. '
                        'It does not create an API token in this app.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                    if (widget.onRegister != null) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        key: const Key('register_link_button'),
                        onPressed: widget.onRegister,
                        child: const Text('Belum punya akun? Daftar di sini'),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      'Your credentials are sent to the configured Django API.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
