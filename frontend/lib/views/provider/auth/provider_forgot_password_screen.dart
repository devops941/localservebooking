import 'package:flutter/material.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';

class ProviderForgotPasswordScreen extends StatefulWidget {
  const ProviderForgotPasswordScreen({super.key});

  @override
  State<ProviderForgotPasswordScreen> createState() =>
      _ProviderForgotPasswordScreenState();
}

class _ProviderForgotPasswordScreenState
    extends State<ProviderForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  bool _isOtpSent = false;
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone_android_rounded, size: 40, color: Colors.teal),
              ),
              const SizedBox(height: 24),
              const Text(
                'Partner Account Recovery 🛠️',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your registered technician/service provider mobile number to receive an OTP.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
              ),
              const SizedBox(height: 28),
              CustomTextField(
                controller: _phoneController,
                labelText: 'Registered Mobile Number',
                hintText: 'e.g. +91 98401 23456',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              if (_isOtpSent) ...[
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _otpController,
                  labelText: 'Enter 6-Digit OTP',
                  hintText: 'e.g. 123456',
                  prefixIcon: Icons.lock_clock_outlined,
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 24),
              CustomButton(
                text: _isOtpSent ? 'Verify OTP & Reset Password' : 'Send SMS Verification Code',
                backgroundColor: Colors.teal,
                onPressed: () {
                  if (!_isOtpSent) {
                    setState(() => _isOtpSent = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('OTP sent to your mobile: 582419 (Demo)'), backgroundColor: Colors.teal),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Verification successful! Set new password.'), backgroundColor: Colors.green),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
