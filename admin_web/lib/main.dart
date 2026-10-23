import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/auth_service.dart';
import 'core/services/admin_service.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/shell/admin_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => AdminService()),
      ],
      child: const AdminWebApp(),
    ),
  );
}

class AdminWebApp extends StatelessWidget {
  const AdminWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LocalServe Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const AdminShell(initialIndex: 0),
        '/users': (context) => const AdminShell(initialIndex: 1),
        '/verifications': (context) => const AdminShell(initialIndex: 2),
        '/bookings': (context) => const AdminShell(initialIndex: 3),
        '/categories': (context) => const AdminShell(initialIndex: 4),
        '/analytics': (context) => const AdminShell(initialIndex: 5),
      },
    );
  }
}
