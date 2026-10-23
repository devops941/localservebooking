import 'package:flutter/material.dart';
import '../../core/models/customer_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';

class MyAddressesScreen extends StatefulWidget {
  const MyAddressesScreen({super.key});

  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
  final authService = AuthService();

  void _openAddAddressModal() {
    final labelCtrl = TextEditingController(text: 'Home');
    final addressCtrl = TextEditingController();
    final landmarkCtrl = TextEditingController();
    final areaCtrl = TextEditingController(text: 'Adyar');
    final pincodeCtrl = TextEditingController(text: '600020');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add New Address',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: labelCtrl,
                  labelText: 'Address Label',
                  hintText: 'e.g. Home, Office, Parents',
                  validator: (v) => v!.isEmpty ? 'Label is required' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: addressCtrl,
                  labelText: 'House / Flat / Street Name',
                  hintText: 'e.g. Flat 3B, Sunshine Apartments, 3rd Cross',
                  validator: (v) => v!.isEmpty ? 'Address is required' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: landmarkCtrl,
                  labelText: 'Landmark (Optional)',
                  hintText: 'e.g. Near Metro Station / Opposite Park',
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: areaCtrl,
                        labelText: 'Area / Locality',
                        hintText: 'e.g. Adyar',
                        validator: (v) => v!.isEmpty ? 'Area required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: pincodeCtrl,
                        labelText: 'Pincode',
                        hintText: 'e.g. 600020',
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Pincode required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Save Address',
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    final newAddr = AddressModel(
                      id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
                      label: labelCtrl.text.trim(),
                      fullAddress: addressCtrl.text.trim(),
                      landmark: landmarkCtrl.text.trim(),
                      area: areaCtrl.text.trim(),
                      city: 'Chennai',
                      pincode: pincodeCtrl.text.trim(),
                      isDefault: (authService.currentUser?.addresses.isEmpty ?? true),
                    );
                    authService.addAddress(newAddr);
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addresses = authService.currentUser?.addresses ?? [];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Saved Addresses',
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('No addresses saved yet.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _openAddAddressModal,
                    child: const Text('Add Your First Address'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final addr = addresses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: addr.isDefault ? const Color(0xFF1E88E5) : Colors.grey.shade200,
                      width: addr.isDefault ? 1.5 : 1,
                    ),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                addr.label.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF1E88E5),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            if (addr.isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'DEFAULT',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                            const Spacer(),
                            PopupMenuButton<String>(
                              onSelected: (val) {
                                if (val == 'default') {
                                  authService.setDefaultAddress(addr.id);
                                  setState(() {});
                                } else if (val == 'delete') {
                                  authService.removeAddress(addr.id);
                                  setState(() {});
                                }
                              },
                              itemBuilder: (context) => [
                                if (!addr.isDefault)
                                  const PopupMenuItem(
                                    value: 'default',
                                    child: Text('Set as Default'),
                                  ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete Address', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          addr.fullAddress,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        if (addr.landmark.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Landmark: ${addr.landmark}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '${addr.area}, ${addr.city} - ${addr.pincode}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddAddressModal,
        backgroundColor: const Color(0xFF1E88E5),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Address', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
