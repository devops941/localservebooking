import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/auth_service.dart';
import 'core/services/provider_service.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/kyc_pending_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/requests/requests_screen.dart';
import 'screens/jobs/jobs_screen.dart';
import 'screens/earnings/earnings_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/reviews/reviews_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ProviderService()),
      ],
      child: const ProviderApp(),
    ),
  );
}

class ProviderApp extends StatelessWidget {
  const ProviderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LocalServe Partner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/kyc_pending': (context) => const KycPendingScreen(),
        '/home': (context) => const HomeScreen(),
        '/requests': (context) => const RequestsScreen(),
        '/jobs': (context) => const JobsScreen(),
        '/earnings': (context) => const EarningsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/reviews': (context) => const ReviewsScreen(),
        '/services': (context) => const ReviewsScreen(),
      },
    );
  }
}
