import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../admin_dashboard_screen.dart';
import '../../shared/auth_portal_screen.dart';
import 'admin_recovery_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@localserve.in');
  final _passwordController = TextEditingController(text: 'admin1234');
  final _securityPinController = TextEditingController(text: '9988');
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _securityPinController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final success = await AuthService().loginAdmin(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      securityPin: _securityPinController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid admin credentials or security PIN.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark slate web background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AuthPortalScreen()),
              );
            },
            icon: const Icon(Icons.swap_horiz, size: 18, color: Colors.white70),
            label: const Text('Other Portals', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B), // Card container
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E88E5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.security, color: Colors.white, size: 28),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.lock, color: Colors.redAccent, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'RESTRICTED ACCESS',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Admin Management Console',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Authorized system administrators only. All access attempts and administrative queries are logged and monitored.',
                    style: TextStyle(fontSize: 12, color: Colors.white60, height: 1.4),
                  ),
                  const SizedBox(height: 26),

                  // Admin Username
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Admin Username / Email',
                    hintText: 'admin@localserve.in',
                    prefixIcon: Icons.admin_panel_settings_outlined,
                    validator: (v) => v!.isEmpty ? 'Admin email required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Master Password',
                    hintText: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (v) => v!.length < 6 ? 'Password required' : null,
                  ),
                  const SizedBox(height: 16),

                  // 2FA Security Token
                  CustomTextField(
                    controller: _securityPinController,
                    labelText: 'Security Access Code / 2FA',
                    hintText: '9988',
                    prefixIcon: Icons.vpn_key_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminRecoveryScreen()),
                        );
                      },
                      child: const Text(
                        'Emergency Key Recovery',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  CustomButton(
                    text: 'Authenticate to Web Console',
                    isLoading: _isLoading,
                    backgroundColor: const Color(0xFF1E88E5),
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: 12),

                  CustomButton(
                    text: '1-Click Demo Admin Login',
                    isOutlined: true,
                    backgroundColor: Colors.white24,
                    textColor: Colors.white,
                    icon: Icons.shield_outlined,
                    onPressed: () {
                      AuthService().loginAdmin('admin@localserve.in', 'admin1234');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
