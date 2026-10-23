import 'package:flutter/material.dart';
import '../../core/models/booking_model.dart';
import '../../core/widgets/custom_button.dart';

class ProviderJobDetailsScreen extends StatefulWidget {
  final BookingModel job;

  const ProviderJobDetailsScreen({super.key, required this.job});

  @override
  State<ProviderJobDetailsScreen> createState() => _ProviderJobDetailsScreenState();
}

class _ProviderJobDetailsScreenState extends State<ProviderJobDetailsScreen> {
  late BookingStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.job.status;
  }

  void _advanceJobStatus() {
    setState(() {
      if (_currentStatus == BookingStatus.confirmed) {
        _currentStatus = BookingStatus.inProgress;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job status updated: Work in Progress!')),
        );
      } else if (_currentStatus == BookingStatus.inProgress) {
        _currentStatus = BookingStatus.completed;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job Completed successfully! ₹249 added to your wallet.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Job #${widget.job.id}',
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(_currentStatus.icon, color: _currentStatus.color, size: 24),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('JOB STATUS', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                          Text(
                            _currentStatus.label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _currentStatus.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    '₹${widget.job.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Customer Info & Quick Contact
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Customer Contact', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                        child: Text(
                          widget.job.customerName.isNotEmpty ? widget.job.customerName[0] : 'C',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.job.customerName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            Text(widget.job.customerPhone, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Calling customer: ${widget.job.customerPhone}')),
                          );
                        },
                        icon: const Icon(Icons.phone, size: 20, color: Color(0xFF1E88E5)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Service details & scheduled slot
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Service Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Text(
                    widget.job.serviceTitle,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Category: ${widget.job.serviceCategory}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Color(0xFF1E88E5)),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.job.bookingDate.day}/${widget.job.bookingDate.month}/${widget.job.bookingDate.year} • ${widget.job.timeSlot}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF1E88E5)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.job.address,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                  if (widget.job.notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Customer Note: ${widget.job.notes}',
                              style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (_currentStatus == BookingStatus.confirmed) ...[
              CustomButton(
                text: 'Start Job / On the Way',
                icon: Icons.play_arrow_rounded,
                onPressed: _advanceJobStatus,
              ),
            ] else if (_currentStatus == BookingStatus.inProgress) ...[
              CustomButton(
                text: 'Mark Job Completed & Collect Payment',
                icon: Icons.check_circle_outline,
                backgroundColor: Colors.green,
                onPressed: _advanceJobStatus,
              ),
            ] else if (_currentStatus == BookingStatus.completed) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified, color: Colors.green, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Job Completed & Paid Successfully',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
