import 'package:flutter/material.dart';
import '../admin/auth/admin_login_screen.dart';
import '../customer/auth/customer_login_screen.dart';
import '../provider/auth/provider_login_screen.dart';

class AuthPortalScreen extends StatelessWidget {
  const AuthPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Choose Authentication Portal',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sign In to Your Module',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 6),
              Text(
                'Select your role to access your dedicated login & registration portal:',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),

              // Portal 1: Customer
              _buildPortalCard(
                context: context,
                badge: 'MODULE 1 • CUSTOMER AUTH',
                badgeColor: const Color(0xFF1E88E5),
                title: 'Customer Sign In & Sign Up',
                description: 'For homeowners looking to book verified electricians, plumbers, and home cleaning services.',
                icon: Icons.person_pin_circle_outlined,
                iconColor: const Color(0xFF1E88E5),
                targetScreen: const CustomerLoginScreen(),
              ),
              const SizedBox(height: 16),

              // Portal 2: Service Provider
              _buildPortalCard(
                context: context,
                badge: 'MODULE 2 • SERVICE PROVIDER AUTH',
                badgeColor: Colors.teal,
                title: 'Service Partner Portal',
                description: 'For trade professionals and technicians. Access job requests, daily earnings, or register new trade services.',
                icon: Icons.handyman_outlined,
                iconColor: Colors.teal,
                targetScreen: const ProviderLoginScreen(),
              ),
              const SizedBox(height: 16),

              // Portal 3: Admin Web View
              _buildPortalCard(
                context: context,
                badge: 'MODULE 3 • ADMIN CONSOLE AUTH',
                badgeColor: const Color(0xFF0F172A),
                title: 'Admin Web Console',
                description: 'Restricted access for platform administrators to review KYC documents, monitor revenue & manage users.',
                icon: Icons.admin_panel_settings_outlined,
                iconColor: const Color(0xFF0F172A),
                targetScreen: const AdminLoginScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortalCard({
    required BuildContext context,
    required String badge,
    required Color badgeColor,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Widget targetScreen,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetScreen),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: badgeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Open Sign In Screen',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14, color: iconColor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
