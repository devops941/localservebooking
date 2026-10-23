import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/provider_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/booking_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/provider_service.dart';
import '../../core/widgets/custom_button.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late DateTime _selectedDate;
  String _selectedSlot = '10:00 AM - 11:30 AM';
  final TextEditingController _streetAddressController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isInit = false;

  final List<String> _timeSlots = [
    '09:00 AM - 10:30 AM',
    '10:00 AM - 11:30 AM',
    '12:00 PM - 01:30 PM',
    '02:30 PM - 04:00 PM',
    '04:30 PM - 06:00 PM',
    '06:30 PM - 08:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _isInit = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is ProviderModel) {
        final rawArea = args.area.split(',')[0].trim();
        _areaController.text = rawArea.isNotEmpty
            ? rawArea
            : context.read<ProviderService>().selectedArea.split(',')[0].trim();
      }
      final user = AuthService().currentUser;
      if (user != null && _streetAddressController.text.isEmpty) {
        // Leave for customer to specify their door / street
      }
    }
  }

  @override
  void dispose() {
    _streetAddressController.dispose();
    _areaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleConfirmBooking(ProviderModel provider) async {
    final street = _streetAddressController.text.trim();
    final area = _areaController.text.trim();

    if (street.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your house/door number and street address.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (area.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter or select a Madurai area.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Capture BookingService ref before async gap
    final bookingService = context.read<BookingService>();

    // Silently capture GPS for map feature — does not block booking if denied
    final position = await LocationService.getCurrentPosition();

    final bookingDate =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    final addressPayload = {
      'fullAddress': street,
      'area': area,
      'city': 'Madurai',
    };

    final result = await bookingService.createBooking(
          providerId: provider.id,
          serviceTitle: provider.profession,
          categoryName: provider.categoryName.isNotEmpty
              ? provider.categoryName
              : provider.profession,
          bookingDate: bookingDate,
          timeSlot: _selectedSlot,
          address: addressPayload,
          totalAmount: provider.hourlyRate,
          notes: _notesController.text.trim(),
          customerLat: position?.latitude,
          customerLng: position?.longitude,
        );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking confirmed successfully!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/bookings',
        (route) => route.settings.name == '/home',
      );
    } else {
      final msg = result['message'] ?? '';
      final isRoleError = msg.toLowerCase().contains('not authorized') ||
          msg.toLowerCase().contains('access denied');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRoleError
                ? 'This account is registered as a service provider. Please login with a customer account to book services.'
                : msg.isNotEmpty
                    ? msg
                    : 'Booking failed. Please try again.',
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        ModalRoute.of(context)?.settings.arguments as ProviderModel?;

    if (provider == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Book Service',
            style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 17),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Color(0xFF1E293B), size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'Provider information not available.\nPlease go back and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final locality = provider.area.split(',')[0].trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Book Service',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1E293B), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider info compact card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                    child: Text(
                      provider.name.isNotEmpty ? provider.name[0] : 'P',
                      style: const TextStyle(
                        fontSize: 16,
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
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                provider.name,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (provider.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified,
                                  size: 15, color: Color(0xFF1E88E5)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${provider.profession} • $locality, Madurai',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 15, color: Color(0xFFD97706)),
                        const SizedBox(width: 2),
                        Text(
                          provider.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Date Selection
            _buildSectionHeader('Select Booking Date', Icons.calendar_month_outlined),
            const SizedBox(height: 8),
            SizedBox(
              height: 68,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index));
                  final isSelected = _selectedDate.day == date.day &&
                      _selectedDate.month == date.month;

                  final dayName = index == 0
                      ? 'Today'
                      : index == 1
                          ? 'Tmrw'
                          : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7];

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = date),
                    child: Container(
                      width: 58,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1E88E5) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1E88E5)
                              : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF1E88E5).withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayName,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? Colors.white.withValues(alpha: 0.85) : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // Time Slots in 2-Column Compact Grid
            _buildSectionHeader('Select Time Slot', Icons.access_time_rounded),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _timeSlots.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 3.2,
              ),
              itemBuilder: (context, index) {
                final slot = _timeSlots[index];
                final isSelected = _selectedSlot == slot;
                return InkWell(
                  onTap: () => setState(() => _selectedSlot = slot),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1E88E5)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1E88E5)
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSelected) ...[
                          const Icon(Icons.check_circle_rounded,
                              size: 13, color: Colors.white),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            slot,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF334155),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            // Service Address Section
            _buildSectionHeader('Service Address (Madurai)', Icons.location_on_outlined),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Address field
                  TextField(
                    controller: _streetAddressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'House / Door No & Street Name *',
                      labelStyle: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                      hintText: 'e.g. Door No. 14, 2nd Main Road',
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.home_outlined, size: 20, color: Color(0xFF1E88E5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF1E88E5)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Area and City row
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: TextField(
                          controller: _areaController,
                          decoration: InputDecoration(
                            labelText: 'Madurai Area *',
                            labelStyle: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                            prefixIcon: const Icon(Icons.place_outlined, size: 18, color: Color(0xFF1E88E5)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF1E88E5)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 4,
                        child: Container(
                          height: 48,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.location_city, size: 16, color: Colors.grey),
                              SizedBox(width: 6),
                              Text(
                                'Madurai',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Notes / Instructions
                  TextField(
                    controller: _notesController,
                    maxLines: 1,
                    decoration: InputDecoration(
                      labelText: 'Notes / Instructions (Optional)',
                      labelStyle: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                      hintText: 'e.g. Ring bell 2 times, bring switch, etc.',
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.notes_rounded, size: 18, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF1E88E5)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Price Summary Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Service Charge (${provider.profession})',
                          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600)),
                      Text('₹${provider.hourlyRate.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Safety & Inspection Fee',
                          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600)),
                      const Text(
                        'FREE',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Estimated Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        '₹${provider.hourlyRate.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              top: BorderSide(color: Color(0xFFE2E8F0)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: CustomButton(
            text: 'Confirm & Book Service',
            isLoading: _isLoading,
            onPressed: () => _handleConfirmBooking(provider),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1E88E5)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
