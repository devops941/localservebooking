import 'package:flutter/material.dart';
import '../../core/services/booking_service.dart';

class AdminBookingsScreen extends StatefulWidget {
  final bool isEmbedded;

  const AdminBookingsScreen({super.key, this.isEmbedded = false});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  final bookingService = BookingService();
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final bookings = bookingService.bookings.where((b) {
      if (_selectedStatus == 'All') return true;
      return b.status.name.toLowerCase() == _selectedStatus.toLowerCase();
    }).toList();

    final content = Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Platform Bookings: ${bookings.length}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              DropdownButton<String>(
                value: _selectedStatus,
                underline: const SizedBox(),
                items: ['All', 'Confirmed', 'Completed', 'Cancelled'].map((st) {
                  return DropdownMenuItem(value: st, child: Text('Filter: $st'));
                }).toList(),
                onChanged: (val) => setState(() => _selectedStatus = val!),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                columns: const [
                  DataColumn(label: Text('BOOKING ID', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('CUSTOMER', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('PROVIDER', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('SERVICE', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('DATE & TIME', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('AMOUNT', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('COMMISSION (15%)', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: bookings.map((b) {
                  final commission = (b.totalAmount * 0.15).toStringAsFixed(0);

                  return DataRow(
                    cells: [
                      DataCell(Text('#${b.id}', style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(b.customerName, style: const TextStyle(fontWeight: FontWeight.w500))),
                      DataCell(Text('${b.providerName}\n(${b.providerProfession})', style: const TextStyle(fontSize: 12))),
                      DataCell(Text(b.serviceTitle)),
                      DataCell(Text('${b.bookingDate.day}/${b.bookingDate.month}/${b.bookingDate.year}\n${b.timeSlot}', style: const TextStyle(fontSize: 12))),
                      DataCell(Text('₹${b.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)))),
                      DataCell(Text('₹$commission', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: b.status.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            b.status.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: b.status.color,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );

    if (widget.isEmbedded) return content;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Admin • Platform Bookings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: content,
    );
  }
}
