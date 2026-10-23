import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/booking_model.dart';
import '../../core/services/booking_service.dart';
import '../../core/widgets/custom_button.dart';

class BookingDetailsScreen extends StatefulWidget {
  const BookingDetailsScreen({super.key});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  bool _paymentThanksShown = false;

  @override
  void initState() {
    super.initState();
    // Fetch fresh data every time this screen opens so payment status is always current
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingService>().loadBookings();
    });
  }

  void _handleCancel(BuildContext context, String bookingId) {
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
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final bookingService = context.read<BookingService>();
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              final success = await bookingService.cancelBooking(bookingId);
              if (!mounted) return;
              messenger.showSnackBar(
                SnackBar(
                  content: Text(success
                      ? 'Booking has been cancelled.'
                      : 'Failed to cancel booking. Please try again.'),
                  backgroundColor:
                      success ? Colors.redAccent : Colors.orange,
                ),
              );
            },
            child: const Text('Yes, Cancel',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPaymentThanksDialog(BuildContext context, String paymentMethod, double amount) {
    final isCash = paymentMethod == 'cash';
    final isUpi = paymentMethod == 'upi';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCash ? Icons.payments_rounded : isUpi ? Icons.qr_code_rounded : Icons.check_circle_rounded,
                  color: Colors.green.shade600,
                  size: 46,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Payment Received!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 8),
              Text(
                isCash
                    ? 'Cash payment of ₹${amount.toStringAsFixed(0)} has been confirmed by the provider.'
                    : isUpi
                        ? 'UPI payment of ₹${amount.toStringAsFixed(0)} has been confirmed by the provider.'
                        : 'Your payment of ₹${amount.toStringAsFixed(0)} has been confirmed.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.45),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isCash ? Colors.green.shade50 : const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isCash ? Colors.green.shade200 : const Color(0xFFC7D2FE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCash ? Icons.money_rounded : Icons.account_balance_wallet_rounded,
                      size: 16,
                      color: isCash ? Colors.green.shade700 : const Color(0xFF6366F1),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isCash ? 'Paid via Cash' : 'Paid via UPI',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isCash ? Colors.green.shade700 : const Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Great, Thank You!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReviewSheet(BuildContext context, String bookingId) {
    double rating = 4.0;
    final commentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Rate & Review',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Your Rating',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (i) {
                  return IconButton(
                    icon: Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () =>
                        setSheetState(() => rating = (i + 1).toDouble()),
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write your experience...',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final bookingService = context.read<BookingService>();
                    final messenger = ScaffoldMessenger.of(context);
                    final comment = commentCtrl.text.trim();
                    final capturedRating = rating;
                    Navigator.pop(ctx);
                    final result = await bookingService.submitReview(
                        bookingId, capturedRating, comment);
                    if (!context.mounted) return;
                    if (result['success'] == true) {
                      await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (dialogCtx) => Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22)),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.star_rounded,
                                      color: Colors.amber, size: 46),
                                ),
                                const SizedBox(height: 16),
                                const Text('Thank You!',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1F2937))),
                                const SizedBox(height: 8),
                                Text(
                                  'Your review helps others find trusted service providers in Madurai.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      height: 1.45),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      i < capturedRating
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      color: Colors.amber,
                                      size: 26,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(dialogCtx);
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF1E88E5),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                    child: const Text('Back to My Bookings',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(result['message'] ??
                              'Failed to submit review.'),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    }
                  },
                  child: const Text('Submit Review',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingId =
        ModalRoute.of(context)!.settings.arguments as String;
    final booking =
        context.watch<BookingService>().getBookingById(bookingId);

    // Show thank-you dialog once when payment status becomes 'paid'
    if (booking != null && booking.paymentStatus == 'paid' && !_paymentThanksShown) {
      _paymentThanksShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showPaymentThanksDialog(context, booking.paymentMethod, booking.totalAmount);
      });
    }

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
          'Booking #${booking.id.length > 8 ? booking.id.substring(0, 8) : booking.id}',
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1E88E5)),
            tooltip: 'Refresh',
            onPressed: () => context.read<BookingService>().loadBookings(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
        child: Column(
          children: [
            // Status header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(booking.status.icon,
                              color: booking.status.color, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            booking.status.label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: booking.status.color,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₹${booking.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTimeline(booking.status),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Provider info card
            if (booking.providerName.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SERVICE PROVIDER',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 0.4),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              const Color(0xFF1E88E5).withValues(alpha: 0.12),
                          child: Text(
                            booking.providerName.isNotEmpty
                                ? booking.providerName[0]
                                : 'P',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E88E5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.providerName,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                booking.serviceTitle,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.phone,
                              color: Color(0xFF1E88E5), size: 22),
                          tooltip: 'Call Provider',
                          onPressed: () async {
                            final phone = booking.providerPhone.trim();
                            if (phone.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Provider phone number not available.')),
                              );
                              return;
                            }
                            final uri = Uri(scheme: 'tel', path: phone);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Cannot dial $phone. Please call manually.')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),

            // Schedule & address card
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SCHEDULE & ADDRESS',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 0.4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined,
                          size: 18, color: Color(0xFF1E88E5)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${booking.bookingDate} (${booking.timeSlot})',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 18, color: Color(0xFF1E88E5)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          booking.address,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade800,
                              height: 1.3),
                        ),
                      ),
                    ],
                  ),
                  if (booking.notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.note_alt_outlined,
                            size: 18, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Note: ${booking.notes}',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Payment summary card
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PAYMENT SUMMARY',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 0.4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(booking.serviceTitle,
                          style: const TextStyle(fontSize: 13)),
                      Text('₹${booking.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text('Convenience & Safety Fee',
                            style: TextStyle(fontSize: 13)),
                      ),
                      Text('₹0 (Waived)',
                          style: TextStyle(
                              fontSize: 13, color: Colors.green)),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(
                        '₹${booking.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E88E5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Payment Status',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: booking.paymentStatus == 'paid'
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          booking.paymentStatus == 'paid'
                              ? (booking.paymentMethod == 'cash'
                                  ? 'Paid via Cash'
                                  : booking.paymentMethod == 'upi'
                                      ? 'Paid via UPI'
                                      : 'Paid')
                              : 'Payment Pending',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: booking.paymentStatus == 'paid'
                                ? const Color(0xFF059669)
                                : const Color(0xFFD97706),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (booking.bookingNumber.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Booking No: ${booking.bookingNumber}',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ],
              ),
            ),

            // Rating display (if already reviewed)
            if (booking.rating != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: Colors.amber, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Your Rating: ${booking.rating!.toStringAsFixed(1)} / 5.0',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    if (booking.reviewComment != null &&
                        booking.reviewComment!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        booking.reviewComment!,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade800),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),

            // Track on Map button — visible for active bookings
            if (booking.status == BookingStatus.confirmed ||
                booking.status == BookingStatus.inProgress) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/map',
                    arguments: booking,
                  ),
                  icon: const Icon(Icons.map_rounded, size: 18),
                  label: Text(
                    booking.status == BookingStatus.inProgress
                        ? 'Track Provider Live'
                        : 'View on Map',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1565C0),
                    side: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Action buttons
            if (booking.status == BookingStatus.confirmed ||
                booking.status == BookingStatus.pending) ...[
              CustomButton(
                text: 'Cancel Booking',
                backgroundColor: Colors.redAccent,
                onPressed: () => _handleCancel(context, booking.id),
              ),
            ] else if (booking.status == BookingStatus.completed &&
                booking.rating == null) ...[
              CustomButton(
                text: 'Rate & Review Service',
                icon: Icons.star_outline_rounded,
                onPressed: () => _showReviewSheet(context, booking.id),
              ),
            ],
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 2.5,
                      color: index == 0
                          ? Colors.transparent
                          : (index <= activeIndex
                              ? const Color(0xFF1E88E5)
                              : Colors.grey.shade300),
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFF1E88E5)
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                      border: isCurrent
                          ? Border.all(
                              color: const Color(0xFF1E88E5)
                                  .withValues(alpha: 0.3),
                              width: 3)
                          : null,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                        : null,
                  ),
                  Expanded(
                    child: Container(
                      height: 2.5,
                      color: index == steps.length - 1
                          ? Colors.transparent
                          : (index < activeIndex
                              ? const Color(0xFF1E88E5)
                              : Colors.grey.shade300),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                steps[index],
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight:
                      isCompleted ? FontWeight.bold : FontWeight.normal,
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
