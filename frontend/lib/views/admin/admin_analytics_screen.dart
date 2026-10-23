import 'package:flutter/material.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  final bool isEmbedded;

  const AdminAnalyticsScreen({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Platform Financial & Growth Analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
          ),
          const SizedBox(height: 6),
          Text(
            'Real-time overview of transaction volume, platform commission, and service demands.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          // Top Metrics Row
          Row(
            children: [
              Expanded(child: _buildMetricCard('Gross Booking Volume', '₹2,48,500', '+18.4% this month', Colors.blue, Icons.currency_rupee)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('Net Commission (15%)', '₹37,275', '+16.2% this month', Colors.green, Icons.account_balance_wallet)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('Completed Jobs', '1,048', '98.2% completion rate', Colors.indigo, Icons.task_alt)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('Active Providers', '142', '+12 joined this week', Colors.purple, Icons.people)),
            ],
          ),
          const SizedBox(height: 28),
          // Demand breakdown
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Categories breakdown
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Top Performing Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      _buildCategoryProgress('Electrician Services', 0.38, '38%', Colors.amber.shade700),
                      _buildCategoryProgress('AC Repair & Servicing', 0.26, '26%', Colors.cyan.shade700),
                      _buildCategoryProgress('Plumbing Solutions', 0.18, '18%', Colors.blue.shade600),
                      _buildCategoryProgress('Home Deep Cleaning', 0.12, '12%', Colors.teal.shade600),
                      _buildCategoryProgress('Carpentry & Woodwork', 0.06, '6%', Colors.brown.shade600),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Locality Heatmap
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Highest Demand Localities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      _buildAreaTile('Adyar, Chennai', '312 bookings', '₹78,000 GMV'),
                      const Divider(height: 16),
                      _buildAreaTile('T. Nagar, Chennai', '248 bookings', '₹62,000 GMV'),
                      const Divider(height: 16),
                      _buildAreaTile('Anna Nagar, Chennai', '196 bookings', '₹51,000 GMV'),
                      const Divider(height: 16),
                      _buildAreaTile('Velachery, Chennai', '164 bookings', '₹42,000 GMV'),
                      const Divider(height: 16),
                      _buildAreaTile('Tambaram, Chennai', '128 bookings', '₹32,000 GMV'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (isEmbedded) return content;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Admin • Platform Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: content,
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCategoryProgress(String name, double progress, String percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Text(percent, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              color: color,
              backgroundColor: Colors.grey.shade200,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaTile(String area, String bookings, String gmv) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(area, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(bookings, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          ],
        ),
        Text(gmv, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E88E5), fontSize: 13)),
      ],
    );
  }
}
