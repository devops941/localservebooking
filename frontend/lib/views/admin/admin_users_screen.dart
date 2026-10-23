import 'package:flutter/material.dart';

class AdminUsersScreen extends StatefulWidget {
  final bool isEmbedded;

  const AdminUsersScreen({super.key, this.isEmbedded = false});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _selectedRoleFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _users = [
    {
      'name': 'Karthik Raja',
      'email': 'karthik@example.com',
      'phone': '+91 98765 43210',
      'role': 'customer',
      'status': 'active',
      'createdAt': '12 Oct 2026',
    },
    {
      'name': 'Suresh Kumar',
      'email': 'suresh.electric@gmail.com',
      'phone': '+91 98401 23456',
      'role': 'provider',
      'status': 'active',
      'createdAt': '10 Oct 2026',
    },
    {
      'name': 'Muthu Vel',
      'email': 'muthu.plumber@yahoo.com',
      'phone': '+91 98402 34567',
      'role': 'provider',
      'status': 'active',
      'createdAt': '08 Oct 2026',
    },
    {
      'name': 'Priya Ramamurthy',
      'email': 'priya.r@outlook.com',
      'phone': '+91 94441 55667',
      'role': 'customer',
      'status': 'active',
      'createdAt': '14 Oct 2026',
    },
    {
      'name': 'Rajesh Khanna',
      'email': 'rajesh.painting@gmail.com',
      'phone': '+91 98840 99881',
      'role': 'provider',
      'status': 'pending',
      'createdAt': '15 Oct 2026',
    },
    {
      'name': 'System Administrator',
      'email': 'admin@localserve.in',
      'phone': '+91 99999 00000',
      'role': 'admin',
      'status': 'active',
      'createdAt': '01 Oct 2026',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _users.where((u) {
      if (_selectedRoleFilter != 'All' && u['role'] != _selectedRoleFilter.toLowerCase()) {
        return false;
      }
      if (_searchController.text.isNotEmpty) {
        final q = _searchController.text.toLowerCase();
        return u['name'].toLowerCase().contains(q) ||
            u['email'].toLowerCase().contains(q) ||
            u['phone'].toLowerCase().contains(q);
      }
      return true;
    }).toList();

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter toolbar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by user name, email, or mobile...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              DropdownButton<String>(
                value: _selectedRoleFilter,
                underline: const SizedBox(),
                items: ['All', 'Customer', 'Provider', 'Admin'].map((role) {
                  return DropdownMenuItem(value: role, child: Text('Role: $role'));
                }).toList(),
                onChanged: (val) => setState(() => _selectedRoleFilter = val!),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Users Table
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                columns: const [
                  DataColumn(label: Text('USER NAME', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('CONTACT', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('ROLE', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('JOINED', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('ACTION', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: filtered.map((u) {
                  final role = u['role'] as String;
                  final status = u['status'] as String;

                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                              child: Text(u['name'][0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Text(u['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      DataCell(Text('${u['email']}\n${u['phone']}', style: const TextStyle(fontSize: 12))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: role == 'admin'
                                ? Colors.purple.shade50
                                : role == 'provider'
                                    ? Colors.blue.shade50
                                    : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            role.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: role == 'admin'
                                  ? Colors.purple
                                  : role == 'provider'
                                      ? Colors.blue
                                      : Colors.green,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: status == 'active' ? Colors.green.shade50 : Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: status == 'active' ? Colors.green : Colors.amber.shade800,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(u['createdAt'], style: const TextStyle(fontSize: 12))),
                      DataCell(
                        PopupMenuButton<String>(
                          onSelected: (action) {
                            if (action == 'toggle') {
                              setState(() {
                                u['status'] = u['status'] == 'active' ? 'suspended' : 'active';
                              });
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'toggle',
                              child: Text(status == 'active' ? 'Suspend Account' : 'Activate Account'),
                            ),
                            const PopupMenuItem(
                              value: 'view',
                              child: Text('View Activity Log'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );

    if (widget.isEmbedded) return content;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Admin • User Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: content,
    );
  }
}
