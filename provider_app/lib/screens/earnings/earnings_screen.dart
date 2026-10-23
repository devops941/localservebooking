import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/provider_service.dart';
import '../../core/models/booking_model.dart';

class EarningsScreen extends StatefulWidget {
  final bool isTab;

  const EarningsScreen({super.key, this.isTab = false});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final svc = context.read<ProviderService>();
      svc.loadStats();
      svc.loadBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderService>(
      builder: (context, providerService, _) {
        final stats = providerService.stats;
        final walletBalance = (stats['walletBalance'] ?? 0).toDouble();
        final rating = (stats['rating'] ?? 0).toDouble();
        final reviewCount = stats['reviewCount'] ?? 0;
        final totalCompletedJobs = stats['totalCompletedJobs'] ?? 0;
        final completedBookings = providerService.getCompletedJobs();

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
            leading: widget.isTab
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
          ),
          body: providerService.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00897B)))
              : RefreshIndicator(
                  color: const Color(0xFF00897B),
                  onRefresh: () async {
                    await providerService.loadStats();
                    await providerService.loadBookings();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Wallet Balance Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00897B), Color(0xFF00695C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00897B).withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'AVAILABLE WALLET BALANCE',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '₹${walletBalance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () => _showWithdrawDialog(context, walletBalance),
                                icon: const Icon(Icons.account_balance, size: 18),
                                label: const Text('Withdraw to Bank Account'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF00695C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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
                              _buildMetricTile(
                                'Completed Jobs',
                                '$totalCompletedJobs',
                                Icons.check_circle_outline,
                                Colors.green,
                              ),
                              _buildMetricTile(
                                'Avg Rating',
                                '${rating.toStringAsFixed(1)} ★',
                                Icons.star_outline,
                                Colors.amber,
                              ),
                              _buildMetricTile(
                                'Reviews',
                                '$reviewCount',
                                Icons.reviews_outlined,
                                Colors.indigo,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Payment Breakdown Card
                        Builder(
                          builder: (context) {
                            final allCompleted = providerService.getCompletedJobs();
                            final paid = allCompleted.where((b) => b.paymentStatus == 'paid').toList();
                            final pending = allCompleted.where((b) => b.paymentStatus != 'paid').toList();
                            final cashTotal = paid
                                .where((b) => b.paymentMethod == 'cash')
                                .fold<double>(0, (s, b) => s + b.totalAmount);
                            final upiTotal = paid
                                .where((b) => b.paymentMethod == 'upi')
                                .fold<double>(0, (s, b) => s + b.totalAmount);
                            final pendingTotal = pending.fold<double>(0, (s, b) => s + b.totalAmount);

                            return Container(
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
                                    'Payment Breakdown',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _buildPaymentStat('Cash', '₹${cashTotal.toStringAsFixed(0)}', const Color(0xFF10B981)),
                                      const SizedBox(width: 8),
                                      _buildPaymentStat('UPI', '₹${upiTotal.toStringAsFixed(0)}', const Color(0xFF6366F1)),
                                      const SizedBox(width: 8),
                                      _buildPaymentStat('Pending', '₹${pendingTotal.toStringAsFixed(0)}', const Color(0xFFF59E0B)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Recent Completed Jobs
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Recent Completed Jobs',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        if (completedBookings.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Center(
                              child: Text(
                                'No completed jobs yet.',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ),
                          )
                        else
                          ...completedBookings.take(10).map(
                                (booking) => _buildTransactionTile(booking),
                              ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  void _showWithdrawDialog(BuildContext context, double balance) {
    if (balance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No balance available to withdraw.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final bankNameCtrl = TextEditingController();
    final accountCtrl = TextEditingController();
    final ifscCtrl = TextEditingController();
    final amountCtrl = TextEditingController(text: balance.toStringAsFixed(0));
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Withdraw to Bank',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00897B).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, color: Color(0xFF00897B), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Available: ₹${balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00897B),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildInput(amountCtrl, 'Withdrawal Amount (₹)', Icons.currency_rupee,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              _buildInput(bankNameCtrl, 'Bank Name', Icons.account_balance_outlined),
              const SizedBox(height: 10),
              _buildInput(accountCtrl, 'Account Number', Icons.credit_card,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              _buildInput(ifscCtrl, 'IFSC Code', Icons.code),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00897B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final amt = double.tryParse(amountCtrl.text.trim()) ?? 0;
                          final bank = bankNameCtrl.text.trim();
                          final acc = accountCtrl.text.trim();
                          final ifsc = ifscCtrl.text.trim().toUpperCase();

                          if (amt <= 0 || bank.isEmpty || acc.isEmpty || ifsc.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all fields correctly.'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          if (amt > balance) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Amount exceeds available balance ₹${balance.toStringAsFixed(0)}.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setSheet(() => isSubmitting = true);
                          final result = await context.read<ProviderService>().withdrawWallet(
                                amount: amt,
                                bankName: bank,
                                accountNumber: acc,
                                ifscCode: ifsc,
                              );
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['message'] ?? ''),
                              backgroundColor: result['success'] == true ? Colors.green : Colors.redAccent,
                            ),
                          );
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Submit Withdrawal Request',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Funds credited within 2 business days',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF00897B)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF00897B)),
        ),
      ),
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

  Widget _buildTransactionTile(BookingModel booking) {
    final isPaid = booking.paymentStatus == 'paid';
    final isUpi = booking.paymentMethod == 'upi';
    final isCash = booking.paymentMethod == 'cash';

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
            color: isPaid
                ? const Color(0xFF00897B).withValues(alpha: 0.1)
                : Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isPaid ? Icons.receipt_long : Icons.hourglass_empty_outlined,
            color: isPaid ? const Color(0xFF00897B) : Colors.orange,
            size: 20,
          ),
        ),
        title: Text(
          booking.serviceTitle,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
            if (isPaid)
              Text(
                isCash ? 'Cash' : isUpi ? 'UPI' : booking.paymentMethod,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isCash ? const Color(0xFF059669) : const Color(0xFF6366F1),
                ),
              ),
          ],
        ),
        isThreeLine: isPaid,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isPaid ? '+' : ''} ₹${booking.totalAmount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isPaid ? Colors.green : Colors.orange,
              ),
            ),
            Text(
              isPaid ? 'Received' : 'Pending',
              style: TextStyle(
                fontSize: 10,
                color: isPaid ? Colors.green.shade600 : Colors.orange.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
