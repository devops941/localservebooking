import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/responsive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final authService = context.read<AuthService>();
    final success = await authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (success) {
      final profile = authService.providerProfile;
      if (profile != null && profile.isVerified) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/kyc_pending');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              authService.errorMessage ?? 'Login failed. Please try again.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF00897B),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Compact green header ──
              Padding(
                padding: EdgeInsets.fromLTRB(
                    context.sw * 0.06, 14, context.sw * 0.06, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand row
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.handyman_rounded,
                              color: Color(0xFF00897B),
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('LocalServe',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: context.rsp(15),
                                    fontWeight: FontWeight.bold)),
                            Text('Partner Portal',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: context.rsp(11))),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Welcome Back,\nPartner!',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: context.rsp(24),
                            fontWeight: FontWeight.bold,
                            height: 1.2)),
                    const SizedBox(height: 6),
                    Text('Sign in to manage your bookings & earnings',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: context.rsp(12))),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // ── Bottom white sheet ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F4),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        context.sw * 0.05, 22, context.sw * 0.05, 0),
                    child: Column(
                      children: [
                        // ── Sign In card ──
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(context.sw * 0.055),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.07),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Card header
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00897B)
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                          Icons.lock_person_outlined,
                                          color: Color(0xFF00897B),
                                          size: 18),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Sign In',
                                            style: TextStyle(
                                                fontSize: context.rsp(16),
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    const Color(0xFF1F2937))),
                                        Text('Enter your credentials',
                                            style: TextStyle(
                                                fontSize: context.rsp(11),
                                                color: Colors.grey.shade500)),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Email field
                                _field(
                                  controller: _emailController,
                                  label: 'Partner Email',
                                  hint: 'your@email.com',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Email is required';
                                    }
                                    if (!v.contains('@')) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),

                                // Password field
                                _field(
                                  controller: _passwordController,
                                  label: 'Password',
                                  hint: 'Enter your password',
                                  icon: Icons.lock_outline,
                                  obscureText: _obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.grey.shade400,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (v.length < 6) {
                                      return 'Minimum 6 characters';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Sign In button
                                SizedBox(
                                  width: double.infinity,
                                  height: context.rpx(50),
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00897B),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.login_rounded,
                                                  size: 18),
                                              const SizedBox(width: 8),
                                              Text(
                                                  'Sign In to Partner Portal',
                                                  style: TextStyle(
                                                      fontSize:
                                                          context.rsp(14),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.2)),
                                            ],
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Register link
                                Center(
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    children: [
                                      Text('New here? ',
                                          style: TextStyle(
                                              fontSize: context.rsp(13),
                                              color: Colors.grey.shade600)),
                                      GestureDetector(
                                        onTap: () => Navigator.pushNamed(
                                            context, '/register'),
                                        child: Text('Join as Partner',
                                            style: TextStyle(
                                                fontSize: context.rsp(13),
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    const Color(0xFF00897B))),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Why join row ──
                        Row(
                          children: [
                            _whyItem(Icons.calendar_today_outlined,
                                'Manage\nBookings'),
                            _whyItem(Icons.account_balance_wallet_outlined,
                                'Instant\nPayouts'),
                            _whyItem(
                                Icons.trending_up_outlined, 'Grow Your\nBase'),
                          ],
                        ),

                        const SizedBox(height: 20),

                        SafeArea(
                          top: false,
                          child: Text(
                            'LocalServe © 2025 · Trusted by professionals',
                            style: TextStyle(
                                fontSize: context.rsp(11),
                                color: Colors.grey.shade400),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _whyItem(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child:
                Icon(icon, size: 20, color: const Color(0xFF00897B)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: context.rsp(11),
                color: Colors.grey.shade600,
                height: 1.3,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(
          fontSize: context.rsp(14), color: const Color(0xFF1F2937)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade400),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF6F8F7),
        labelStyle: TextStyle(
            fontSize: context.rsp(13), color: Colors.grey.shade500),
        hintStyle: TextStyle(
            fontSize: context.rsp(13), color: Colors.grey.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00897B), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
    );
  }
}
