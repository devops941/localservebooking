import 'package:flutter/material.dart';
import '../../core/models/provider_model.dart';
import '../../core/widgets/custom_textfield.dart';

class ProviderServicesScreen extends StatefulWidget {
  final bool isTab;

  const ProviderServicesScreen({super.key, this.isTab = false});

  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  final List<ProviderServiceItem> _services = List.from(
    ProviderModel.mockProviders.first.services,
  );

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
              CustomTextField(
                controller: titleCtrl,
                labelText: 'Service Title',
                hintText: 'e.g. Inverter Wiring & Installation',
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: priceCtrl,
                labelText: 'Price (₹)',
                hintText: 'e.g. 399',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: durationCtrl,
                labelText: 'Estimated Duration',
                hintText: 'e.g. 1 hr',
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: descCtrl,
                labelText: 'Brief Description',
                hintText: 'What is included in this service...',
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
              setState(() {
                _services.add(
                  ProviderServiceItem(
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
                const SnackBar(content: Text('Service offering added!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Add Service'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Rate Card & Services',
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
      body: ListView.builder(
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
                        Text(srv.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        if (srv.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(srv.description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(srv.duration, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            const SizedBox(width: 14),
                            Text(
                              '₹${srv.price.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E88E5)),
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
        backgroundColor: const Color(0xFF1E88E5),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Service', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
