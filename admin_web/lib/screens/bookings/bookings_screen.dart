import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/services/admin_service.dart';
import '../../core/models/booking_model.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  String _statusFilter = 'All';
  bool _initialLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    context.read<AdminService>().loadBookings(
          status: _statusFilter == 'All' ? null : _statusFilter,
        );
    setState(() => _initialLoaded = true);
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<AdminService>();
    final bookings = svc.bookings;

    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    svc.isLoading ? 'Loading...' : 'Total: ${bookings.length} booking(s)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  if (svc.isLoading) ...[
                    const SizedBox(width: 10),
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E88E5)),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  _buildStatusFilter(),
                  const SizedBox(width: 12),
                  IconButton(
                    tooltip: 'Refresh',
                    icon: const Icon(Icons.refresh, size: 20, color: Color(0xFF1E88E5)),
                    onPressed: _load,
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),

        // Table
        Expanded(
          child: !_initialLoaded && svc.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5)))
              : svc.error != null && bookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                          const SizedBox(height: 12),
                          Text(svc.error!, style: const TextStyle(color: Colors.redAccent)),
                          const SizedBox(height: 16),
                          ElevatedButton(onPressed: _load, child: const Text('Retry')),
                        ],
                      ),
                    )
                  : bookings.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment_outlined, size: 56, color: Colors.grey),
                              SizedBox(height: 12),
                              Text('No bookings found.', style: TextStyle(color: Colors.grey, fontSize: 15)),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(const Color(0xFFF3F4F6)),
                              dataRowMinHeight: 52,
                              dataRowMaxHeight: 68,
                              columns: const [
                                DataColumn(label: Text('BOOKING ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                DataColumn(label: Text('CUSTOMER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                DataColumn(label: Text('PROVIDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                DataColumn(label: Text('SERVICE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                DataColumn(label: Text('DATE & TIME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                DataColumn(label: Text('AMOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                DataColumn(label: Text('COMMISSION (15%)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                DataColumn(label: Text('REVIEW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              ],
                              rows: bookings.map((b) => _buildRow(b)).toList(),
                            ),
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    final statuses = ['All', 'Confirmed', 'Completed', 'Cancelled', 'Pending'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButton<String>(
        value: _statusFilter,
        underline: const SizedBox(),
        isDense: true,
        style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
        items: statuses.map((s) {
          return DropdownMenuItem(value: s, child: Text('Status: $s'));
        }).toList(),
        onChanged: (v) {
          setState(() => _statusFilter = v!);
          _load();
        },
      ),
    );
  }

  DataRow _buildRow(BookingModel b) {
    final commission = (b.totalAmount * 0.15).toStringAsFixed(0);
    final dateStr = DateFormat('dd MMM yyyy').format(b.bookingDate);
    final shortId = b.id.length > 8 ? '#${b.id.substring(b.id.length - 8)}' : '#${b.id}';

    return DataRow(cells: [
      DataCell(
        Text(
          shortId,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E88E5)),
        ),
      ),
      DataCell(Text(b.customerName.isEmpty ? '—' : b.customerName, style: const TextStyle(fontSize: 12))),
      DataCell(Text(b.providerName.isEmpty ? '—' : b.providerName, style: const TextStyle(fontSize: 12))),
      DataCell(
        SizedBox(
          width: 140,
          child: Text(b.serviceTitle, style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ),
      DataCell(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateStr, style: const TextStyle(fontSize: 12)),
            if (b.timeSlot.isNotEmpty)
              Text(b.timeSlot, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
      DataCell(
        Text(
          '₹${b.totalAmount.toStringAsFixed(0)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E88E5)),
        ),
      ),
      DataCell(
        Text(
          '₹$commission',
          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
      DataCell(_buildStatusBadge(b.status, b.statusColor)),
      DataCell(_buildReviewCell(b)),
    ]);
  }

  Widget _buildReviewCell(BookingModel b) {
    if (b.rating == null) {
      return Text('—', style: TextStyle(fontSize: 12, color: Colors.grey.shade400));
    }
    return SizedBox(
      width: 130,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: List.generate(5, (i) => Icon(
            i < (b.rating ?? 0) ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 13,
            color: const Color(0xFFF59E0B),
          ))),
          if (b.reviewComment != null && b.reviewComment!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                b.reviewComment!,
                style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
