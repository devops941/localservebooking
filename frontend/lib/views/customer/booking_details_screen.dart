import 'package:flutter/material.dart';
import '../../core/models/booking_model.dart';
import '../../core/services/booking_service.dart';
import '../../core/widgets/custom_button.dart';
import 'review_screen.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final bookingService = BookingService();

  void _handleCancel() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Booking'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              bookingService.cancelBooking(widget.bookingId);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking has been cancelled.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = bookingService.getBookingById(widget.bookingId);

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Details')),
        body: const Center(child: Text('Booking not found.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Booking #${booking.id}',
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
          children: [
            // Status Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(booking.status.icon, color: booking.status.color, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            booking.status.label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: booking.status.color,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₹${booking.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTimeline(booking.status),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Provider Info Card
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
                  const Text(
                    'Service Provider',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFF1E88E5).withValues(alpha: 0.12),
                        child: Text(
                          booking.providerName[0],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.providerName,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              booking.providerProfession,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone, color: Color(0xFF1E88E5)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Calling provider...')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Schedule & Address Card
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
                  const Text(
                    'Schedule & Address',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, size: 20, color: Color(0xFF1E88E5)),
                      const SizedBox(width: 10),
                      Text(
                        '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year} (${booking.timeSlot})',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 20, color: Color(0xFF1E88E5)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          booking.address,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                  if (booking.notes.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.note_alt_outlined, size: 20, color: Colors.orange),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Note: ${booking.notes}',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Bill Details Card
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
                  const Text(
                    'Payment Summary',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(booking.serviceTitle, style: const TextStyle(fontSize: 13)),
                      Text('₹${booking.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Convenience & Safety Fee', style: TextStyle(fontSize: 13)),
                      Text('₹0 (Waived)', style: TextStyle(fontSize: 13, color: Colors.green)),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(
                        '₹${booking.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Payment mode: Cash or UPI after service completion',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            if (booking.rating != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'Your Rating: ${booking.rating!.toStringAsFixed(1)} / 5.0',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    if (booking.reviewComment != null && booking.reviewComment!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        booking.reviewComment!,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Bottom Action buttons
            if (booking.status == BookingStatus.confirmed || booking.status == BookingStatus.pending) ...[
              CustomButton(
                text: 'Cancel Booking',
                backgroundColor: Colors.redAccent,
                onPressed: _handleCancel,
              ),
            ] else if (booking.status == BookingStatus.completed && booking.rating == null) ...[
              CustomButton(
                text: 'Rate & Review Service',
                icon: Icons.star_outline_rounded,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewScreen(booking: booking),
                    ),
                  );
                  if (result == true) {
                    setState(() {});
                  }
                },
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(BookingStatus status) {
    final steps = ['Booked', 'Confirmed', 'In Progress', 'Completed'];
    int activeIndex = 0;
    if (status == BookingStatus.confirmed) activeIndex = 1;
    if (status == BookingStatus.inProgress) activeIndex = 2;
    if (status == BookingStatus.completed) activeIndex = 3;
    if (status == BookingStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.centerLeft,
        child: const Text(
          'This booking was cancelled.',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
        ),
      );
    }

    return Row(
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= activeIndex;
        final isCurrent = index == activeIndex;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 3,
                      color: index == 0
                          ? Colors.transparent
                          : (index <= activeIndex ? const Color(0xFF1E88E5) : Colors.grey.shade300),
                    ),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isCompleted ? const Color(0xFF1E88E5) : Colors.grey.shade300,
                      shape: BoxShape.circle,
                      border: isCurrent
                          ? Border.all(color: const Color(0xFF1E88E5).withValues(alpha: 0.3), width: 4)
                          : null,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 13, color: Colors.white)
                        : null,
                  ),
                  Expanded(
                    child: Container(
                      height: 3,
                      color: index == steps.length - 1
                          ? Colors.transparent
                          : (index < activeIndex ? const Color(0xFF1E88E5) : Colors.grey.shade300),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                steps[index],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted ? const Color(0xFF1F2937) : Colors.grey,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
