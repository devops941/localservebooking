import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/admin_service.dart';
import '../../core/models/user_model.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _roleFilter = 'All';
  String _statusFilter = 'All';
  final TextEditingController _searchCtrl = TextEditingController();
  bool _initialLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    context.read<AdminService>().loadUsers(
          role: _roleFilter == 'All' ? null : _roleFilter.toLowerCase(),
          status: _statusFilter == 'All' ? null : _statusFilter.toLowerCase(),
          search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
        );
    setState(() => _initialLoaded = true);
  }

  Future<void> _toggleStatus(UserModel user) async {
    final newStatus = user.status == 'active' ? 'suspended' : 'active';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${newStatus == 'active' ? 'Activate' : 'Suspend'} User'),
        content: Text(
          'Are you sure you want to ${newStatus == 'active' ? 'activate' : 'suspend'} ${user.name}?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'active' ? Colors.green : Colors.redAccent,
            ),
            child: Text(
              newStatus == 'active' ? 'Activate' : 'Suspend',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final err = await context.read<AdminService>().updateUserStatus(user.id, newStatus);
    if (mounted && err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.redAccent),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name} has been ${newStatus == 'active' ? 'activated' : 'suspended'}.'),
          backgroundColor: newStatus == 'active' ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<AdminService>();
    final users = svc.users;

    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onSubmitted: (_) => _load(),
                  decoration: InputDecoration(
                    hintText: 'Search by name, email or phone...',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              _load();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              _FilterDropdown(
                label: 'Role',
                value: _roleFilter,
                items: const ['All', 'Customer', 'Provider', 'Admin'],
                onChanged: (v) {
                  setState(() => _roleFilter = v);
                  _load();
                },
              ),
              const SizedBox(width: 12),
              _FilterDropdown(
                label: 'Status',
                value: _statusFilter,
                items: const ['All', 'Active', 'Suspended', 'Pending'],
                onChanged: (v) {
                  setState(() => _statusFilter = v);
                  _load();
                },
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),

        // Summary bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: const Color(0xFFF9FAFB),
          child: Row(
            children: [
              Text(
                svc.isLoading ? 'Loading...' : '${users.length} user(s) found',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),

        // Table
        Expanded(
          child: svc.isLoading && !_initialLoaded
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5)))
              : svc.error != null && users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
                          const SizedBox(height: 8),
                          Text(svc.error!, style: const TextStyle(color: Colors.redAccent)),
                          const SizedBox(height: 12),
                          ElevatedButton(onPressed: _load, child: const Text('Retry')),
                        ],
                      ),
                    )
                  : users.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('No users found.', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(const Color(0xFFF3F4F6)),
                              dataRowMinHeight: 52,
                              dataRowMaxHeight: 64,
                              columns: const [
                                DataColumn(label: Text('USER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                DataColumn(label: Text('EMAIL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                DataColumn(label: Text('PHONE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                DataColumn(label: Text('ROLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              ],
                              rows: users.map((u) => _buildRow(u)).toList(),
                            ),
                          ),
                        ),
        ),
      ],
    );
  }

  DataRow _buildRow(UserModel u) {
    final roleColor = _roleColor(u.role);
    final statusColor = _statusColor(u.status);

    return DataRow(cells: [
      DataCell(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: const Color(0xFF1E88E5).withValues(alpha: 0.12),
              child: Text(
                u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
              ),
            ),
            const SizedBox(width: 10),
            Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
      DataCell(Text(u.email, style: const TextStyle(fontSize: 12))),
      DataCell(Text(u.phone.isEmpty ? '—' : u.phone, style: const TextStyle(fontSize: 12))),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: roleColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            u.role.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: roleColor),
          ),
        ),
      ),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            u.status.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
          ),
        ),
      ),
      DataCell(
        u.role == 'admin'
            ? const Text('—', style: TextStyle(color: Colors.grey, fontSize: 12))
            : PopupMenuButton<String>(
                tooltip: 'Actions',
                onSelected: (action) {
                  if (action == 'toggle') _toggleStatus(u);
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          u.status == 'active' ? Icons.block : Icons.check_circle_outline,
                          size: 16,
                          color: u.status == 'active' ? Colors.redAccent : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(u.status == 'active' ? 'Suspend Account' : 'Activate Account'),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Actions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, size: 16),
                    ],
                  ),
                ),
              ),
      ),
    ]);
  }

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'provider':
        return const Color(0xFF1E88E5);
      default:
        return Colors.green;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'suspended':
        return Colors.redAccent;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        isDense: true,
        style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text('$label: $item'));
        }).toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }
}
