import 'package:flutter/material.dart';
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
  final _name  = TextEditingController();
  final _pw    = TextEditingController();
  final _pw2   = TextEditingController();

  bool _isSignup = false;
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose(); _name.dispose(); _pw.dispose(); _pw2.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (_isSignup) {
        if (_pw.text.length < 6) { _error = 'Min 6 characters'; }
        else if (_pw.text != _pw2.text) { _error = 'Passwords do not match'; }
        else {
          await LocalAuth.instance.signUp(
            email: _email.text,
            displayName: _name.text.isEmpty ? 'Player' : _name.text,
            password: _pw.text,
          );
          _goHome();
        }
      } else {
        final ok = await LocalAuth.instance.signIn(
          email: _email.text,
          password: _pw.text,
        );
        if (ok) _goHome(); else _error = 'Invalid email or password';
      }
    } catch (_) {
      _error = 'Something went wrong';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goHome() {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
  }

  @override
  Widget build(BuildContext context) {
    final title = _isSignup ? 'Create account' : 'Sign in';

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
                  // Logo / App title
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
                      title,
                      style: const TextStyle(
                        color: Colors.white,
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
                          decoration: _input('Email'),
                        ),
                        const SizedBox(height: 12),
                        if (_isSignup) ...[
                          TextField(
                            controller: _name,
                            textCapitalization: TextCapitalization.words,
                            decoration: _input('Display name'),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextField(
                          controller: _pw,
                          obscureText: _obscure,
                          decoration: _input('Password').copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure ? Icons.visibility : Icons.visibility_off,
                                color: Colors.white.withValues(alpha: .85),
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
                            decoration: _input('Confirm password'),
                          ),
                        ],
                        const SizedBox(height: 10),
                        if (_error != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Color(0xFFFFB4B4)),
                            ),
                          ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: .14),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              _isSignup ? 'Create account' : 'Sign in',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _loading ? null : () => setState(() => _isSignup = !_isSignup),
                    child: Text(
                      _isSignup
                          ? 'Have an account? Sign in'
                          : 'New here? Create an account',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .95),
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

  InputDecoration _input(String label) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: .75)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: .06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .35)),
        ),
      );
}
