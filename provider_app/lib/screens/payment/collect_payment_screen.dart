import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/models/booking_model.dart';
import '../../core/services/provider_service.dart';

class CollectPaymentScreen extends StatefulWidget {
  final BookingModel booking;

  const CollectPaymentScreen({super.key, required this.booking});

  @override
  State<CollectPaymentScreen> createState() => _CollectPaymentScreenState();
}

class _CollectPaymentScreenState extends State<CollectPaymentScreen>
    with SingleTickerProviderStateMixin {
  // Theme colors
  static const Color _primaryTeal = Color(0xFF00897B);
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _background = Color(0xFFF8FAFC);
  static const Color _border = Color(0xFFE2E8F0);

  late TabController _tabController;

  bool _isLoading = true;
  String? _errorMessage;

  // Payment details from backend
  String? _providerUpiId;
  String? _providerName;
  String? _paymentStatus;
  double? _amount;
  String? _bookingNumber;
  String? _customerName;
  String? _serviceTitle;

  // Cash tab state
  bool _cashConfirmChecked = false;
  bool _cashConfirmLoading = false;

  // UPI tab state
  final TextEditingController _upiTxnController = TextEditingController();
  bool _upiConfirmLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPaymentDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _upiTxnController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final service = Provider.of<ProviderService>(context, listen: false);

    try {
      final result = await service.getPaymentDetails(widget.booking.id);

      if (!mounted) return;

      if (result['success'] == true) {
        final payment = result['payment'] as Map<String, dynamic>;
        setState(() {
          _providerUpiId = payment['providerUpiId'] as String?;
          _providerName = payment['providerName'] as String?;
          _paymentStatus = payment['paymentStatus'] as String?;
          _bookingNumber = payment['bookingNumber'] as String?;
          _customerName = payment['customerName'] as String?;
          _serviceTitle = payment['serviceTitle'] as String?;
          final rawAmount = payment['amount'];
          if (rawAmount is num) {
            _amount = rawAmount.toDouble();
          } else if (rawAmount is String) {
            _amount = double.tryParse(rawAmount);
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              result['message'] as String? ?? 'Failed to load payment details.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmCashPayment() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final service = Provider.of<ProviderService>(context, listen: false);

    setState(() => _cashConfirmLoading = true);

    try {
      final result = await service.confirmCashPayment(widget.booking.id);

      if (!mounted) return;

      if (result['success'] == true) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Cash payment confirmed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        navigator.pop(true);
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              result['message'] as String? ?? 'Failed to confirm cash payment.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _cashConfirmLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _cashConfirmLoading = false);
    }
  }

  Future<void> _confirmUpiPayment() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final service = Provider.of<ProviderService>(context, listen: false);

    setState(() => _upiConfirmLoading = true);

    final txnId = _upiTxnController.text.trim();

    try {
      final result = await service.confirmUpiPayment(
        widget.booking.id,
        transactionId: txnId,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('UPI payment confirmed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        navigator.pop(true);
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              result['message'] as String? ?? 'Failed to confirm UPI payment.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _upiConfirmLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _upiConfirmLoading = false);
    }
  }

  String _buildUpiUri() {
    final upiId = Uri.encodeComponent(_providerUpiId ?? '');
    final name = Uri.encodeComponent(_providerName ?? '');
    final amt = _amount?.toStringAsFixed(2) ?? '0.00';
    final note = Uri.encodeComponent(_bookingNumber ?? '');
    return 'upi://pay?pa=$upiId&pn=$name&am=$amt&cu=INR&tn=$note';
  }

  String _formatAmount(double? amount) {
    if (amount == null) return '₹0.00';
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryTeal))
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _primaryTeal,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Collect Payment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (_bookingNumber != null && _bookingNumber!.isNotEmpty)
            Text(
              'Booking #$_bookingNumber',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
        ],
      ),
      bottom: _isLoading || _errorMessage != null
          ? null
          : TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              tabs: const [
                Tab(text: 'Cash'),
                Tab(text: 'UPI'),
              ],
            ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: _textDark),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPaymentDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryTeal,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildHeaderCard(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCashTab(),
              _buildUpiTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    final isPaid = (_paymentStatus ?? '').toLowerCase() == 'paid';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_bookingNumber != null && _bookingNumber!.isNotEmpty)
                      Text(
                        'Booking #$_bookingNumber',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (_serviceTitle != null && _serviceTitle!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _serviceTitle!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                    ],
                    if (_customerName != null && _customerName!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.person_outline,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            _customerName!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isPaid
                        ? Colors.green.shade300
                        : Colors.orange.shade300,
                  ),
                ),
                child: Text(
                  isPaid ? 'Paid' : 'Pending',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isPaid
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: _border, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                _formatAmount(_amount),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _primaryTeal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Cash Tab
  // ---------------------------------------------------------------------------

  Widget _buildCashTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCashReceiptCard(),
          const SizedBox(height: 16),
          _buildCashConfirmCard(),
          const SizedBox(height: 24),
          _buildCashConfirmButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCashReceiptCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 36,
              color: Colors.green.shade600,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Cash Collection',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatAmount(_amount),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: _border),
          const SizedBox(height: 12),
          if (_serviceTitle != null && _serviceTitle!.isNotEmpty)
            _buildInfoRow(Icons.build_outlined, 'Service', _serviceTitle!),
          if (_customerName != null && _customerName!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.person_outline, 'Customer', _customerName!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCashConfirmCard() {
    final amountStr = _formatAmount(_amount);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: CheckboxListTile(
        value: _cashConfirmChecked,
        onChanged: (val) => setState(() => _cashConfirmChecked = val ?? false),
        activeColor: _primaryTeal,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          'I confirm I have received cash of $amountStr from the customer',
          style: const TextStyle(
            fontSize: 14,
            color: _textDark,
            height: 1.4,
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildCashConfirmButton() {
    final isEnabled = _cashConfirmChecked && !_cashConfirmLoading;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isEnabled ? _confirmCashPayment : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? _primaryTeal : Colors.grey.shade300,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: isEnabled ? 2 : 0,
        ),
        child: _cashConfirmLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Confirm Cash Payment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UPI Tab
  // ---------------------------------------------------------------------------

  Widget _buildUpiTab() {
    final hasUpiId =
        _providerUpiId != null && _providerUpiId!.trim().isNotEmpty;

    if (!hasUpiId) {
      return _buildUpiNotSetCard();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildQrCard(),
          const SizedBox(height: 16),
          _buildUpiInstructionsCard(),
          const SizedBox(height: 16),
          _buildUpiTxnField(),
          const SizedBox(height: 24),
          _buildUpiConfirmButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildUpiNotSetCard() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 48, color: Colors.orange.shade600),
              const SizedBox(height: 16),
              const Text(
                'UPI ID Not Set',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'UPI ID not set. Please update your UPI ID in Profile settings to use UPI payments.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrCard() {
    final upiUri = _buildUpiUri();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Scan to Pay',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: QrImageView(
              data: upiUri,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Colors.white,
              errorStateBuilder: (ctx, err) => const SizedBox(
                width: 220,
                height: 220,
                child: Center(
                  child: Text(
                    'Failed to generate QR code',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: _border),
          const SizedBox(height: 16),
          Text(
            _formatAmount(_amount),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _primaryTeal,
            ),
          ),
          const SizedBox(height: 8),
          if (_providerName != null && _providerName!.isNotEmpty)
            Text(
              _providerName!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
          const SizedBox(height: 4),
          if (_providerUpiId != null && _providerUpiId!.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _providerUpiId!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildUpiInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: Colors.blue.shade600),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Ask customer to scan this QR code with any UPI app (Google Pay, PhonePe, Paytm)',
              style: TextStyle(
                fontSize: 13,
                color: _textDark,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpiTxnField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: TextField(
        controller: _upiTxnController,
        decoration: const InputDecoration(
          labelText: 'Enter UPI Transaction ID (optional)',
          labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(Icons.tag, color: Colors.grey),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: const TextStyle(fontSize: 14, color: _textDark),
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
        ],
      ),
    );
  }

  Widget _buildUpiConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _upiConfirmLoading ? null : _confirmUpiPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _upiConfirmLoading ? Colors.grey.shade300 : _primaryTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: _upiConfirmLoading ? 0 : 2,
        ),
        child: _upiConfirmLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'I verified payment received — Confirm UPI',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
