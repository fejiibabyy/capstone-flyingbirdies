import 'package:flutter/material.dart';
import 'features/onboarding/welcome_screen.dart';
import 'features/shell/home_shell.dart';
import 'features/auth/login_screen.dart';
import 'features/history/history_page.dart';
import 'features/profile/profile_screen.dart';
import 'services/local_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TEMP: remove when you’re done testing login flow
  await LocalAuth.instance.signOut();

  final loggedIn = await LocalAuth.instance.isLoggedIn();
  runApp(StrikeProApp(startLoggedIn: loggedIn));
}

class StrikeProApp extends StatelessWidget {
  const StrikeProApp({super.key, required this.startLoggedIn});
  final bool startLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StrikePro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: startLoggedIn ? const HomeShell() : const WelcomeScreen(),
      routes: {
        '/auth': (_) => const LoginScreen(),
        '/history': (_) => const HistoryPage(),
        '/profile': (_) => const ProfileScreen(),
      },
    );
  }
}
