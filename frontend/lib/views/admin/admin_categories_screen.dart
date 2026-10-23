import 'package:flutter/material.dart';
import '../../core/models/category_model.dart';
import '../../core/services/provider_service.dart';
import '../../core/widgets/custom_textfield.dart';

class AdminCategoriesScreen extends StatefulWidget {
  final bool isEmbedded;

  const AdminCategoriesScreen({super.key, this.isEmbedded = false});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  late List<CategoryModel> _categories;

  @override
  void initState() {
    super.initState();
    _categories = List.from(ProviderService().getCategories());
  }

  void _openAddCategoryDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Service Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(controller: nameCtrl, labelText: 'Category Name', hintText: 'e.g. CCTV & Security'),
            const SizedBox(height: 12),
            CustomTextField(controller: priceCtrl, labelText: 'Base Price (₹)', hintText: 'e.g. 499', keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            CustomTextField(controller: descCtrl, labelText: 'Description', hintText: 'Short summary of services...'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
              setState(() {
                _categories.add(
                  CategoryModel(
                    id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameCtrl.text.trim(),
                    icon: Icons.miscellaneous_services,
                    description: descCtrl.text.trim(),
                    startingPrice: double.tryParse(priceCtrl.text) ?? 299,
                    providerCount: 0,
                    themeColor: Colors.teal,
                  ),
                );
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Category added to catalog!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Create Category'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Categories: ${_categories.length}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              ElevatedButton.icon(
                onPressed: _openAddCategoryDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Category'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                columns: const [
                  DataColumn(label: Text('CATEGORY', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('STARTING PRICE', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('ACTIVE PROS', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('PLATFORM COMMISSION', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _categories.map((cat) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: cat.themeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(cat.icon, color: cat.themeColor, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      DataCell(Text('₹${cat.startingPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text('${cat.providerCount} Verified')),
                      const DataCell(Text('15% per booking', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600))),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF1E88E5)),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                              onPressed: () {
                                setState(() => _categories.remove(cat));
                              },
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
        title: const Text('Admin • Service Categories', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: content,
    );
  }
}
