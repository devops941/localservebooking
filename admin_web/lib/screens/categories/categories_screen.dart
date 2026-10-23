import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/admin_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminService>().loadCategories();
    });
  }

  void _openAddDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Service Category', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildField(nameCtrl, 'Category Name', 'e.g. CCTV & Security', validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Category name is required';
                    return null;
                  }),
                  const SizedBox(height: 12),
                  _buildField(
                    priceCtrl,
                    'Starting Price (₹)',
                    'e.g. 499',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Price is required';
                      if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildField(descCtrl, 'Description', 'Short summary of services offered...'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isSubmitting = true);

                      final err = await context.read<AdminService>().createCategory(
                            name: nameCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            startingPrice: double.parse(priceCtrl.text.trim()),
                          );

                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(err ?? 'Category created successfully!'),
                            backgroundColor: err != null ? Colors.redAccent : Colors.green,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Create Category'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFF374151), fontSize: 13),
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1E88E5)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<AdminService>();
    final categories = svc.categories;

    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    svc.isLoading ? 'Loading...' : 'Total Categories: ${categories.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  if (svc.isLoading) ...[
                    const SizedBox(width: 10),
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E88E5)),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Refresh',
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: () => context.read<AdminService>().loadCategories(),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _openAddDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Category'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),

        // Error banner
        if (svc.error != null && categories.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.red.shade50,
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(svc.error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
                TextButton(
                  onPressed: () => context.read<AdminService>().loadCategories(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),

        // Table
        Expanded(
          child: categories.isEmpty && svc.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5)))
              : categories.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category_outlined, size: 56, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('No categories found.', style: TextStyle(color: Colors.grey, fontSize: 15)),
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
                          dataRowMaxHeight: 68,
                          columns: const [
                            DataColumn(label: Text('CATEGORY NAME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            DataColumn(label: Text('DESCRIPTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            DataColumn(label: Text('STARTING PRICE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            DataColumn(label: Text('PLATFORM COMMISSION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          ],
                          rows: categories.map((cat) => _buildRow(cat)).toList(),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }

  DataRow _buildRow(Map<String, dynamic> cat) {
    final name = cat['name']?.toString() ?? '—';
    final desc = cat['description']?.toString() ?? '';
    final price = (cat['startingPrice'] as num?)?.toDouble() ?? 0.0;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    final colors = [
      Colors.blue,
      Colors.teal,
      Colors.purple,
      Colors.orange,
      Colors.green,
      Colors.indigo,
      Colors.red,
      Colors.cyan,
    ];
    final colorIndex = name.codeUnitAt(0) % colors.length;
    final tagColor = colors[colorIndex];

    return DataRow(cells: [
      DataCell(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: tagColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: TextStyle(color: tagColor, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
      DataCell(
        SizedBox(
          width: 260,
          child: Text(
            desc.isEmpty ? '—' : desc,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      DataCell(
        Text(
          '₹${price.toStringAsFixed(0)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E88E5)),
        ),
      ),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            '15% per booking',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ),
      ),
    ]);
  }
}
