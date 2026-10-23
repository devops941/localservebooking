import 'package:flutter/material.dart';
import '../admin/admin_dashboard_screen.dart';
import '../admin/auth/admin_login_screen.dart';
import 'auth_portal_screen.dart';
import '../customer/auth/customer_login_screen.dart';
import '../provider/auth/provider_login_screen.dart';
import '../customer/customer_home_screen.dart';
import '../provider/provider_home_screen.dart';

class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Select Application Module',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Authentication Portals',
            icon: const Icon(Icons.lock_outline, color: Color(0xFF1E88E5)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AuthPortalScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Authentication Hub Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E88E5).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.admin_panel_settings, color: Color(0xFF60A5FA), size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '3-Module Auth Portals',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Customer • Service Partner • Admin Web',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Dedicated authentication flows with login, registration, password recovery, and partner KYC onboarding.',
                      style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AuthPortalScreen()),
                          );
                        },
                        icon: const Icon(Icons.login_rounded, size: 18),
                        label: const Text('Open 3-Module Auth Hub', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Explore Live Application Modules',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose a module to launch its main dashboard or sign-in portal:',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              // Module 1: Customer Module
              _buildModuleCard(
                context: context,
                badge: 'MODULE 1 • MOBILE APP',
                badgeColor: const Color(0xFF1E88E5),
                title: 'Customer Experience',
                subtitle:
                    'Browse 8+ service categories, find local verified electricians/plumbers, book slots, live track job, view bills & leave reviews.',
                icon: Icons.person_pin_circle_outlined,
                iconColor: const Color(0xFF1E88E5),
                features: ['Location & Area selection', 'Search & Category grid', 'Booking with date/time slots', 'My Bookings tracker & reviews'],
                onLaunch: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
                  );
                },
                onAuth: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomerLoginScreen()),
                  );
                },
              ),
              const SizedBox(height: 18),

              // Module 2: Service Provider Module
              _buildModuleCard(
                context: context,
                badge: 'MODULE 2 • MOBILE APP',
                badgeColor: Colors.teal,
                title: 'Service Provider Portal',
                subtitle:
                    'For electricians, plumbers & technicians. Toggle online availability, accept/decline requests, advance job status, and withdraw earnings.',
                icon: Icons.handyman_outlined,
                iconColor: Colors.teal,
                features: ['Online/Offline live toggle', 'Incoming requests (Accept/Decline)', 'Active job lifecycle stepper', 'Wallet balance & bank withdrawal'],
                onLaunch: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProviderHomeScreen()),
                  );
                },
                onAuth: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProviderLoginScreen()),
                  );
                },
              ),
              const SizedBox(height: 18),

              // Module 3: Admin Module
              _buildModuleCard(
                context: context,
                badge: 'MODULE 3 • WEB VIEW',
                badgeColor: const Color(0xFF0F172A),
                title: 'Admin Web Portal',
                subtitle:
                    'Responsive Web View dashboard. Monitor platform gross GMV, review provider KYC documents, manage service catalog & view all bookings.',
                icon: Icons.admin_panel_settings_outlined,
                iconColor: const Color(0xFF0F172A),
                features: ['Dark slate web sidebar layout', 'Financial KPIs & Commission (15%)', 'Provider KYC review queue', 'Platform bookings & User control'],
                onLaunch: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                  );
                },
                onAuth: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required BuildContext context,
    required String badge,
    required Color badgeColor,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required List<String> features,
    required VoidCallback onLaunch,
    required VoidCallback onAuth,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: badgeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ...features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 16, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        f,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: iconColor,
                      side: BorderSide(color: iconColor.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: onAuth,
                    icon: const Icon(Icons.lock_open, size: 16),
                    label: const Text('Auth / Login', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: iconColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: onLaunch,
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Direct App', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
