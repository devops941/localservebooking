import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final bool isTab;

  const ProfileScreen({super.key, this.isTab = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ── Logout ──────────────────────────────────────────────────────────────────

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
            SizedBox(width: 8),
            Text('Sign Out', style: TextStyle(fontSize: 17)),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout from your account?',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthService>().logout();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            child: const Text('Yes, Logout'),
          ),
        ],
      ),
    );
  }

  // ── Payment Methods ─────────────────────────────────────────────────────────

  void _showPaymentMethodsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            const SizedBox(height: 12),
            _sheetTitle(ctx, 'Payment Methods'),
            Text('Accepted payment modes for LocalServe services',
                style:
                    TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(height: 20),
            _buildPaymentOption(Icons.money_rounded, Colors.green,
                'Cash on Delivery',
                'Pay the provider directly after service completion.',
                isActive: true),
            const Divider(height: 24),
            _buildPaymentOption(
                Icons.account_balance_wallet_outlined, Colors.indigo,
                'UPI (GPay / PhonePe)',
                'Scan provider\'s QR code via any UPI app.',
                isActive: true),
            const Divider(height: 24),
            _buildPaymentOption(Icons.credit_card_outlined, Colors.purple,
                'Credit / Debit Cards', 'Card payment — coming soon.',
                isActive: false),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: Color(0xFF1E88E5)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pay via Cash or scan the provider\'s UPI QR code using GPay / PhonePe after job completion.',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF1565C0)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
      IconData icon, Color color, String title, String sub,
      {required bool isActive}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isActive ? 0.12 : 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon,
              color: isActive ? color : Colors.grey.shade400, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? const Color(0xFF1F2937)
                        : Colors.grey.shade500,
                  )),
              Text(sub,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ),
        if (isActive)
          const Icon(Icons.check_circle_rounded,
              color: Colors.green, size: 20)
        else
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('Soon',
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }

  // ── Notifications ───────────────────────────────────────────────────────────

  void _showNotificationsSheet() {
    bool notifyBookings = true;
    bool notifyUpdates = true;
    bool notifyPromo = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHandle(),
              const SizedBox(height: 12),
              _sheetTitle(ctx, 'Notifications'),
              Text('Control which notifications you receive',
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade500)),
              const SizedBox(height: 20),
              _buildNotifTile(
                'Booking Confirmations',
                'Alerts when your booking is confirmed or updated',
                Icons.calendar_today_outlined,
                Colors.teal,
                notifyBookings,
                (v) => setSheet(() => notifyBookings = v),
              ),
              const Divider(height: 20),
              _buildNotifTile(
                'Provider Updates',
                'Know when your provider is on the way',
                Icons.directions_run_rounded,
                Colors.orange,
                notifyUpdates,
                (v) => setSheet(() => notifyUpdates = v),
              ),
              const Divider(height: 20),
              _buildNotifTile(
                'Offers & Promotions',
                'Exclusive deals and seasonal offers',
                Icons.local_offer_outlined,
                Colors.purple,
                notifyPromo,
                (v) => setSheet(() => notifyPromo = v),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotifTile(String title, String sub, IconData icon, Color color,
      bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              Text(sub,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: const Color(0xFF1E88E5),
          activeThumbColor: Colors.white,
        ),
      ],
    );
  }

  // ── Customer Support ────────────────────────────────────────────────────────

  void _showSupportSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            const SizedBox(height: 12),
            _sheetTitle(ctx, 'Customer Support'),
            Text("We're here to help! Reach us anytime.",
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(height: 20),
            _buildContactCard(
              icon: Icons.email_outlined,
              iconColor: Colors.white,
              bgColor: const Color(0xFF1E88E5),
              containerColor: Colors.blue.shade50,
              borderColor: Colors.blue.shade100,
              title: 'Email Support',
              subtitle: 'support@localserve.in',
              subtitleColor: const Color(0xFF1E88E5),
              onTap: () async {
                final uri = Uri(
                  scheme: 'mailto',
                  path: 'support@localserve.in',
                  queryParameters: {
                    'subject': 'LocalServe Customer Support'
                  },
                );
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
            ),
            const SizedBox(height: 10),
            _buildContactCard(
              icon: Icons.phone_outlined,
              iconColor: Colors.white,
              bgColor: Colors.green,
              containerColor: Colors.green.shade50,
              borderColor: Colors.green.shade100,
              title: 'Call Support',
              subtitle: '+91 98765 43210  •  Mon–Sat, 9am–6pm',
              subtitleColor: Colors.green.shade700,
              onTap: () async {
                final uri =
                    Uri(scheme: 'tel', path: '+919876543210');
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
            ),
            const SizedBox(height: 14),
            Text('Average email response time: within 24 hours.',
                style: TextStyle(
                    fontSize: 11, color: Colors.grey.shade400),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color containerColor,
    required Color borderColor,
    required String title,
    required String subtitle,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12, color: subtitleColor)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade400, size: 22),
          ],
        ),
      ),
    );
  }

  // ── Privacy Policy ──────────────────────────────────────────────────────────

  void _showPrivacyPolicySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scroll) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
              child: Column(
                children: [
                  _sheetHandle(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Privacy Policy & Terms',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  Text('Last updated: October 2025',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400)),
                  const SizedBox(height: 16),
                  const _PolicySection(
                    title: '1. Information We Collect',
                    body:
                        'We collect your name, phone number, email address, and service address when you register and use LocalServe. Device information is collected to improve app performance.',
                  ),
                  const _PolicySection(
                    title: '2. How We Use Your Information',
                    body:
                        'Your information is used to connect you with verified local service providers, process bookings, and send service reminders. We do not sell your personal data to third parties.',
                  ),
                  const _PolicySection(
                    title: '3. Data Security',
                    body:
                        'We use industry-standard encryption to protect your personal information. All providers are verified through our KYC process before they can accept bookings.',
                  ),
                  const _PolicySection(
                    title: '4. Booking & Payments',
                    body:
                        'Payments are currently made directly to the provider in cash after service completion. LocalServe does not handle or store any payment card information.',
                  ),
                  const _PolicySection(
                    title: '5. Provider Verification',
                    body:
                        'All service providers undergo background checks and KYC verification by our admin team before being approved on the platform.',
                  ),
                  const _PolicySection(
                    title: '6. Cancellation Policy',
                    body:
                        'Customers can cancel bookings before the service starts. Providers must give a minimum 1-hour notice for cancellations. Repeated cancellations may affect account standing.',
                  ),
                  const _PolicySection(
                    title: '7. Contact Us',
                    body:
                        'For questions about this policy, email support@localserve.in or call +91 98765 43210 (Mon–Sat, 9am–6pm).',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared sheet helpers ────────────────────────────────────────────────────

  Widget _sheetHandle() => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  Widget _sheetTitle(BuildContext ctx, String title) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(ctx)),
          ],
        ),
      );

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: widget.isTab
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pushNamed(context, '/edit_profile'),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Hero Header ────────────────────────────────────────────────────
          Container(
            color: const Color(0xFF1E88E5),
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          Colors.white.withValues(alpha: 0.25),
                      child: Icon(
                        user?.gender == 'female' ? Icons.face_retouching_natural : Icons.face,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified_rounded,
                            size: 14, color: Color(0xFF1E88E5)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Customer',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (user?.email.isNotEmpty == true) ...[
                        const SizedBox(height: 1),
                        Text(
                          user!.email,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (user?.phone.isNotEmpty == true) ...[
                        Text(
                          user!.phone,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:
                              Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Verified Customer',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // White card clipped over blue header for depth effect
                  Transform.translate(
                    offset: const Offset(0, -16),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E88E5)
                                .withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildTile(
                            icon: Icons.calendar_today_outlined,
                            color: Colors.teal,
                            title: 'My Bookings',
                            subtitle:
                                'View all your active and past bookings',
                            onTap: () =>
                                Navigator.pushNamed(context, '/bookings'),
                          ),
                          Divider(
                              height: 1, color: Colors.grey.shade100),
                          _buildTile(
                            icon: Icons.payment_outlined,
                            color: Colors.indigo,
                            title: 'Payment Methods',
                            subtitle: 'Cash, UPI & Saved Cards',
                            onTap: _showPaymentMethodsSheet,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Preferences section ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('PREFERENCES'),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildTile(
                                icon: Icons.notifications_none_outlined,
                                color: Colors.orange,
                                title: 'Notifications',
                                subtitle:
                                    'Manage SMS & Push reminders',
                                onTap: _showNotificationsSheet,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Help & Legal section ─────────────────────────────────
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('HELP & LEGAL'),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildTile(
                                icon: Icons.support_agent_outlined,
                                color: Colors.green,
                                title: 'Customer Support',
                                subtitle: 'support@localserve.in',
                                onTap: _showSupportSheet,
                              ),
                              Divider(
                                  height: 1,
                                  color: Colors.grey.shade100),
                              _buildTile(
                                icon: Icons.security_outlined,
                                color: Colors.purple,
                                title: 'Privacy Policy & Terms',
                                subtitle: 'App terms of service',
                                onTap: _showPrivacyPolicySheet,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Logout ───────────────────────────────────────────────
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 28),
                    child: InkWell(
                      onTap: _handleLogout,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.red.shade100, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red
                                  .withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius:
                                    BorderRadius.circular(11),
                              ),
                              child: const Icon(Icons.logout_rounded,
                                  color: Colors.redAccent, size: 20),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                'Log Out',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 14, color: Colors.redAccent),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _sectionLabel(String label) => Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 0.8,
        ),
      );

  Widget _buildTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF1F2937)),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: Colors.grey.shade400),
    );
  }
}

// ── Privacy Policy section widget ──────────────────────────────────────────────

class _PolicySection extends StatelessWidget {
  final String title;
  final String body;

  const _PolicySection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937)),
          ),
          const SizedBox(height: 5),
          Text(
            body,
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.55),
          ),
        ],
      ),
    );
  }
}
