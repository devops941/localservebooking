import 'package:flutter/material.dart';
import 'views/admin/admin_analytics_screen.dart';
import 'views/admin/admin_bookings_screen.dart';
import 'views/admin/admin_categories_screen.dart';
import 'views/admin/admin_dashboard_screen.dart';
import 'views/admin/admin_users_screen.dart';
import 'views/admin/admin_verifications_screen.dart';
import 'views/admin/auth/admin_login_screen.dart';
import 'views/admin/auth/admin_recovery_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryDark = Color(0xFF0F172A);

    return MaterialApp(
      title: 'ServeLocal – Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryDark,
          primary: primaryDark,
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
            backgroundColor: primaryDark,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AdminLoginScreen(),
        '/recovery': (context) => const AdminRecoveryScreen(),
        '/dashboard': (context) => const AdminDashboardScreen(),
        '/users': (context) => const AdminUsersScreen(),
        '/verifications': (context) => const AdminVerificationsScreen(),
        '/categories': (context) => const AdminCategoriesScreen(),
        '/bookings': (context) => const AdminBookingsScreen(),
        '/analytics': (context) => const AdminAnalyticsScreen(),
      },
    );
  }
}
