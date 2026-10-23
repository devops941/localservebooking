import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/admin_service.dart';
import '../../core/models/provider_model.dart';

class VerificationsScreen extends StatefulWidget {
  const VerificationsScreen({super.key});

  @override
  State<VerificationsScreen> createState() => _VerificationsScreenState();
}

class _VerificationsScreenState extends State<VerificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminService>().loadPendingProviders();
    });
  }

  // ── Opens the full-detail popup for a provider ──
  void _showDetailPopup(ProviderModel p) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _KycDetailDialog(
        provider: p,
        onApprove: () => _handleApprove(p),
        onReject: () => _handleReject(p),
      ),
    );
  }

  Future<void> _handleApprove(ProviderModel provider) async {
    Navigator.of(context, rootNavigator: true).pop(); // close popup first
    final err = await context.read<AdminService>().approveProvider(provider.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(err ??
                  '${provider.name} approved! Notification sent to ${provider.phone.isNotEmpty ? provider.phone : "provider"}.'),
            ),
          ],
        ),
        backgroundColor: err != null ? Colors.redAccent : Colors.green.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleReject(ProviderModel provider) async {
    Navigator.of(context, rootNavigator: true).pop(); // close popup first
    final err = await context.read<AdminService>().rejectProvider(provider.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cancel, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(err ?? 'Application for ${provider.name} rejected.'),
            ),
          ],
        ),
        backgroundColor: err != null ? Colors.redAccent : Colors.orange.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<AdminService>();
    final providers = svc.pendingProviders;

    if (svc.isLoading && providers.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5)));
    }

    if (svc.error != null && providers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(svc.error!, style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<AdminService>().loadPendingProviders(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (providers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user_outlined, size: 72, color: Colors.green.shade400),
            const SizedBox(height: 16),
            const Text(
              'All Applications Reviewed!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 6),
            const Text(
              'No pending KYC verifications in queue.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => context.read<AdminService>().loadPendingProviders(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ── Header bar ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Text(
                      '${providers.length} pending',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Provider KYC applications awaiting review',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
              if (svc.isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E88E5)),
                )
              else
                IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () => context.read<AdminService>().loadPendingProviders(),
                ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),

        // ── Provider cards list ──
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: providers.length,
            itemBuilder: (ctx, i) => _buildProviderCard(providers[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderCard(ProviderModel p) {
    final joinDate = p.createdAt != null
        ? '${p.createdAt!.day}/${p.createdAt!.month}/${p.createdAt!.year}'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card header ──
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                  child: Text(
                    p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E88E5),
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.profession,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      if (joinDate.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Applied on $joinDate',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hourglass_top_rounded,
                          size: 12, color: Colors.amber.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'KYC PENDING',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Quick info chips ──
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                if (p.area.isNotEmpty) _chip(Icons.location_on_outlined, p.area),
                if (p.phone.isNotEmpty) _chip(Icons.phone_outlined, p.phone),
                if (p.hourlyRate > 0) _chip(Icons.currency_rupee, '₹${p.hourlyRate.toInt()}/hr'),
                if (p.experienceYears > 0)
                  _chip(Icons.work_history_outlined, '${p.experienceYears} yrs exp'),
              ],
            ),
            const Divider(height: 24, color: Color(0xFFE5E7EB)),

            // ── Actions ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // View details link
                TextButton.icon(
                  onPressed: () => _showDetailPopup(p),
                  icon: const Icon(Icons.open_in_new, size: 14),
                  label: const Text('View Full Details'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1E88E5),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showDetailPopup(p),
                      icon: const Icon(Icons.close, size: 15),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => _showDetailPopup(p),
                      icon: const Icon(Icons.verified, size: 15),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Full-detail KYC popup dialog
// ─────────────────────────────────────────────
class _KycDetailDialog extends StatefulWidget {
  final ProviderModel provider;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _KycDetailDialog({
    required this.provider,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<_KycDetailDialog> createState() => _KycDetailDialogState();
}

class _KycDetailDialogState extends State<_KycDetailDialog> {
  bool _isActing = false;

  Future<void> _act(VoidCallback action) async {
    setState(() => _isActing = true);
    action();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    final joinDate = p.createdAt != null
        ? '${p.createdAt!.day}/${p.createdAt!.month}/${p.createdAt!.year}'
        : 'N/A';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Dialog header ──
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
              decoration: const BoxDecoration(
                color: Color(0xFF0D1B3E),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                    child: Text(
                      p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          p.profession,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      'KYC PENDING',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                  ),
                ],
              ),
            ),

            // ── Scrollable body ──
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Info section
                    _sectionHeader(Icons.person_outline, 'Personal Information'),
                    const SizedBox(height: 12),
                    _infoGrid([
                      _InfoItem('Full Name', p.name, Icons.badge_outlined),
                      _InfoItem('Email Address', p.email.isNotEmpty ? p.email : 'N/A', Icons.email_outlined),
                      _InfoItem('Phone Number', p.phone.isNotEmpty ? p.phone : 'N/A', Icons.phone_outlined),
                      _InfoItem('Applied On', joinDate, Icons.calendar_today_outlined),
                    ]),

                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 20),

                    // Professional Details section
                    _sectionHeader(Icons.work_outline, 'Professional Details'),
                    const SizedBox(height: 12),
                    _infoGrid([
                      _InfoItem('Profession / Trade', p.profession.isNotEmpty ? p.profession : 'N/A', Icons.handyman_outlined),
                      _InfoItem('Service Area', p.area.isNotEmpty ? p.area : 'N/A', Icons.location_on_outlined),
                      _InfoItem('City', p.city.isNotEmpty ? p.city : 'N/A', Icons.location_city_outlined),
                      _InfoItem('Experience', '${p.experienceYears} year${p.experienceYears != 1 ? 's' : ''}', Icons.work_history_outlined),
                      _InfoItem('Hourly Rate', p.hourlyRate > 0 ? '₹${p.hourlyRate.toInt()} / hour' : 'N/A', Icons.currency_rupee),
                    ]),

                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 20),

                    // Identity proof section
                    _sectionHeader(Icons.verified_user_outlined, 'Identity Documents'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _docTile(
                            icon: Icons.credit_card_outlined,
                            label: 'Aadhaar Card',
                            sublabel: 'Government ID',
                            color: const Color(0xFF1E88E5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _docTile(
                            icon: Icons.receipt_long_outlined,
                            label: 'PAN Card',
                            sublabel: 'Tax Identity',
                            color: const Color(0xFF43A047),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Admin note
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.amber.shade700, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Approving will activate this provider and send a verification notification to their registered mobile number.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade800,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Action buttons (fixed at bottom) ──
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                children: [
                  // Reject button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isActing ? null : () => _act(widget.onReject),
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Reject Application'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Approve button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isActing ? null : () => _act(widget.onApprove),
                      icon: _isActing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.verified, size: 16),
                      label: Text(
                          _isActing ? 'Approving...' : 'Approve & Send Notification'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
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

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1E88E5)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _infoGrid(List<_InfoItem> items) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        return SizedBox(
          width: 240,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(item.icon, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.value,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _docTile({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              Text(sublabel,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check_circle,
                      size: 12, color: Colors.green.shade500),
                  const SizedBox(width: 4),
                  Text('Submitted',
                      style: TextStyle(
                          fontSize: 10, color: Colors.green.shade600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  final IconData icon;
  const _InfoItem(this.label, this.value, this.icon);
}
