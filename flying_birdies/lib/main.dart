import 'package:flutter/material.dart';

import 'app/theme.dart';
import 'app/theme_controller.dart';
import 'services/local_auth.dart';

// screens
import 'features/onboarding/welcome_screen.dart';
import 'features/shell/home_shell.dart';
import 'features/auth/login_screen.dart';
import 'features/history/history_page.dart';
import 'features/profile/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // load saved theme preference (system / light / dark)
  await ThemeController.instance.load();

  // ❌ remove this – it was forcing you logged out every launch
  // await LocalAuth.instance.signOut();

  runApp(const StrikeProApp());
}

class StrikeProApp extends StatelessWidget {
  const StrikeProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'StrikePro',

          // light / dark themes
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeController.instance.mode,

          // 🔑 Let AuthGate decide where to start
          home: const AuthGate(),

          // named routes used in the app
          routes: {
            '/auth': (_) => const LoginScreen(),
            '/history': (_) => const HistoryPage(),
            '/profile': (_) => const ProfileScreen(),
          },
        );
      },
    );
  }
}

/// Decides what to show when the app launches.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<_AuthState> _load() async {
    final loggedIn = await LocalAuth.instance.isLoggedIn();
    final hasAcct  = await LocalAuth.instance.hasAccount();
    return _AuthState(loggedIn: loggedIn, hasAccount: hasAcct);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AuthState>(
      future: _load(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final s = snapshot.data!;

        if (s.loggedIn) {
          // ✅ already logged in -> go straight into the app
          return const HomeShell();
        }

        if (s.hasAccount) {
          // has account but logged out -> show login screen
          return const LoginScreen();
        }

        // first time user -> pretty welcome screen
        return const WelcomeScreen();
      },
    );
  }
}

class _AuthState {
  final bool loggedIn;
  final bool hasAccount;
  _AuthState({required this.loggedIn, required this.hasAccount});
}
