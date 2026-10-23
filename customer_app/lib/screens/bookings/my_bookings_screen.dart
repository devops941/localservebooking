import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/booking_model.dart';
import '../../core/services/booking_service.dart';

class MyBookingsScreen extends StatefulWidget {
  final bool isTab;

  const MyBookingsScreen({super.key, this.isTab = false});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingService>().loadBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingService = context.watch<BookingService>();
    final upcoming = bookingService.upcoming;
    final completed = bookingService.completed;
    final cancelled = bookingService.cancelled;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: widget.isTab
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.black87, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1E88E5),
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: const Color(0xFF1E88E5),
          indicatorWeight: 3,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: 'Active (${upcoming.length})'),
            Tab(text: 'Completed (${completed.length})'),
            Tab(text: 'Cancelled (${cancelled.length})'),
          ],
        ),
      ),
      body: bookingService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(context, upcoming,
                    'No active bookings currently.'),
                _buildBookingList(context, completed,
                    'No completed service bookings yet.'),
                _buildBookingList(context, cancelled, 'No cancelled bookings.'),
              ],
            ),
    );
  }

  Widget _buildBookingList(
      BuildContext context, List<BookingModel> list, String emptyMessage) {
    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<BookingService>().loadBookings(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 320,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 54, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      emptyMessage,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<BookingService>().loadBookings(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final booking = list[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            elevation: 0,
            color: Colors.white,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/booking_details',
                  arguments: booking.id,
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Service Title & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            booking.serviceTitle,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: booking.status.color
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            booking.status.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: booking.status.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Provider name
                    if (booking.providerName.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.person_outline,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            booking.providerName,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    // Date & Time
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${booking.bookingDate} • ${booking.timeSlot}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    // Bottom: ID & Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ID: ${booking.id.length > 8 ? booking.id.substring(0, 8) : booking.id}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                        Row(
                          children: [
                            Text(
                              '₹${booking.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E88E5),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_ios,
                                size: 12, color: Colors.grey),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
