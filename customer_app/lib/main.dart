import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/auth_service.dart';
import 'core/services/category_service.dart';
import 'core/services/provider_service.dart';
import 'core/services/booking_service.dart';
import 'core/services/notification_service.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/categories/categories_screen.dart';
import 'screens/providers/provider_list_screen.dart';
import 'screens/providers/provider_details_screen.dart';
import 'screens/bookings/booking_screen.dart';
import 'screens/bookings/my_bookings_screen.dart';
import 'screens/bookings/booking_details_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/areas/area_selection_screen.dart';
import 'screens/map/booking_map_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => CategoryService()),
        ChangeNotifierProvider(create: (_) => ProviderService()),
        ChangeNotifierProvider(create: (_) => BookingService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
      ],
      child: const CustomerApp(),
    ),
  );
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LocalServe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const SplashScreen(),
            );
          case '/login':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const LoginScreen(),
            );
          case '/register':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const RegisterScreen(),
            );
          case '/forgot_password':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const ForgotPasswordScreen(),
            );
          case '/home':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const HomeScreen(),
            );
          case '/categories':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const CategoriesScreen(),
            );
          case '/providers':
            final args = settings.arguments;
            String? categoryId;
            String? categoryName;
            if (args is Map<String, dynamic>) {
              categoryId = args['categoryId'] as String?;
              categoryName = args['categoryName'] as String?;
            }
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => ProviderListScreen(
                categoryId: categoryId,
                categoryName: categoryName,
              ),
            );
          case '/provider_details':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const ProviderDetailsScreen(),
            );
          case '/booking':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const BookingScreen(),
            );
          case '/bookings':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const MyBookingsScreen(),
            );
          case '/booking_details':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const BookingDetailsScreen(),
            );
          case '/profile':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const ProfileScreen(),
            );
          case '/areas':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const AreaSelectionScreen(),
            );
          case '/map':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const BookingMapScreen(),
            );
          case '/notifications':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const NotificationsScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const SplashScreen(),
            );
        }
      },
    );
  }
}
