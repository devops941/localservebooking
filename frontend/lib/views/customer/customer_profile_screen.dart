import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import 'auth/customer_login_screen.dart';
import '../shared/role_selector_screen.dart';
import 'my_addresses_screen.dart';
import 'my_bookings_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  final bool isTab;

  const CustomerProfileScreen({super.key, this.isTab = false});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final authService = AuthService();

  void _openEditProfileSheet() {
    final user = authService.currentUser;
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: nameCtrl,
              labelText: 'Full Name',
              hintText: 'Enter your name',
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: phoneCtrl,
              labelText: 'Phone Number',
              hintText: 'Enter phone number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Save Changes',
              onPressed: () {
                authService.updateProfile(
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out from your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              authService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const CustomerLoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: widget.isTab
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(0xFF1E88E5).withValues(alpha: 0.12),
                    child: Text(
                      user != null && user.name.isNotEmpty ? user.name[0] : 'U',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E88E5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Guest User',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user?.phone ?? '+91 98765 43210',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                        Text(
                          user?.email ?? 'user@example.com',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFF1E88E5)),
                    onPressed: _openEditProfileSheet,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Options Section
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.location_on_outlined,
                    title: 'Saved Addresses',
                    subtitle: '${user?.addresses.length ?? 0} addresses saved',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyAddressesScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileTile(
                    icon: Icons.calendar_today_outlined,
                    title: 'My Bookings & History',
                    subtitle: 'View active and past bookings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyBookingsScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileTile(
                    icon: Icons.payment_outlined,
                    title: 'Payment Methods',
                    subtitle: 'Cash, UPI & Saved Cards',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Payment methods management coming soon.')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileTile(
                    icon: Icons.notifications_none_outlined,
                    title: 'Notification Preferences',
                    subtitle: 'Manage SMS & Push reminders',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Help & App Info
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.support_agent_outlined,
                    title: 'Customer Support & Helpdesk',
                    subtitle: '24/7 Support assistance',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contact support: support@localserve.in')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileTile(
                    icon: Icons.security_outlined,
                    title: 'Privacy Policy & Terms',
                    subtitle: 'App terms of service',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildProfileTile(
                    icon: Icons.swap_horiz_rounded,
                    title: 'Switch Module / Portal',
                    subtitle: 'Switch to Service Provider or Admin Web View',
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const RoleSelectorScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Logout Button
            ListTile(
              onTap: _handleLogout,
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.red.shade100),
              ),
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.redAccent),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E88E5).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF1E88E5), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }
}
