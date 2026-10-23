import 'package:flutter/material.dart';
import 'views/customer/auth/customer_forgot_password_screen.dart';
import 'views/customer/auth/customer_login_screen.dart';
import 'views/customer/auth/customer_register_screen.dart';
import 'views/customer/area_selection_screen.dart';
import 'views/customer/category_screen.dart';
import 'views/customer/customer_home_screen.dart';
import 'views/customer/customer_profile_screen.dart';
import 'views/customer/my_addresses_screen.dart';
import 'views/customer/my_bookings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1E88E5);

    return MaterialApp(
      title: 'ServeLocal – Customer',
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const CustomerLoginScreen(),
        '/register': (context) => const CustomerRegisterScreen(),
        '/forgot_password': (context) => const CustomerForgotPasswordScreen(),
        '/home': (context) => const CustomerHomeScreen(),
        '/categories': (context) => const CategoryScreen(),
        '/areas': (context) => const AreaSelectionScreen(),
        '/bookings': (context) => const MyBookingsScreen(),
        '/addresses': (context) => const MyAddressesScreen(),
        '/profile': (context) => const CustomerProfileScreen(),
      },
    );
  }
}
