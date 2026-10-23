import 'package:flutter/material.dart';
import '../../core/models/booking_model.dart';
import 'provider_job_details_screen.dart';

class ProviderRequestsScreen extends StatefulWidget {
  final bool isTab;

  const ProviderRequestsScreen({super.key, this.isTab = false});

  @override
  State<ProviderRequestsScreen> createState() => _ProviderRequestsScreenState();
}

class _ProviderRequestsScreenState extends State<ProviderRequestsScreen> {
  final List<BookingModel> _requests = [
    BookingModel(
      id: 'BK-1095',
      customerId: 'cust_002',
      customerName: 'Vigneshwaran',
      customerPhone: '+91 97911 22334',
      providerId: 'prov_01',
      providerName: 'Suresh Kumar',
      providerProfession: 'Electrician',
      serviceCategory: 'Electrician',
      serviceTitle: 'Ceiling Fan Installation / Replacement',
      bookingDate: DateTime.now().add(const Duration(hours: 3)),
      timeSlot: '04:00 PM - 05:00 PM',
      status: BookingStatus.pending,
      totalAmount: 199.0,
      address: 'Door 18, 4th Main Road, Besant Nagar, Chennai - 600090',
      notes: 'New fan box ready, ladder available in house.',
    ),
    BookingModel(
      id: 'BK-1096',
      customerId: 'cust_003',
      customerName: 'Meenakshi Sundaram',
      customerPhone: '+91 98410 88990',
      providerId: 'prov_01',
      providerName: 'Suresh Kumar',
      providerProfession: 'Electrician',
      serviceCategory: 'Electrician',
      serviceTitle: 'MCB / Distribution Box Repair',
      bookingDate: DateTime.now().add(const Duration(days: 1)),
      timeSlot: '11:00 AM - 12:30 PM',
      status: BookingStatus.pending,
      totalAmount: 349.0,
      address: 'Flat 4B, Ceebros Heights, Adyar, Chennai - 600020',
      notes: 'Main power switch trips intermittently when geyser is switched on.',
    ),
  ];

  void _acceptRequest(int index) {
    final acceptedJob = _requests[index].copyWith(status: BookingStatus.confirmed);
    setState(() {
      _requests.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Accepted Job #${acceptedJob.id}! Added to active jobs.'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'View Job',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProviderJobDetailsScreen(job: acceptedJob),
              ),
            );
          },
        ),
      ),
    );
  }

  void _declineRequest(int index) {
    setState(() {
      _requests.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking request declined.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Incoming Job Requests (${_requests.length})',
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: widget.isTab
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: _requests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('No new booking requests at the moment.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 6),
                  Text('Keep your availability toggle ON to get notified.', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final req = _requests[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              req.serviceTitle,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              '₹${req.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1E88E5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(req.customerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${req.bookingDate.day}/${req.bookingDate.month} • ${req.timeSlot}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                req.address,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _declineRequest(index),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                  side: const BorderSide(color: Colors.redAccent),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Decline'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _acceptRequest(index),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E88E5),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Accept Job'),
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
    );
  }
}
