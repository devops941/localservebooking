import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/provider_service.dart';

class ProfileScreen extends StatelessWidget {
  final bool isTab;

  const ProfileScreen({super.key, this.isTab = false});

  void _showUpiEditDialog(BuildContext context, AuthService authService, String currentUpiId) {
    final ctrl = TextEditingController(text: currentUpiId);
    bool saving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('UPI ID', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your UPI ID so customers can pay you via UPI QR code.',
                style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'UPI ID (e.g. name@upi)',
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF00897B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF00897B)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: saving
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      setDialog(() => saving = true);
                      final result = await context.read<ProviderService>().updateUpiId(ctrl.text);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (result['success'] == true) {
                        await authService.refreshProfile();
                      }
                      messenger.showSnackBar(SnackBar(
                        content: Text(result['message'] ?? ''),
                        backgroundColor: result['success'] == true ? Colors.green : Colors.red,
                      ));
                    },
              child: saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        final user = authService.currentUser;
        final profile = authService.providerProfile;

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
                            backgroundColor: const Color(0xFF00897B).withValues(alpha: 0.12),
                            child: Icon(
                              user?.gender == 'female' ? Icons.face_retouching_natural : Icons.face,
                              size: 36,
                              color: const Color(0xFF00897B),
                            ),
                          ),
                          if (profile?.isVerified == true)
                            const Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.verified, size: 16, color: Color(0xFF00897B)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Provider',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            if (profile?.profession.isNotEmpty == true)
                              Text(
                                profile!.profession,
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                              ),
                            const SizedBox(height: 4),
                            if ((profile?.rating ?? 0) > 0)
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 14, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${profile!.rating.toStringAsFixed(1)} (${profile.reviewCount} reviews)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Contact Info
                Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email_outlined, color: Color(0xFF00897B)),
                        title: const Text('Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text(user?.email ?? '-', style: const TextStyle(fontSize: 12)),
                      ),
                      if (user?.phone.isNotEmpty == true) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.phone_outlined, color: Color(0xFF00897B)),
                          title: const Text('Phone', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Text(user!.phone, style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                      if (profile?.area.isNotEmpty == true) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.location_on_outlined, color: Colors.orange),
                          title: const Text('Service Area', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Text(
                            '${profile!.area}, ${profile.city}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF6366F1)),
                        title: const Text('UPI ID', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text(
                          (profile?.upiId.isNotEmpty == true) ? profile!.upiId : 'Not set — tap to add',
                          style: TextStyle(
                            fontSize: 12,
                            color: (profile?.upiId.isNotEmpty == true) ? null : Colors.orange,
                          ),
                        ),
                        trailing: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF00897B)),
                        onTap: () => _showUpiEditDialog(context, authService, profile?.upiId ?? ''),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Verification & KYC Status
                Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.verified_user,
                          color: profile?.isVerified == true ? Colors.green : Colors.orange,
                        ),
                        title: const Text(
                          'Identity & KYC Status',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Text(
                          profile?.isVerified == true
                              ? 'Verified — Approved by Admin'
                              : 'Pending — Under review',
                          style: TextStyle(
                            fontSize: 12,
                            color: profile?.isVerified == true ? Colors.green : Colors.orange,
                          ),
                        ),
                        trailing: Icon(
                          profile?.isVerified == true ? Icons.check_circle : Icons.hourglass_top,
                          color: profile?.isVerified == true ? Colors.green : Colors.orange,
                          size: 20,
                        ),
                      ),
                      if (profile != null) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.work_outline, color: Color(0xFF00897B)),
                          title: const Text(
                            'Experience & Rate',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          subtitle: Text(
                            '${profile.experienceYears} years experience • ₹${profile.hourlyRate.toStringAsFixed(0)}/hr',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Logout
                ListTile(
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Row(
                          children: [
                            Icon(Icons.logout, color: Colors.redAccent, size: 22),
                            SizedBox(width: 8),
                            Text('Sign Out', style: TextStyle(fontSize: 17)),
                          ],
                        ),
                        content: const Text(
                          'Are you sure you want to logout from your Provider Account?',
                          style: TextStyle(fontSize: 14, height: 1.4),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Yes, Logout'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await authService.logout();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    }
                  },
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.red.shade100),
                  ),
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text(
                    'Sign Out from Provider Account',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
