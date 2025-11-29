import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/glass_widgets.dart';
import '../../app/theme.dart';
import '../shell/home_shell.dart';
import '../../services/local_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _name = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();

  bool _isSignup = false;
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _name.dispose();
    _pw.dispose();
    _pw2.dispose();
    super.dispose();
  }

  Future<void> _saveProfile({String? name, String? email}) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null && name.isNotEmpty) {
      await prefs.setString('player_name', name);
    }
    if (email != null && email.isNotEmpty) {
      await prefs.setString('player_email', email);
    }
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isSignup) {
        if (_pw.text.length < 6) {
          _error = 'Min 6 characters';
        } else if (_pw.text != _pw2.text) {
          _error = 'Passwords do not match';
        } else {
          await LocalAuth.instance.signUp(
            email: _email.text,
            displayName: _name.text.isEmpty ? 'Player' : _name.text,
            password: _pw.text,
          );
          await _saveProfile(
            name: _name.text,
            email: _email.text,
          );
          _goHome();
        }
      } else {
        final ok = await LocalAuth.instance.signIn(
          email: _email.text,
          password: _pw.text,
        );
        if (ok) {
          // name might already be stored from sign-up; we at least update email
          await _saveProfile(email: _email.text);
          _goHome();
        } else {
          _error = 'Invalid email or password';
        }
      }
    } catch (_) {
      _error = 'Something went wrong';
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final secondary =
        isDark ? Colors.white.withValues(alpha: .95) : const Color(0xFF4B5563);

    final pageTitle = _isSignup ? 'Create account' : 'Sign in';

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 36, 20, 24),
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: ShaderMask(
                      shaderCallback: (r) =>
                          const LinearGradient(colors: AppTheme.titleGradient)
                              .createShader(r),
                      child: const Text(
                        'StrikePro',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      pageTitle,
                      style: TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  GlassCard(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                    child: Column(
                      children: [
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _input(context, 'Email'),
                        ),
                        const SizedBox(height: 12),
                        if (_isSignup) ...[
                          TextField(
                            controller: _name,
                            textCapitalization: TextCapitalization.words,
                            decoration: _input(context, 'Display name'),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextField(
                          controller: _pw,
                          obscureText: _obscure,
                          decoration: _input(context, 'Password').copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: secondary,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                        ),
                        if (_isSignup) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _pw2,
                            obscureText: true,
                            decoration:
                                _input(context, 'Confirm password'),
                          ),
                        ],
                        const SizedBox(height: 10),
                        if (_error != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            child: Text(
                              _isSignup ? 'Create account' : 'Sign in',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => setState(() => _isSignup = !_isSignup),
                    child: Text(
                      _isSignup
                          ? 'Have an account? Sign in'
                          : 'New here? Create an account',
                      style: TextStyle(
                        color: secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _input(BuildContext context, String label) {
    final base = Theme.of(context).inputDecorationTheme;
    return InputDecoration(
      labelText: label,
      labelStyle: base.labelStyle,
      filled: base.filled,
      fillColor: base.fillColor,
      contentPadding: base.contentPadding,
      enabledBorder: base.enabledBorder,
      focusedBorder: base.focusedBorder,
      border: base.border,
      hintStyle: base.hintStyle,
    );
  }
}
