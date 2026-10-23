import 'package:flutter/material.dart';

class AdminVerificationsScreen extends StatefulWidget {
  final bool isEmbedded;

  const AdminVerificationsScreen({super.key, this.isEmbedded = false});

  @override
  State<AdminVerificationsScreen> createState() => _AdminVerificationsScreenState();
}

class _AdminVerificationsScreenState extends State<AdminVerificationsScreen> {
  final List<Map<String, dynamic>> _pendingPros = [
    {
      'id': 'V-101',
      'name': 'Rajesh Khanna',
      'profession': 'Professional House Painter',
      'experience': '5 Years',
      'area': 'Velachery, Chennai',
      'phone': '+91 98840 99881',
      'documents': ['Aadhaar Card (Verified)', 'Asian Paints Certified Painter Certificate'],
      'appliedDate': '15 Oct 2026',
    },
    {
      'id': 'V-102',
      'name': 'Kabilan Murugan',
      'profession': 'Senior AC & Refrigerator Mechanic',
      'experience': '6 Years',
      'area': 'Anna Nagar, Chennai',
      'phone': '+91 94440 11223',
      'documents': ['Aadhaar Card (Verified)', 'ITI Refrigeration Diploma Certificate'],
      'appliedDate': '14 Oct 2026',
    },
  ];

  void _verifyProvider(int index, bool approve) {
    final pro = _pendingPros[index];
    setState(() {
      _pendingPros.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          approve
            ? '${pro['name']} approved & verified successfully!'
            : 'Application for ${pro['name']} was rejected.',
        ),
        backgroundColor: approve ? Colors.green : Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _pendingPros.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user_outlined, size: 64, color: Colors.green.shade400),
                const SizedBox(height: 12),
                const Text(
                  'All provider applications have been reviewed!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text('No pending KYC verifications in queue.', style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _pendingPros.length,
            itemBuilder: (context, index) {
              final pro = _pendingPros[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                                child: Text(pro['name'][0], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(pro['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text(pro['profession'], style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: const Text('KYC PENDING', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text('${pro['area']} • Exp: ${pro['experience']}', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                          const SizedBox(width: 16),
                          Icon(Icons.phone_outlined, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(pro['phone'], style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                        ],
                      ),
                      const Divider(height: 24),
                      const Text('Uploaded Documents & Proofs:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      ...(pro['documents'] as List<String>).map((doc) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, size: 16, color: Colors.green),
                              const SizedBox(width: 6),
                              Text(doc, style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => _verifyProvider(index, false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                            ),
                            child: const Text('Reject Application'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => _verifyProvider(index, true),
                            icon: const Icon(Icons.verified, size: 18),
                            label: const Text('Approve & Verify Pro'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );

    if (widget.isEmbedded) return content;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Admin • Provider KYC Queue', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: content,
    );
  }
}
