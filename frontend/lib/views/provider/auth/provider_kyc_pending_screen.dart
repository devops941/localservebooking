import 'package:flutter/material.dart';
import '../../../core/widgets/custom_button.dart';
import '../provider_home_screen.dart';

class ProviderKycPendingScreen extends StatelessWidget {
  final String providerName;
  final String profession;

  const ProviderKycPendingScreen({
    super.key,
    this.providerName = 'Service Professional',
    this.profession = 'Electrician',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Partner Verification Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.hourglass_top_rounded, color: Colors.amber, size: 48),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Application Under Review ⏳',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 10),
              Text(
                'Thank you for registering with LocalServe, $providerName!\nYour $profession documents have been submitted to our team.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
              ),
              const SizedBox(height: 28),
              // Checklist
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildCheckItem('Basic Profile & Contact Details', true),
                    const Divider(height: 16),
                    _buildCheckItem('Trade Experience & Base Rate Card', true),
                    const Divider(height: 16),
                    _buildCheckItem('Government ID / Aadhaar Upload', true),
                    const Divider(height: 16),
                    _buildCheckItem('Admin Background & Police Clearance', false),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Verification usually completes within 24 to 48 hours.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const Spacer(),
              // Demo shortcut to test provider dashboard
              CustomButton(
                text: 'Simulate Admin Approval & Enter Portal',
                icon: Icons.check_circle_outline,
                backgroundColor: Colors.teal,
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const ProviderHomeScreen()),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Return to Login',
                isOutlined: true,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem(String title, bool isDone) {
    return Row(
      children: [
        Icon(
          isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 18,
          color: isDone ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
              color: isDone ? Colors.black87 : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
