import 'package:flutter/material.dart';
import '../shared/role_selector_screen.dart';
import 'auth/provider_login_screen.dart';

class ProviderProfileScreen extends StatelessWidget {
  final bool isTab;

  const ProviderProfileScreen({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Provider Profile',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: isTab
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Provider Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(0xFF1E88E5).withValues(alpha: 0.12),
                        child: const Text(
                          'S',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
                        ),
                      ),
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.verified, size: 16, color: Color(0xFF1E88E5)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text(
                              'Suresh Kumar',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('Master Electrician', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            const Text('4.9 (142 reviews)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Verification & KYC Status
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.verified_user, color: Colors.green),
                    title: const Text('Identity & KYC Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Aadhaar & Police Verification Approved', style: TextStyle(fontSize: 12, color: Colors.green)),
                    trailing: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.badge_outlined, color: Color(0xFF1E88E5)),
                    title: const Text('Trade License & Certificate', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Govt. Wireman Class-B Certified', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.location_city_outlined, color: Colors.orange),
                    title: const Text('Operating Service Area', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Adyar, Besant Nagar, Thiruvanmiyur (5 km)', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Module Switcher Tile
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
              ),
              child: ListTile(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const RoleSelectorScreen()),
                    (route) => false,
                  );
                },
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.swap_horiz, color: Color(0xFF1E88E5)),
                ),
                title: const Text(
                  'Switch Module (Customer / Admin)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E88E5)),
                ),
                subtitle: const Text('Open Customer app or Admin Web View', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF1E88E5)),
              ),
            ),
            const SizedBox(height: 16),

            // Logout
            ListTile(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const ProviderLoginScreen()),
                  (route) => false,
                );
              },
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.red.shade100),
              ),
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Sign Out from Provider Account',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
