import 'package:flutter/material.dart';
import '../../services/local_auth.dart';
import '../shell/home_shell.dart';

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
        if (_pw.text.length < 6) { setState(() => _error = 'Min 6 characters'); }
        else if (_pw.text != _pw2.text) { setState(() => _error = 'Passwords do not match'); }
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
        if (ok) _goHome(); else setState(() => _error = 'Invalid email or password');
      }
    } catch (e) {
      setState(() => _error = 'Something went wrong');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
  }

  @override
  Widget build(BuildContext context) {
    final title = _isSignup ? 'Create account' : 'Sign in';
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
          children: [
            const SizedBox(height: 6),
            Text('StrikePro', textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            Text(title, textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),

            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            if (_isSignup) ...[
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Display name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
            ],

            TextField(
              controller: _pw,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            if (_isSignup) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _pw2,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm password', border: OutlineInputBorder()),
              ),
            ],
            const SizedBox(height: 10),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _submit,
                child: Text(_isSignup ? 'Create account' : 'Sign in'),
              ),
            ),
            TextButton(
              onPressed: _loading ? null : () => setState(() => _isSignup = !_isSignup),
              child: Text(_isSignup ? 'Have an account? Sign in' : 'New here? Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}
