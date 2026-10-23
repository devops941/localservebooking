import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/booking_model.dart';
import '../../core/services/provider_service.dart';
import '../../core/services/location_tracking_service.dart';
import '../payment/collect_payment_screen.dart';

class JobsScreen extends StatefulWidget {
  final bool isTab;

  const JobsScreen({super.key, this.isTab = false});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LocationTrackingService _tracker = LocationTrackingService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderService>().loadBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tracker.stopTracking();
    super.dispose();
  }

  Future<void> _openInMaps(String query) async {
    final encoded = Uri.encodeComponent(query);
    final gMaps = Uri.parse('google.navigation:q=$encoded&mode=d');
    final gMapsWeb = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$encoded');
    if (await canLaunchUrl(gMaps)) {
      await launchUrl(gMaps);
    } else if (await canLaunchUrl(gMapsWeb)) {
      await launchUrl(gMapsWeb, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps. Please copy the address.')),
        );
      }
    }
  }

  void _openLocationDetails(String address, String customerName, String phone) {
    final fullQuery = address.toLowerCase().contains('madurai')
        ? address
        : '$address, Madurai';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on, color: Color(0xFF1E88E5), size: 24),
                SizedBox(width: 8),
                Text(
                  'Customer Location Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName.isNotEmpty ? customerName : 'Customer',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fullQuery,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.w500),
                  ),
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Contact: $phone',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Navigate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _openInMaps(fullQuery);
                },
                icon: const Icon(Icons.navigation_rounded, size: 18),
                label: const Text('Navigate with Google Maps',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: fullQuery));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Address copied to clipboard'),
                          backgroundColor: Color(0xFF00897B),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Copy Address'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E88E5),
                      side: const BorderSide(color: Color(0xFF1E88E5)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _callCustomer(phone);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.phone_rounded, size: 16),
                      label: Text(phone),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00897B),
                        side: const BorderSide(color: Color(0xFF00897B)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _callCustomer(String phone) async {
    if (phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer phone number not available.')),
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Clipboard.setData(ClipboardData(text: phone));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phone: $phone — copied to clipboard')),
      );
    }
  }

  Future<void> _updateStatus(BookingModel job, BookingStatus newStatus) async {
    final providerService = context.read<ProviderService>();
    final success = await providerService.updateBookingStatus(job.id, newStatus);
    if (!mounted) return;
    if (success) {
      if (newStatus == BookingStatus.inProgress) {
        _tracker.startTracking(job.id);
      } else if (newStatus == BookingStatus.completed ||
          newStatus == BookingStatus.cancelled) {
        _tracker.stopTracking();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job status updated to ${newStatus.label}.'),
          backgroundColor: const Color(0xFF00897B),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(providerService.errorMessage ?? 'Failed to update status.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showDelayNotificationSheet(BuildContext context, BookingModel job) {
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        const delays = [10, 15, 20, 30, 45, 60];
        int selectedDelay = 10;
        bool isSending = false;

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Notify Customer About Delay',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${job.customerName.isNotEmpty ? job.customerName : 'Customer'} · ${job.serviceTitle}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Delay Duration',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: delays.map((minutes) {
                      final isSelected = selectedDelay == minutes;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedDelay = minutes),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFF59E0B) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFF59E0B) : Colors.grey.shade400,
                            ),
                          ),
                          child: Text(
                            '$minutes min',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: messageController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'e.g. Sorry, traffic jam on the way...',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFF59E0B)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSending
                          ? null
                          : () async {
                              setSheetState(() => isSending = true);
                              final error = await context.read<ProviderService>().sendDelayNotification(
                                bookingId: job.id,
                                delayMinutes: selectedDelay,
                                message: messageController.text.trim().isNotEmpty
                                    ? messageController.text.trim()
                                    : null,
                              );
                              setSheetState(() => isSending = false);
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error ?? 'Customer notified about the delay.'),
                                  backgroundColor: error != null ? Colors.redAccent : const Color(0xFF00897B),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: isSending
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Text(
                              'Send Notification',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showStatusDialog(BuildContext context, BookingModel job) {
    final actions = <BookingStatus>[];
    if (job.status == BookingStatus.confirmed) {
      actions.add(BookingStatus.inProgress);
    }
    if (job.status == BookingStatus.inProgress) {
      actions.add(BookingStatus.completed);
    }
    if (job.status != BookingStatus.cancelled) {
      actions.add(BookingStatus.cancelled);
    }

    if (actions.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update Job Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...actions.map((status) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: status.color.withValues(alpha: 0.15),
                      child: Icon(
                        status == BookingStatus.inProgress
                            ? Icons.navigation_rounded
                            : status == BookingStatus.completed
                                ? Icons.check_circle_outline
                                : Icons.cancel_outlined,
                        color: status.color,
                      ),
                    ),
                    title: Text(
                      status == BookingStatus.inProgress
                          ? 'Start Job (On The Way / In Progress)'
                          : 'Mark as ${status.label}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _updateStatus(job, status);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderService>(
      builder: (context, providerService, _) {
        final activeJobs = providerService.getActiveJobs();
        final completedJobs = providerService.getCompletedJobs();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'My Service Jobs',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            leading: widget.isTab
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF1E293B), size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF00897B)),
                onPressed: () => providerService.loadBookings(),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF00897B),
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: const Color(0xFF00897B),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(text: 'Active Jobs (${activeJobs.length})'),
                Tab(text: 'Completed (${completedJobs.length})'),
              ],
            ),
          ),
          body: providerService.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00897B)))
              : RefreshIndicator(
                  color: const Color(0xFF00897B),
                  onRefresh: providerService.loadBookings,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildJobsList(activeJobs, 'No active jobs right now.',
                          showManage: true),
                      _buildJobsList(completedJobs, 'No completed jobs yet.',
                          showManage: false),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildJobsList(List<BookingModel> list, String emptyMessage,
      {required bool showManage}) {
    if (list.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: 300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined,
                      size: 50, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(emptyMessage,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final job = list[index];
        final formattedDate =
            '${job.bookingDate.day.toString().padLeft(2, '0')}/${job.bookingDate.month.toString().padLeft(2, '0')}/${job.bookingDate.year}';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: ID and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      job.bookingNumber.isNotEmpty
                          ? job.bookingNumber
                          : 'Job #${job.id.length > 8 ? job.id.substring(job.id.length - 8) : job.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        color: Colors.grey,
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: job.status.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        job.status.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: job.status.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Service & Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        job.serviceTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.5,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Text(
                      '₹${job.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00897B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Customer info & Contact
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 15, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        job.customerName.isNotEmpty ? job.customerName : 'Customer',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (job.customerPhone.isNotEmpty)
                      InkWell(
                        onTap: () => _callCustomer(job.customerPhone),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.phone,
                                  size: 12, color: Color(0xFF059669)),
                              SizedBox(width: 4),
                              Text(
                                'Call',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF065F46),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),

                // Date & Time
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '$formattedDate • ${job.timeSlot}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),

                // Customer Location Section
                if (job.address.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 15, color: Color(0xFF1E88E5)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                job.address,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (showManage) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _openLocationDetails(
                                      job.address,
                                      job.customerName,
                                      job.customerPhone),
                                  icon: const Icon(Icons.directions_outlined,
                                      size: 14),
                                  label: const Text(
                                    'Customer Location & Directions',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E88E5),
                                    foregroundColor: Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6)),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                icon: const Icon(Icons.copy,
                                    size: 15, color: Color(0xFF1E88E5)),
                                tooltip: 'Copy Address',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: job.address));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Address copied to clipboard!'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                if (!showManage) ...[
                  const SizedBox(height: 8),
                  // Payment row — Column to avoid overflow on small screens
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: job.paymentStatus == 'paid'
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: job.paymentStatus == 'paid'
                            ? const Color(0xFFA7F3D0)
                            : const Color(0xFFFED7AA),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          job.paymentStatus == 'paid'
                              ? Icons.check_circle_outline
                              : Icons.payment_outlined,
                          size: 14,
                          color: job.paymentStatus == 'paid'
                              ? const Color(0xFF059669)
                              : const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            job.paymentStatus == 'paid'
                                ? 'Paid via ${job.paymentMethod == 'cash' ? 'Cash' : job.paymentMethod == 'upi' ? 'UPI' : job.paymentMethod}'
                                : 'Payment Pending',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: job.paymentStatus == 'paid'
                                  ? const Color(0xFF059669)
                                  : const Color(0xFFD97706),
                            ),
                          ),
                        ),
                        if (job.paymentStatus != 'paid')
                          GestureDetector(
                            onTap: () {
                              final svc = context.read<ProviderService>();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CollectPaymentScreen(booking: job),
                                ),
                              ).then((_) => svc.loadBookings());
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00897B),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Collect',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Customer review (if any)
                  if (job.rating != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 4),
                              Text(
                                'Customer Review — ${job.rating}/5',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                              ),
                              const SizedBox(width: 6),
                              Row(
                                children: List.generate(5, (i) => Icon(
                                  i < (job.rating ?? 0) ? Icons.star_rounded : Icons.star_outline_rounded,
                                  size: 13,
                                  color: const Color(0xFFF59E0B),
                                )),
                              ),
                            ],
                          ),
                          if (job.reviewComment != null && job.reviewComment!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              '"${job.reviewComment}"',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF78350F), fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],

                if (showManage) ...[
                  const Divider(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showStatusDialog(context, job),
                      icon: Icon(
                        job.status == BookingStatus.confirmed
                            ? Icons.play_arrow_rounded
                            : Icons.task_alt_rounded,
                        size: 16,
                      ),
                      label: Text(
                        job.status == BookingStatus.confirmed
                            ? 'Start Service Job'
                            : 'Update / Complete Service',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: job.status == BookingStatus.confirmed
                            ? const Color(0xFF00897B)
                            : Colors.teal.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  if (job.status == BookingStatus.inProgress) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showDelayNotificationSheet(context, job),
                        icon: const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFFF59E0B)),
                        label: const Text(
                          'Notify Customer About Delay',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFF59E0B)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
