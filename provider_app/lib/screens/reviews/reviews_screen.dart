import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/provider_service.dart';
import '../../core/models/booking_model.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  int _selectedFilterStar = 0; // 0 = All

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final providerService = context.watch<ProviderService>();
    final profile = authService.providerProfile;

    final overallRating = (providerService.stats['rating'] ?? profile?.rating ?? 0.0).toDouble();
    final totalReviewsCount = profile?.reviewCount ?? 0;

    final allReviewedBookings = providerService.getReviewedBookings();

    // Calculate rating distribution
    final counts = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final b in allReviewedBookings) {
      final r = b.rating ?? 0;
      if (r >= 1 && r <= 5) {
        counts[r] = (counts[r] ?? 0) + 1;
      }
    }

    final filteredBookings = _selectedFilterStar == 0
        ? allReviewedBookings
        : allReviewedBookings.where((b) => b.rating == _selectedFilterStar).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Customer Reviews & Ratings',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF00897B),
        onRefresh: () async {
          await Future.wait([
            providerService.loadStats(),
            providerService.loadBookings(),
            authService.refreshProfile(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Summary Score Card ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF042F2E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F766E).withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left Score
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              overallRating > 0 ? overallRating.toStringAsFixed(1) : '0.0',
                              style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(5, (index) {
                                final starVal = index + 1;
                                return Icon(
                                  starVal <= overallRating.floor()
                                      ? Icons.star_rounded
                                      : (overallRating - index >= 0.5
                                          ? Icons.star_half_rounded
                                          : Icons.star_outline_rounded),
                                  color: const Color(0xFFFBBF24),
                                  size: 19,
                                );
                              }),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              totalReviewsCount > 0
                                  ? '$totalReviewsCount rating${totalReviewsCount > 1 ? 's' : ''}'
                                  : 'No ratings yet',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 24),
                        Container(width: 1, height: 96, color: Colors.white12),
                        const SizedBox(width: 20),

                        // Right: Star Bar breakdown
                        Expanded(
                          child: Column(
                            children: [5, 4, 3, 2, 1].map((star) {
                              final count = counts[star] ?? 0;
                              final total = allReviewedBookings.isNotEmpty
                                  ? allReviewedBookings.length
                                  : (totalReviewsCount > 0 ? totalReviewsCount : 1);
                              final ratio = allReviewedBookings.isNotEmpty
                                  ? count / total
                                  : (overallRating >= star && overallRating < star + 1 ? 0.7 : 0.0);

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.2),
                                child: Row(
                                  children: [
                                    Text(
                                      '$star',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFBBF24)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: ratio.clamp(0.0, 1.0),
                                          minHeight: 6,
                                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFBBF24)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 18,
                                      child: Text(
                                        '$count',
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Filter Chips ──
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All (${allReviewedBookings.length})', 0),
                    const SizedBox(width: 8),
                    _buildFilterChip('5 ★ (${counts[5] ?? 0})', 5),
                    const SizedBox(width: 8),
                    _buildFilterChip('4 ★ (${counts[4] ?? 0})', 4),
                    const SizedBox(width: 8),
                    _buildFilterChip('3 ★ (${counts[3] ?? 0})', 3),
                    const SizedBox(width: 8),
                    _buildFilterChip('2 ★ (${counts[2] ?? 0})', 2),
                    const SizedBox(width: 8),
                    _buildFilterChip('1 ★ (${counts[1] ?? 0})', 1),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ── Reviews List / Empty State ──
              if (filteredBookings.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.reviews_rounded,
                          size: 44,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedFilterStar == 0
                            ? 'No Customer Reviews Yet'
                            : 'No $_selectedFilterStar-Star Reviews',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _selectedFilterStar == 0
                            ? 'Ratings & written comments from customers will appear here after you complete bookings.'
                            : 'No customer reviews match this star rating filter.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredBookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final booking = filteredBookings[index];
                    return _buildReviewCard(booking);
                  },
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int starValue) {
    final isSelected = _selectedFilterStar == starValue;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterStar = starValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00897B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF00897B) : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00897B).withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(BookingModel booking) {
    final rating = booking.rating ?? 5;
    final customerInitial = (booking.customerName.isNotEmpty)
        ? booking.customerName[0].toUpperCase()
        : 'C';

    final dateStr =
        '${booking.bookingDate.day.toString().padLeft(2, '0')}/${booking.bookingDate.month.toString().padLeft(2, '0')}/${booking.bookingDate.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF00897B).withValues(alpha: 0.12),
                child: Text(
                  customerInitial,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00897B),
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            booking.customerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, size: 10, color: Colors.green),
                              SizedBox(width: 2),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              // Stars
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: const Color(0xFFFBBF24),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Service tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              booking.serviceTitle,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ),

          if (booking.reviewComment != null && booking.reviewComment!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              booking.reviewComment!.trim(),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
