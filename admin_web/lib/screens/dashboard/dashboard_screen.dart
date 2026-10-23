import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/services/admin_service.dart';
import '../../core/models/booking_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final svc = context.read<AdminService>();
      svc.loadStats();
      svc.loadBookings(limit: 10);
    });
  }

  String _fmt(dynamic val) {
    if (val == null) return '—';
    final n = num.tryParse(val.toString());
    if (n == null) return val.toString();
    if (n >= 1000000) return '₹${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '₹${(n / 1000).toStringAsFixed(1)}K';
    return '₹${n.toStringAsFixed(0)}';
  }

  String _fmtCount(dynamic val) {
    if (val == null) return '—';
    return val.toString();
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<AdminService>();
    final stats = svc.stats;
    final bookings = svc.bookings;

    if (svc.isLoading && stats.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5)));
    }

    if (svc.error != null && stats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(svc.error!, style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                svc.loadStats();
                svc.loadBookings(limit: 10);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          LayoutBuilder(
            builder: (ctx, constraints) {
              final cols = constraints.maxWidth > 900 ? 4 : constraints.maxWidth > 600 ? 2 : 1;
              return _buildKpiGrid(stats, cols);
            },
          ),
          const SizedBox(height: 24),

          // Pending Verifications Alert
          if ((stats['pendingVerifications'] ?? 0) > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: Colors.amber, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${stats['pendingVerifications']} Provider KYC Application(s) Require Review',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF92400E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pending providers are awaiting identity verification.',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Recent Bookings Table
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Platform Bookings',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      if (svc.isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E88E5)),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                if (bookings.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        'No bookings found.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
                      columns: const [
                        DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('CUSTOMER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('SERVICE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('PROVIDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('DATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('AMOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('COMMISSION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      ],
                      rows: bookings.take(8).map((b) => _buildBookingRow(b)).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(Map<String, dynamic> stats, int cols) {
    final cards = [
      _KpiData(
        title: 'Total Users',
        value: _fmtCount(stats['totalUsers']),
        subtitle: '${_fmtCount(stats['totalCustomers'])} customers · ${_fmtCount(stats['totalProviders'])} providers',
        icon: Icons.people_outline,
        color: Colors.purple,
      ),
      _KpiData(
        title: 'Total Bookings',
        value: _fmtCount(stats['totalBookings']),
        subtitle: '${_fmtCount(stats['activeBookings'])} active · ${_fmtCount(stats['completedBookings'])} completed',
        icon: Icons.assignment_outlined,
        color: Colors.blue,
      ),
      _KpiData(
        title: 'Gross Volume',
        value: _fmt(stats['grossVolume']),
        subtitle: 'Total platform GMV',
        icon: Icons.currency_rupee,
        color: Colors.green,
      ),
      _KpiData(
        title: 'Platform Commission',
        value: _fmt(stats['platformCommission']),
        subtitle: 'Net admin earnings',
        icon: Icons.account_balance_wallet_outlined,
        color: Colors.orange,
      ),
      _KpiData(
        title: 'Pending Verifications',
        value: _fmtCount(stats['pendingVerifications']),
        subtitle: 'Providers awaiting KYC',
        icon: Icons.verified_user_outlined,
        color: Colors.amber.shade700,
      ),
      _KpiData(
        title: 'Categories',
        value: _fmtCount(stats['totalCategories']),
        subtitle: 'Active service categories',
        icon: Icons.category_outlined,
        color: Colors.teal,
      ),
    ];

    if (cols == 4) {
      return Column(
        children: [
          Row(
            children: cards.take(4).map((c) => Expanded(child: Padding(
              padding: EdgeInsets.only(right: cards.indexOf(c) < 3 ? 16 : 0),
              child: _buildKpiCard(c),
            ))).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildKpiCard(cards[4])),
              const SizedBox(width: 16),
              Expanded(child: _buildKpiCard(cards[5])),
              const Expanded(flex: 2, child: SizedBox()),
            ],
          ),
        ],
      );
    }

    if (cols == 2) {
      final rows = <Widget>[];
      for (int i = 0; i < cards.length; i += 2) {
        rows.add(Row(
          children: [
            Expanded(child: _buildKpiCard(cards[i])),
            const SizedBox(width: 16),
            if (i + 1 < cards.length)
              Expanded(child: _buildKpiCard(cards[i + 1]))
            else
              const Expanded(child: SizedBox()),
          ],
        ));
        if (i + 2 < cards.length) rows.add(const SizedBox(height: 16));
      }
      return Column(children: rows);
    }

    return Column(
      children: cards.map((c) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildKpiCard(c),
      )).toList(),
    );
  }

  Widget _buildKpiCard(_KpiData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, color: data.color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 4),
          Text(
            data.subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  DataRow _buildBookingRow(BookingModel b) {
    final commission = (b.totalAmount * 0.15).toStringAsFixed(0);
    final dateStr = DateFormat('dd MMM').format(b.bookingDate);
    final shortId = b.id.length > 8 ? '#${b.id.substring(b.id.length - 8)}' : '#${b.id}';

    return DataRow(cells: [
      DataCell(Text(shortId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
      DataCell(Text(b.customerName, style: const TextStyle(fontSize: 12))),
      DataCell(Text(b.serviceTitle, style: const TextStyle(fontSize: 12))),
      DataCell(Text(b.providerName, style: const TextStyle(fontSize: 12))),
      DataCell(Text('$dateStr · ${b.timeSlot}', style: const TextStyle(fontSize: 12))),
      DataCell(Text('₹${b.totalAmount.toStringAsFixed(0)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E88E5)))),
      DataCell(Text('₹$commission',
          style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold))),
      DataCell(_buildStatusBadge(b.status, b.statusColor)),
    ]);
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

class _KpiData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _KpiData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
