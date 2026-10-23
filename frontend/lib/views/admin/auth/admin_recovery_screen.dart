import 'package:flutter/material.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';

class AdminRecoveryScreen extends StatefulWidget {
  const AdminRecoveryScreen({super.key});

  @override
  State<AdminRecoveryScreen> createState() => _AdminRecoveryScreenState();
}

class _AdminRecoveryScreenState extends State<AdminRecoveryScreen> {
  final _recoveryKeyCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();

  @override
  void dispose() {
    _recoveryKeyCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.emergency_outlined, color: Colors.redAccent, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Emergency Console Recovery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Root Administrator Access', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Enter the 32-character Master Recovery Key issued during initial server deployment.',
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _recoveryKeyCtrl,
                  labelText: 'Master Recovery Key',
                  hintText: 'e.g. LS-ADM-KEY-9988-7766-5544',
                  prefixIcon: Icons.vpn_key_outlined,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _newPassCtrl,
                  labelText: 'New Master Password',
                  hintText: 'Enter new secure password',
                  prefixIcon: Icons.lock_reset,
                  isPassword: true,
                ),
                const SizedBox(height: 28),
                CustomButton(
                  text: 'Override & Reset Admin Credentials',
                  backgroundColor: Colors.redAccent,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Root credentials updated successfully! Sign in to console.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
