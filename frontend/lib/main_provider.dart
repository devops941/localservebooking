import 'package:flutter/material.dart';
import 'views/provider/auth/provider_forgot_password_screen.dart';
import 'views/provider/auth/provider_kyc_pending_screen.dart';
import 'views/provider/auth/provider_login_screen.dart';
import 'views/provider/auth/provider_register_screen.dart';
import 'views/provider/provider_earnings_screen.dart';
import 'views/provider/provider_home_screen.dart';
import 'views/provider/provider_jobs_screen.dart';
import 'views/provider/provider_profile_screen.dart';
import 'views/provider/provider_requests_screen.dart';
import 'views/provider/provider_services_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderApp());
}

class ProviderApp extends StatelessWidget {
  const ProviderApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF00897B);

    return MaterialApp(
      title: 'ServeLocal – Provider',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryTeal,
          primary: primaryTeal,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1F2937),
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          color: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryTeal,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ProviderLoginScreen(),
        '/register': (context) => const ProviderRegisterScreen(),
        '/kyc_pending': (context) => const ProviderKycPendingScreen(),
        '/forgot_password': (context) => const ProviderForgotPasswordScreen(),
        '/home': (context) => const ProviderHomeScreen(),
        '/requests': (context) => const ProviderRequestsScreen(),
        '/jobs': (context) => const ProviderJobsScreen(),
        '/earnings': (context) => const ProviderEarningsScreen(),
        '/services': (context) => const ProviderServicesScreen(),
        '/profile': (context) => const ProviderProfileScreen(),
      },
    );
  }
}
