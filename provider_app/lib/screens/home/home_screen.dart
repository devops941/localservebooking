import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/provider_service.dart';
import '../requests/requests_screen.dart';
import '../jobs/jobs_screen.dart';
import '../earnings/earnings_screen.dart';
import '../profile/profile_screen.dart';
import '../services/services_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _checkPendingNotification();
      context.read<ProviderService>().startPolling();
    });
  }

  Future<void> _loadData() async {
    final providerService = context.read<ProviderService>();
    await Future.wait([
      providerService.loadStats(),
      providerService.loadBookings(),
      providerService.loadNotifications(),
    ]);
  }

  void _checkPendingNotification() {
    final auth = context.read<AuthService>();
    final title = auth.pendingNotificationTitle;
    final message = auth.pendingNotificationMessage;
    if (title == null || message == null) return;

    auth.clearPendingNotification();

    final isApproved = title.toLowerCase().contains('verified') ||
        title.toLowerCase().contains('approved');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isApproved
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isApproved
                      ? Icons.verified_rounded
                      : Icons.info_outline_rounded,
                  size: 38,
                  color: isApproved
                      ? Colors.green.shade500
                      : Colors.orange.shade600,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isApproved
                        ? const Color(0xFF00897B)
                        : Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isApproved ? 'Start Accepting Jobs!' : 'Got it',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationSheet(BuildContext context) {
    final providerService = context.read<ProviderService>();
    providerService.loadNotifications();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Consumer<ProviderService>(
        builder: (context, ps, _) {
          final notifs = ps.notifications;
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.35,
            maxChildSize: 0.85,
            expand: false,
            builder: (_, scrollController) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active_rounded,
                          color: Color(0xFF00897B), size: 20),
                      const SizedBox(width: 8),
                      const Flexible(
                        child: Text(
                          'Notifications & Alerts',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (ps.unreadNotifications > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${ps.unreadNotifications} new',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (notifs.isNotEmpty)
                        TextButton(
                          onPressed: () => ps.markAllNotificationsRead(),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Mark all read',
                              style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                  const Divider(height: 16),
                  Expanded(
                    child: notifs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_off_outlined,
                                    size: 40, color: Colors.grey.shade400),
                                const SizedBox(height: 10),
                                Text(
                                  'No notifications yet.',
                                  style: TextStyle(
                                      color: Colors.grey.shade600, fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: notifs.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final n = notifs[index];
                              final isUnread = n['read'] == false;
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: n['type'] == 'booking_request'
                                      ? Colors.orange.shade50
                                      : const Color(0xFF00897B)
                                          .withValues(alpha: 0.12),
                                  child: Icon(
                                    n['type'] == 'booking_request'
                                        ? Icons.notifications_active_rounded
                                        : Icons.info_outline_rounded,
                                    color: n['type'] == 'booking_request'
                                        ? Colors.orange
                                        : const Color(0xFF00897B),
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  n['title'] ?? 'Notification',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: isUnread
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                subtitle: Text(
                                  n['message'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isUnread
                                        ? Colors.black87
                                        : Colors.grey.shade600,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  setState(() => _currentTabIndex = 1);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerService = context.watch<ProviderService>();
    final pendingCount = providerService.getIncomingRequests().length;

    // Check if new booking alert was triggered
    if (providerService.hasNewRequestAlert) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        providerService.clearNewRequestAlert();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orange.shade800,
            duration: const Duration(seconds: 4),
            content: const Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'New Booking Request received! Tap to review.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'VIEW',
              textColor: Colors.white,
              onPressed: () => setState(() => _currentTabIndex = 1),
            ),
          ),
        );
      });
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _buildDashboard(),
          const RequestsScreen(isTab: true),
          const JobsScreen(isTab: true),
          const EarningsScreen(isTab: true),
          const ProfileScreen(isTab: true),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00897B),
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              backgroundColor: Colors.orange,
              child: const Icon(Icons.notifications_active_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              backgroundColor: Colors.orange,
              child: const Icon(Icons.notifications_active),
            ),
            label: 'Requests',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Jobs',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Earnings',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Consumer2<AuthService, ProviderService>(
      builder: (context, authService, providerService, _) {
        final user = authService.currentUser;
        final providerProfile = authService.providerProfile;
        final stats = providerService.stats;
        final isAvailable = stats['isAvailable'] as bool? ??
            providerProfile?.isAvailable ?? false;
        final pendingCount = providerService.getIncomingRequests().length;
        final activeCount = providerService.getActiveJobs().length;
        final walletBalance =
            (stats['walletBalance'] ?? providerProfile?.walletBalance ?? 0)
                .toDouble();
        final rating =
            (stats['rating'] ?? providerProfile?.rating ?? 0).toDouble();
        final completedJobs =
            stats['totalCompletedJobs'] ?? providerProfile?.completedJobs ?? 0;
        final unreadNotifs = providerService.unreadNotifications;
        final initials = (user?.name.isNotEmpty == true)
            ? user!.name[0].toUpperCase()
            : 'P';

        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F4),
          body: Column(
            children: [
              // ── Green gradient header ──
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00897B), Color(0xFF00695C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Provider identity row
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.22),
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.name ?? 'Provider',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (providerProfile?.isVerified == true)
                                    const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.verified,
                                            size: 12, color: Colors.white70),
                                        SizedBox(width: 3),
                                        Text(
                                          'Verified Pro',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    const Text(
                                      'Service Provider',
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.white60),
                                    ),
                                ],
                              ),
                            ),
                            // Notification bell
                            GestureDetector(
                              onTap: () => _showNotificationSheet(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Badge(
                                  isLabelVisible: unreadNotifs > 0,
                                  label: Text('$unreadNotifs',
                                      style: const TextStyle(fontSize: 9)),
                                  backgroundColor: Colors.orange,
                                  child: const Icon(
                                      Icons.notifications_outlined,
                                      color: Colors.white,
                                      size: 22),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Availability toggle pill
                            GestureDetector(
                              onTap: () {
                                providerService
                                    .toggleAvailability(!isAvailable)
                                    .then((success) {
                                  if (!context.mounted) return;
                                  if (success) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(!isAvailable
                                          ? 'You are now Online!'
                                          : 'You are now Offline.'),
                                      duration: const Duration(seconds: 2),
                                    ));
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isAvailable
                                      ? Colors.white.withValues(alpha: 0.22)
                                      : Colors.white.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isAvailable
                                        ? Colors.white54
                                        : Colors.white24,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: isAvailable
                                            ? Colors.greenAccent
                                            : Colors.white38,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      isAvailable ? 'Online' : 'Offline',
                                      style: TextStyle(
                                        color: isAvailable
                                            ? Colors.white
                                            : Colors.white54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Stats row in frosted container
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryItem(
                                  'Wallet',
                                  '₹${walletBalance.toStringAsFixed(0)}',
                                  Icons.account_balance_wallet_outlined),
                              _buildSummaryDivider(),
                              _buildSummaryItem('Jobs Done', '$completedJobs',
                                  Icons.task_alt_outlined),
                              _buildSummaryDivider(),
                              _buildSummaryItem(
                                  'Rating',
                                  '${rating.toStringAsFixed(1)} ★',
                                  Icons.star_outline_rounded),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Scrollable body ──
              Expanded(
                child: providerService.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF00897B)))
                    : RefreshIndicator(
                        color: const Color(0xFF00897B),
                        onRefresh: _loadData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding:
                              const EdgeInsets.fromLTRB(16, 18, 16, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Pending requests alert
                              if (pendingCount > 0) ...[
                                InkWell(
                                  onTap: () => setState(
                                      () => _currentTabIndex = 1),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius:
                                          BorderRadius.circular(14),
                                      border: Border.all(
                                          color: Colors.orange.shade200),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange
                                              .withValues(alpha: 0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(9),
                                          decoration: const BoxDecoration(
                                            color: Colors.orange,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                              Icons.notifications_active,
                                              color: Colors.white,
                                              size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$pendingCount New Job Request${pendingCount > 1 ? 's' : ''} Waiting',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 14,
                                                    color:
                                                        Color(0xFF1F2937)),
                                              ),
                                              const Text(
                                                'Review & accept customer booking now',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.black54),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.arrow_forward_ios,
                                            size: 14, color: Colors.orange),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],

                              const Text(
                                'Quick Actions',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937)),
                              ),
                              const SizedBox(height: 12),
                              GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.55,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  _buildActionCard(
                                    'My Rate Card',
                                    'Edit prices',
                                    Icons.sell_outlined,
                                    const Color(0xFF7C3AED),
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const ServicesScreen()),
                                    ),
                                  ),
                                  _buildActionCard(
                                    'Active Jobs',
                                    '$activeCount in progress',
                                    Icons.assignment_outlined,
                                    const Color(0xFF00897B),
                                    () => setState(
                                        () => _currentTabIndex = 2),
                                  ),
                                  _buildActionCard(
                                    'Wallet & Payout',
                                    '₹${walletBalance.toStringAsFixed(0)} balance',
                                    Icons.account_balance_wallet_outlined,
                                    const Color(0xFF3B82F6),
                                    () => setState(
                                        () => _currentTabIndex = 3),
                                  ),
                                  _buildActionCard(
                                    'KYC Profile',
                                    providerProfile?.isVerified == true
                                        ? 'Verified ✓'
                                        : 'Pending review',
                                    Icons.badge_outlined,
                                    const Color(0xFF0EA5E9),
                                    () => setState(
                                        () => _currentTabIndex = 4),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildSummaryDivider() {
    return Container(height: 36, width: 1, color: Colors.white24);
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1F2937))),
            const SizedBox(height: 2),
            Text(subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}
