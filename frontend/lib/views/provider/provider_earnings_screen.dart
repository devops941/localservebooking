import 'package:flutter/material.dart';

class ProviderEarningsScreen extends StatelessWidget {
  final bool isTab;

  const ProviderEarningsScreen({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Earnings & Wallet',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: isTab
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Wallet Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AVAILABLE WALLET BALANCE', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  const Text('₹12,450.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildWalletStat('This Week', '₹3,240'),
                      _buildWalletStat('This Month', '₹14,800'),
                      _buildWalletStat('Lifetime', '₹84,200'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Withdraw Funds'),
                          content: const Text(
                            'Withdraw ₹12,450 to your registered Bank Account (HDFC Bank ending in **8921)? Funds will be transferred within 2 hours.',
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Withdrawal request initiated successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              child: const Text('Confirm Transfer'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.account_balance, size: 18),
                    label: const Text('Withdraw to Bank Account'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0D47A1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Performance Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricTile('Completed Jobs', '380', Icons.check_circle_outline, Colors.green),
                  _buildMetricTile('Avg Rating', '4.9 ★', Icons.star_outline, Colors.amber),
                  _buildMetricTile('Platform Fee', '15%', Icons.percent, Colors.indigo),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Payout History
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Payouts & Credits',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
            ),
            const SizedBox(height: 10),
            _buildTransactionTile('Job #BK-1082 (Living Room Wiring)', 'Today, 02:30 PM', '+ ₹249.00', Colors.green),
            _buildTransactionTile('Job #BK-1078 (Ceiling Fan Fit)', 'Yesterday', '+ ₹199.00', Colors.green),
            _buildTransactionTile('Bank Payout Transfer (**8921)', '12 Oct 2026', '- ₹5,000.00', Colors.black87),
            _buildTransactionTile('Job #BK-1065 (Fuse repair)', '10 Oct 2026', '+ ₹349.00', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget _buildMetricTile(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildTransactionTile(String title, String date, String amount, Color amountColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.receipt_long, color: Color(0xFF1E88E5), size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: Text(date, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        trailing: Text(
          amount,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: amountColor),
        ),
      ),
    );
  }
}
