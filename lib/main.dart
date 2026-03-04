import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/user.dart';
import 'screens/auth_screen.dart';
import 'screens/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env', isOptional: true);
  runApp(const MyMetrQuotApp());
}

class MyMetrQuotApp extends StatelessWidget {
  const MyMetrQuotApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1976D2),
      primary: const Color(0xFF1976D2),
      secondary: const Color(0xFFFFC107),
      surface: const Color(0xFFF5F5F5),
    );

    final textTheme = GoogleFonts.robotoTextTheme().copyWith(
      headlineLarge: GoogleFonts.roboto(fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.roboto(fontWeight: FontWeight.bold),
      headlineSmall: GoogleFonts.roboto(fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.roboto(fontWeight: FontWeight.bold),
      bodyLarge: GoogleFonts.roboto(fontWeight: FontWeight.w400),
      bodyMedium: GoogleFonts.roboto(fontWeight: FontWeight.w400),
    );

    return MaterialApp(
      title: 'mymetrquot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        textTheme: textTheme.apply(
          bodyColor: const Color(0xFF212121),
          displayColor: const Color(0xFF212121),
        ),
      ),
      home: const AppEntryPoint(),
    );
  }
}

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  User? _authenticatedUser;

  void _onAuthCompleted(User user) {
    setState(() {
      _authenticatedUser = user;
    });
  }

  void _logout() {
    setState(() {
      _authenticatedUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
        ).animate(animation);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offsetAnimation, child: child),
        );
      },
      child: _authenticatedUser != null
          ? HomeShell(
              key: const ValueKey('home-shell'),
              user: _authenticatedUser!,
              onLogout: _logout,
            )
          : AuthScreen(
              key: const ValueKey('auth-screen'),
              onAuthenticated: _onAuthCompleted,
            ),
    );
  }
}
