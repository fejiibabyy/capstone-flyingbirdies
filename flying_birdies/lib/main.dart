import 'package:flutter/material.dart';
import 'features/onboarding/welcome_screen.dart';
import 'features/shell/home_shell.dart';
import 'features/auth/login_screen.dart';
import 'services/local_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 TEMP RESET for development
  await LocalAuth.instance.signOut();  // clears any saved login (use once while testing)

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
      home: startLoggedIn
          ? const HomeShell()
          : const WelcomeScreen(),
    );
  }
}
