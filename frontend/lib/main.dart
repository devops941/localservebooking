import 'package:flutter/material.dart';
import 'views/admin/admin_analytics_screen.dart';
import 'views/admin/admin_bookings_screen.dart';
import 'views/admin/admin_categories_screen.dart';
import 'views/admin/admin_dashboard_screen.dart';
import 'views/admin/admin_users_screen.dart';
import 'views/admin/admin_verifications_screen.dart';
import 'views/admin/auth/admin_login_screen.dart';
import 'views/admin/auth/admin_recovery_screen.dart';
import 'views/shared/auth_portal_screen.dart';
import 'views/customer/auth/customer_forgot_password_screen.dart';
import 'views/customer/auth/customer_login_screen.dart';
import 'views/customer/auth/customer_register_screen.dart';
import 'views/provider/auth/provider_forgot_password_screen.dart';
import 'views/provider/auth/provider_kyc_pending_screen.dart';
import 'views/provider/auth/provider_login_screen.dart';
import 'views/provider/auth/provider_register_screen.dart';
import 'views/shared/splash_screen.dart';
import 'views/customer/area_selection_screen.dart';
import 'views/customer/category_screen.dart';
import 'views/customer/customer_home_screen.dart';
import 'views/customer/customer_profile_screen.dart';
import 'views/customer/my_addresses_screen.dart';
import 'views/customer/my_bookings_screen.dart';
import 'views/provider/provider_earnings_screen.dart';
import 'views/provider/provider_home_screen.dart';
import 'views/provider/provider_jobs_screen.dart';
import 'views/provider/provider_profile_screen.dart';
import 'views/provider/provider_requests_screen.dart';
import 'views/provider/provider_services_screen.dart';
import 'views/shared/role_selector_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LocalServiceApp());
}

class LocalServiceApp extends StatelessWidget {
  const LocalServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1E88E5);

    return MaterialApp(
      title: 'Local Service Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
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
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/select_role': (context) => const RoleSelectorScreen(),
        '/auth_portal': (context) => const AuthPortalScreen(),

        // Common / Legacy Auth routes
        '/login': (context) => const CustomerLoginScreen(),
        '/register': (context) => const CustomerRegisterScreen(),
        '/forgot_password': (context) => const CustomerForgotPasswordScreen(),

        // Module 1: Customer Auth
        '/customer_login': (context) => const CustomerLoginScreen(),
        '/customer_register': (context) => const CustomerRegisterScreen(),
        '/customer_forgot_password': (context) => const CustomerForgotPasswordScreen(),

        // Module 2: Service Provider Auth
        '/provider_login': (context) => const ProviderLoginScreen(),
        '/provider_register': (context) => const ProviderRegisterScreen(),
        '/provider_kyc_pending': (context) => const ProviderKycPendingScreen(),
        '/provider_forgot_password': (context) => const ProviderForgotPasswordScreen(),

        // Module 3: Admin Web Auth
        '/admin_login': (context) => const AdminLoginScreen(),
        '/admin_recovery': (context) => const AdminRecoveryScreen(),

        // Customer Module
        '/home': (context) => const CustomerHomeScreen(),
        '/categories': (context) => const CategoryScreen(),
        '/areas': (context) => const AreaSelectionScreen(),
        '/bookings': (context) => const MyBookingsScreen(),
        '/addresses': (context) => const MyAddressesScreen(),
        '/profile': (context) => const CustomerProfileScreen(),

        // Service Provider Module
        '/provider_home': (context) => const ProviderHomeScreen(),
        '/provider_requests': (context) => const ProviderRequestsScreen(),
        '/provider_jobs': (context) => const ProviderJobsScreen(),
        '/provider_earnings': (context) => const ProviderEarningsScreen(),
        '/provider_services': (context) => const ProviderServicesScreen(),
        '/provider_profile': (context) => const ProviderProfileScreen(),

        // Admin Module (Web View)
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/admin_users': (context) => const AdminUsersScreen(),
        '/admin_verifications': (context) => const AdminVerificationsScreen(),
        '/admin_categories': (context) => const AdminCategoriesScreen(),
        '/admin_bookings': (context) => const AdminBookingsScreen(),
        '/admin_analytics': (context) => const AdminAnalyticsScreen(),
      },
    );
  }
}
