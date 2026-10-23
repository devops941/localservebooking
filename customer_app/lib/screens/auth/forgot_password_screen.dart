import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/auth_service.dart';
import '../../core/widgets/custom_textfield.dart';

// Steps: 0 = email, 1 = OTP, 2 = new password, 3 = success
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 0;
  bool _isLoading = false;

  // Step 0
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  // Step 1 — OTP boxes
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());
  int _resendCooldown = 0;
  Timer? _resendTimer;

  // Step 2
  final _pwFormKey = GlobalKey<FormState>();
  final _newPwController = TextEditingController();
  final _confirmPwController = TextEditingController();
  String _resetToken = '';

  @override
  void dispose() {
    _emailController.dispose();
    for (final c in _otpControllers) { c.dispose(); }
    for (final f in _otpFocusNodes) { f.dispose(); }
    _newPwController.dispose();
    _confirmPwController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  // ── Step 0: send OTP ──────────────────────────────────────────────────────
  Future<void> _sendOtp({bool resend = false}) async {
    if (!resend && !_emailFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final result = await AuthService().sendOtp(_emailController.text.trim());
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (result['success'] == true) {
      if (!resend) setState(() => _step = 1);
      _startResendCooldown();

      if (resend) {
        _showSnack('OTP resent to your email.', isError: false);
        for (final c in _otpControllers) { c.clear(); }
        _otpFocusNodes[0].requestFocus();
      }
    } else {
      _showSnack(result['message'] ?? 'Failed to send OTP.');
    }
  }

  // ── Step 1: verify OTP ────────────────────────────────────────────────────
  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      _showSnack('Please enter the complete 6-digit OTP.');
      return;
    }

    setState(() => _isLoading = true);
    final result = await AuthService().verifyOtp(_emailController.text.trim(), otp);
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (result['success'] == true) {
      _resetToken = result['resetToken'] as String;
      setState(() => _step = 2);
    } else {
      _showSnack(result['message'] ?? 'Incorrect OTP.');
    }
  }

  // ── Step 2: reset password ─────────────────────────────────────────────────
  Future<void> _resetPassword() async {
    if (!_pwFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final result = await AuthService().resetPassword(
      email: _emailController.text.trim(),
      resetToken: _resetToken,
      newPassword: _newPwController.text,
    );
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (result['success'] == true) {
      setState(() => _step = 3);
    } else {
      _showSnack(result['message'] ?? 'Password reset failed.');
    }
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendCooldown = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCooldown <= 1) {
        t.cancel();
        if (mounted) setState(() => _resendCooldown = 0);
      } else {
        if (mounted) setState(() => _resendCooldown--);
      }
    });
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.redAccent : const Color(0xFF1565C0),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── OTP box widget ────────────────────────────────────────────────────────
  Widget _otpBox(int index) {
    return SizedBox(
      width: 44,
      height: 52,
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A2340),
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFFF0F4F8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (val) {
          if (val.isNotEmpty && index < 5) {
            _otpFocusNodes[index + 1].requestFocus();
          }
          if (val.isEmpty && index > 0) {
            _otpFocusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  // ── Gradient button ───────────────────────────────────────────────────────
  Widget _gradientButton({required String label, required VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E88E5).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
        ),
      ),
    );
  }

  // ── Step indicator ────────────────────────────────────────────────────────
  Widget _stepIndicator() {
    if (_step >= 3) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final isActive = i == _step;
        final isDone = i < _step;
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 28 : 20,
              height: 20,
              decoration: BoxDecoration(
                color: isDone
                    ? const Color(0xFF1565C0)
                    : isActive
                        ? const Color(0xFF1565C0)
                        : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, size: 11, color: Colors.white)
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.white : Colors.grey,
                        ),
                      ),
              ),
            ),
            if (i < 2)
              Container(
                width: 28,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: i < _step ? const Color(0xFF1565C0) : const Color(0xFFE5E7EB),
              ),
          ],
        );
      }),
    );
  }

  // ── Step 0: Email ─────────────────────────────────────────────────────────
  Widget _buildEmailStep() {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Forgot Password?',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Color(0xFF1A2340)),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter your registered email and we\'ll send a 6-digit OTP to reset your password.',
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500, height: 1.4),
          ),
          const SizedBox(height: 22),
          CustomTextField(
            controller: _emailController,
            labelText: 'Registered Email',
            hintText: 'e.g. karthik@example.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Email is required';
              if (!val.contains('@')) return 'Enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 24),
          _gradientButton(
            label: 'Send OTP',
            onPressed: _isLoading ? null : () => _sendOtp(),
          ),
        ],
      ),
    );
  }

  // ── Step 1: OTP ───────────────────────────────────────────────────────────
  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verify Your Email',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Color(0xFF1A2340)),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500, height: 1.4),
            children: [
              const TextSpan(text: 'Enter the 6-digit OTP sent to '),
              TextSpan(
                text: _emailController.text.trim(),
                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1565C0)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, _otpBox),
        ),
        const SizedBox(height: 16),
        // Resend row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive it? ",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            _resendCooldown > 0
                ? Text(
                    'Resend in ${_resendCooldown}s',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  )
                : GestureDetector(
                    onTap: _isLoading ? null : () => _sendOtp(resend: true),
                    child: const Text(
                      'Resend OTP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
          ],
        ),
        const SizedBox(height: 24),
        _gradientButton(
          label: 'Verify OTP',
          onPressed: _isLoading ? null : _verifyOtp,
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _step = 0),
            child: Text(
              'Change email address',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
        ),
      ],
    );
  }

  // ── Step 2: New password ──────────────────────────────────────────────────
  Widget _buildNewPasswordStep() {
    return Form(
      key: _pwFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Set New Password',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Color(0xFF1A2340)),
          ),
          const SizedBox(height: 4),
          Text(
            'Create a strong password for your LocalServe account.',
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500, height: 1.4),
          ),
          const SizedBox(height: 22),
          CustomTextField(
            controller: _newPwController,
            labelText: 'New Password',
            hintText: 'Minimum 6 characters',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Password is required';
              if (val.length < 6) return 'Minimum 6 characters required';
              return null;
            },
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _confirmPwController,
            labelText: 'Confirm Password',
            hintText: 'Re-enter your password',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please confirm your password';
              if (val != _newPwController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 24),
          _gradientButton(
            label: 'Reset Password',
            onPressed: _isLoading ? null : _resetPassword,
          ),
        ],
      ),
    );
  }

  // ── Step 3: Success ───────────────────────────────────────────────────────
  Widget _buildSuccessStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_outline_rounded, size: 56, color: Colors.green),
        ),
        const SizedBox(height: 20),
        const Text(
          'Password Reset!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A2340)),
        ),
        const SizedBox(height: 8),
        Text(
          'Your password has been updated successfully.\nYou can now sign in with your new password.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.5),
        ),
        const SizedBox(height: 28),
        _gradientButton(
          label: 'Back to Sign In',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF2F6FB),
      body: Column(
        children: [
          // Compact header with back button
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account Recovery',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _stepIndicator(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Card
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: switch (_step) {
                      0 => _buildEmailStep(),
                      1 => _buildOtpStep(),
                      2 => _buildNewPasswordStep(),
                      _ => _buildSuccessStep(),
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
