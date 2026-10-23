import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/booking_model.dart';
import '../../core/services/provider_service.dart';

class RequestsScreen extends StatefulWidget {
  final bool isTab;

  const RequestsScreen({super.key, this.isTab = false});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderService>().loadBookings();
    });
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: fullQuery));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Address copied to clipboard: "$fullQuery"'),
                      backgroundColor: const Color(0xFF00897B),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy Address for Maps Navigation',
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
            if (phone.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: phone));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Phone number $phone copied!')),
                    );
                  },
                  icon: const Icon(Icons.phone_rounded, size: 18),
                  label: Text('Copy Customer Phone ($phone)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00897B),
                    side: const BorderSide(color: Color(0xFF00897B)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
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

  Future<void> _acceptRequest(BookingModel req) async {
    final providerService = context.read<ProviderService>();
    final success =
        await providerService.updateBookingStatus(req.id, BookingStatus.confirmed);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Accepted booking for ${req.serviceTitle}! Added to your Active Jobs.'),
          backgroundColor: const Color(0xFF00897B),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(providerService.errorMessage ?? 'Failed to accept job.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _declineRequest(BookingModel req) async {
    final providerService = context.read<ProviderService>();
    final success =
        await providerService.updateBookingStatus(req.id, BookingStatus.cancelled);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking request declined.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderService>(
      builder: (context, providerService, _) {
        final requests = providerService.getIncomingRequests();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Incoming Requests (${requests.length})',
              style: const TextStyle(
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
          ),
          body: providerService.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00897B)))
              : RefreshIndicator(
                  color: const Color(0xFF00897B),
                  onRefresh: providerService.loadBookings,
                  child: requests.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.65,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00897B)
                                              .withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.notifications_none_rounded,
                                          size: 48,
                                          color: Color(0xFF00897B),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      const Text(
                                        'No New Booking Requests',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'When customers in Madurai book your service, requests will automatically alert and appear here in real-time.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: Colors.grey.shade600,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      OutlinedButton.icon(
                                        onPressed: () =>
                                            providerService.loadBookings(),
                                        icon: const Icon(Icons.refresh_rounded,
                                            size: 16),
                                        label: const Text('Check for Requests'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              const Color(0xFF00897B),
                                          side: const BorderSide(
                                              color: Color(0xFF00897B)),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final req = requests[index];
                            final formattedDate =
                                '${req.bookingDate.day.toString().padLeft(2, '0')}/${req.bookingDate.month.toString().padLeft(2, '0')}/${req.bookingDate.year}';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.orange.shade200, width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withValues(alpha: 0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header: Service & Amount
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF3C7),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'NEW REQUEST',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF92400E),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '₹${req.totalAmount.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Color(0xFF00897B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Service Title
                                    Text(
                                      req.serviceTitle,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Customer Details Tile
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 14,
                                                backgroundColor:
                                                    const Color(0xFF00897B)
                                                        .withValues(alpha: 0.12),
                                                child: Text(
                                                  req.customerName.isNotEmpty
                                                      ? req.customerName[0]
                                                          .toUpperCase()
                                                      : 'C',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF00897B),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  req.customerName.isNotEmpty
                                                      ? req.customerName
                                                      : 'Customer',
                                                  style: const TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF1E293B),
                                                  ),
                                                ),
                                              ),
                                              if (req.customerPhone.isNotEmpty)
                                                InkWell(
                                                  onTap: () => _callCustomer(
                                                      req.customerPhone),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFECFDF5),
                                                      borderRadius:
                                                          BorderRadius.circular(8),
                                                      border: Border.all(
                                                          color: const Color(
                                                              0xFFA7F3D0)),
                                                    ),
                                                    child: const Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.phone,
                                                            size: 13,
                                                            color: Color(
                                                                0xFF059669)),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          'Call',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xFF065F46),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today,
                                                  size: 13, color: Colors.grey),
                                              const SizedBox(width: 6),
                                              Text(
                                                '$formattedDate • ${req.timeSlot}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Customer Location Section
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: const Color(0xFFBFDBFE)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on,
                                                  size: 16,
                                                  color: Color(0xFF1E88E5)),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  req.address.isNotEmpty
                                                      ? req.address
                                                      : 'Madurai',
                                                  style: const TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF1E3A8A),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () =>
                                                      _openLocationDetails(
                                                          req.address,
                                                          req.customerName,
                                                          req.customerPhone),
                                                  icon: const Icon(
                                                      Icons.directions_outlined,
                                                      size: 15),
                                                  label: const Text(
                                                    'Location & Directions',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFF1E88E5),
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 8),
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8)),
                                                    minimumSize: Size.zero,
                                                    tapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                icon: const Icon(Icons.copy,
                                                    size: 16,
                                                    color: Color(0xFF1E88E5)),
                                                tooltip: 'Copy Address',
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                onPressed: () {
                                                  Clipboard.setData(ClipboardData(
                                                      text: req.address));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Address copied to clipboard!'),
                                                      duration:
                                                          Duration(seconds: 1),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    if (req.notes.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.note_alt_outlined,
                                              size: 14, color: Colors.orange),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'Note: ${req.notes}',
                                              style: TextStyle(
                                                  fontSize: 11.5,
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.grey.shade700),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],

                                    const Divider(height: 20),

                                    // Action Buttons: Decline & Accept
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () =>
                                                _declineRequest(req),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  Colors.red.shade700,
                                              side: BorderSide(
                                                  color: Colors.red.shade300),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                            ),
                                            child: const Text('Decline'),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                _acceptRequest(req),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF00897B),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                            ),
                                            child: const Text(
                                              'Accept Job',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
        );
      },
    );
  }
}
