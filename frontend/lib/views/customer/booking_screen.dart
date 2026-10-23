import 'package:flutter/material.dart';
import '../../core/models/customer_model.dart';
import '../../core/models/provider_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/booking_service.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import 'booking_success_screen.dart';
import 'my_addresses_screen.dart';

class BookingScreen extends StatefulWidget {
  final ProviderModel provider;
  final ProviderServiceItem? initialService;

  const BookingScreen({
    super.key,
    required this.provider,
    this.initialService,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late ProviderServiceItem _selectedService;
  late DateTime _selectedDate;
  String _selectedSlot = '10:00 AM - 11:30 AM';
  AddressModel? _selectedAddress;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

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
    _selectedService = widget.initialService ??
        (widget.provider.services.isNotEmpty
            ? widget.provider.services.first
            : ProviderServiceItem(
                id: 'gen',
                title: widget.provider.profession,
                price: widget.provider.hourlyRate,
              ));

    _selectedDate = DateTime.now().add(const Duration(days: 1));

    final addresses = AuthService().currentUser?.addresses ?? [];
    if (addresses.isNotEmpty) {
      _selectedAddress = addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => addresses.first,
      );
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _handleConfirmBooking() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or add a service address.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final customer = AuthService().currentUser ?? CustomerModel.mockCustomer;

    final booking = BookingService().createBooking(
      customerId: customer.id,
      customerName: customer.name,
      customerPhone: customer.phone,
      providerId: widget.provider.id,
      providerName: widget.provider.name,
      providerProfession: widget.provider.profession,
      serviceCategory: widget.provider.profession,
      serviceTitle: _selectedService.title,
      bookingDate: _selectedDate,
      timeSlot: _selectedSlot,
      totalAmount: _selectedService.price,
      address:
          '${_selectedAddress!.fullAddress}, ${_selectedAddress!.area}, ${_selectedAddress!.city} - ${_selectedAddress!.pincode}',
      notes: _notesController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BookingSuccessScreen(booking: booking),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addresses = AuthService().currentUser?.addresses ?? [];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Book Service',
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider info header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF1E88E5).withValues(alpha: 0.12),
                    child: Text(
                      widget.provider.name[0],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E88E5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.provider.name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.provider.profession,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(
                        widget.provider.rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Select Service
            const Text(
              'Select Specific Service',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: widget.provider.services.map((service) {
                final isSelected = _selectedService.id == service.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade200,
                        width: isSelected ? 1.8 : 1,
                      ),
                    ),
                    child: ListTile(
                      onTap: () => setState(() => _selectedService = service),
                      title: Text(
                        service.title,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        '${service.duration} • ${service.description}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        '₹${service.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Select Date
            const Text(
              'Select Booking Date',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 74,
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
                      width: 62,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1E88E5) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white70 : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Time Slots
            const Text(
              'Select Time Slot',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeSlots.map((slot) {
                final isSelected = _selectedSlot == slot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: isSelected,
                  selectedColor: const Color(0xFF1E88E5),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedSlot = slot);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Service Address
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Service Address',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyAddressesScreen()),
                    );
                    setState(() {
                      final updated = AuthService().currentUser?.addresses ?? [];
                      if (updated.isNotEmpty) {
                        _selectedAddress = updated.firstWhere(
                          (a) => a.isDefault,
                          orElse: () => updated.first,
                        );
                      }
                    });
                  },
                  child: const Text('Manage', style: TextStyle(color: Color(0xFF1E88E5))),
                ),
              ],
            ),
            if (addresses.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'No address found. Please add an address.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyAddressesScreen()),
                      ),
                      child: const Text('Add Now'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Column(
                children: addresses.map((addr) {
                  final isSelected = _selectedAddress?.id == addr.id;
                  return InkWell(
                    onTap: () => setState(() => _selectedAddress = addr),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade200,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? const Color(0xFF1E88E5) : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${addr.label} - ${addr.fullAddress}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${addr.area}, ${addr.city} - ${addr.pincode}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),

            // Additional Notes
            CustomTextField(
              controller: _notesController,
              labelText: 'Instructions / Notes for Provider (Optional)',
              hintText: 'e.g. Please bring extra 10A switch, bell is broken, etc.',
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Price Breakdown Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Service Charge', style: TextStyle(color: Colors.grey)),
                      Text('₹${_selectedService.price.toStringAsFixed(0)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Safety & Inspection Fee', style: TextStyle(color: Colors.grey)),
                      Text('FREE', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Estimated Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        '₹${_selectedService.price.toStringAsFixed(0)}',
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

            CustomButton(
              text: 'Confirm & Book Service',
              isLoading: _isLoading,
              onPressed: _handleConfirmBooking,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
