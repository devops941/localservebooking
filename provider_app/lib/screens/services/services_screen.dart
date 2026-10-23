import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';

class _ServiceItem {
  final String id;
  final String title;
  final double price;
  final String duration;
  final String description;

  _ServiceItem({
    required this.id,
    required this.title,
    required this.price,
    required this.duration,
    required this.description,
  });
}

class ServicesScreen extends StatefulWidget {
  final bool isTab;

  const ServicesScreen({super.key, this.isTab = false});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final List<_ServiceItem> _services = [
    _ServiceItem(
      id: 'srv_1',
      title: 'Basic Electrical Inspection',
      price: 199,
      duration: '30 mins',
      description: 'Full electrical panel and wiring inspection.',
    ),
    _ServiceItem(
      id: 'srv_2',
      title: 'Ceiling Fan Installation',
      price: 249,
      duration: '45 mins',
      description: 'Installation of ceiling fan with wiring.',
    ),
    _ServiceItem(
      id: 'srv_3',
      title: 'MCB / Distribution Box Repair',
      price: 349,
      duration: '1 hr',
      description: 'Troubleshoot and repair circuit breakers.',
    ),
  ];

  void _openAddServiceDialog() {
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '45 mins');
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Service Offering'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Service Title',
                  hintText: 'e.g. Inverter Wiring & Installation',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price (₹)',
                  hintText: 'e.g. 399',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: durationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Estimated Duration',
                  hintText: 'e.g. 1 hr',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Brief Description',
                  hintText: 'What is included in this service...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
              setState(() {
                _services.add(
                  _ServiceItem(
                    id: 'srv_${DateTime.now().millisecondsSinceEpoch}',
                    title: titleCtrl.text.trim(),
                    price: double.tryParse(priceCtrl.text) ?? 249,
                    duration: durationCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                  ),
                );
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Service offering added!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00897B)),
            child: const Text('Add Service'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final profession = authService.providerProfile?.profession ?? 'Services';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '$profession Rate Card',
          style: const TextStyle(
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
      body: _services.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sell_outlined, size: 54, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'No services added yet.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap + to add your service offerings.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _services.length,
              itemBuilder: (context, index) {
                final srv = _services[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                srv.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              if (srv.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  srv.description,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    srv.duration,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    '₹${srv.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF00897B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () {
                            setState(() => _services.removeAt(index));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddServiceDialog,
        backgroundColor: const Color(0xFF00897B),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Service', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
