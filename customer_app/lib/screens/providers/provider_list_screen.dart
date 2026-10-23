import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/provider_model.dart';
import '../../core/services/provider_service.dart';
import '../../core/services/category_service.dart';
import '../../core/widgets/provider_card.dart';
import '../../core/utils/responsive.dart';
import '../areas/area_selection_screen.dart';

class ProviderListScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;
  final String? initialQuery;

  const ProviderListScreen({
    super.key,
    this.categoryId,
    this.categoryName,
    this.initialQuery,
  });

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _activeCategoryId;
  String? _activeCategoryName;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _activeCategoryId = widget.categoryId;
    _activeCategoryName = widget.categoryName;

    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryService>().loadCategories();
      final providerService = context.read<ProviderService>();
      providerService.loadProviders(
        categoryId: _activeCategoryId,
        search: widget.initialQuery,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String? catId, String? catName) {
    setState(() {
      _activeCategoryId = catId;
      _activeCategoryName = catName;
    });
    context.read<ProviderService>().loadProviders(
          categoryId: catId,
          search: _searchController.text.trim(),
        );
  }

  List<ProviderModel> _getFilteredProviders(List<ProviderModel> providers) {
    List<ProviderModel> list = providers;

    final query = _searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.profession.toLowerCase().contains(query) ||
              p.categoryName.toLowerCase().contains(query))
          .toList();
    }

    if (_selectedFilter == 'Available Now') {
      list = list.where((p) => p.isAvailable).toList();
    } else if (_selectedFilter == 'Rating 4.8+') {
      list = list.where((p) => p.rating >= 4.8).toList();
    } else if (_selectedFilter == 'Under ₹400') {
      list = list.where((p) => p.hourlyRate <= 400).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final providerService = context.watch<ProviderService>();
    final categoryService = context.watch<CategoryService>();
    final providers = _getFilteredProviders(providerService.providers);
    final selectedArea = providerService.selectedArea;
    final localityName = selectedArea.split(',')[0].trim();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _activeCategoryName ?? 'Approved Specialists',
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Area Selector Chip Bar ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      final selected = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AreaSelectionScreen()),
                      );
                      if (selected != null) {
                        providerService.setSelectedArea(
                          selected,
                          categoryId: _activeCategoryId,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              const Color(0xFF1E88E5).withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 16, color: Color(0xFF1E88E5)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Area: $selectedArea',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1565C0),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E88E5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Change',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search & Filters Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by provider name or service...',
                    prefixIcon:
                        const Icon(Icons.search, color: Colors.grey, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Category Filter Pills (Requirement 6)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // "All Services" chip
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: const Text('All Services'),
                          selected: _activeCategoryId == null,
                          selectedColor: const Color(0xFF1E88E5),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          labelStyle: TextStyle(
                            fontSize: context.rsp(11.5),
                            fontWeight: _activeCategoryId == null
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _activeCategoryId == null
                                ? Colors.white
                                : Colors.black87,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              _onCategoryChanged(null, null);
                            }
                          },
                        ),
                      ),
                      // Dynamic categories from database
                      ...categoryService.categories.map((cat) {
                        final isSelected = _activeCategoryId == cat.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(cat.name),
                            selected: isSelected,
                            selectedColor: const Color(0xFF1E88E5),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            labelStyle: TextStyle(
                              fontSize: context.rsp(11.5),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                _onCategoryChanged(cat.id, cat.name);
                              } else {
                                _onCategoryChanged(null, null);
                              }
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Secondary Sort / Filter Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Available Now', 'Rating 4.8+', 'Under ₹400']
                        .map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          selectedColor:
                              const Color(0xFF1E88E5).withValues(alpha: 0.15),
                          checkmarkColor: const Color(0xFF1E88E5),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          labelStyle: TextStyle(
                            fontSize: context.rsp(10.5),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFF1565C0)
                                : Colors.grey.shade700,
                          ),
                          onSelected: (val) {
                            setState(() => _selectedFilter = filter);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          if (providers.isNotEmpty) ...[
            const SizedBox(height: 4),

            // Count & Status Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$localityName • ${providers.length} Available',
                      style: TextStyle(
                        fontSize: context.rsp(13),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 12, color: Color(0xFF059669)),
                        SizedBox(width: 4),
                        Text(
                          'KYC Approved',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // List or Empty State
          Expanded(
            child: providerService.isLoading
                ? const Center(child: CircularProgressIndicator())
                : providers.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.person_search_rounded,
                                    size: 54, color: Colors.grey.shade400),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _activeCategoryName != null
                                    ? 'No "$_activeCategoryName" providers\nfound in $localityName'
                                    : 'No providers found\nin $localityName',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Try changing the area or selecting a different category.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 12,
                                runSpacing: 10,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      final selected =
                                          await Navigator.push<String>(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const AreaSelectionScreen()),
                                      );
                                      if (selected != null) {
                                        providerService.setSelectedArea(
                                          selected,
                                          categoryId: _activeCategoryId,
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.location_on_rounded,
                                        size: 16),
                                    label: const Text('Change Area'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF1E88E5),
                                      side: const BorderSide(
                                          color: Color(0xFF1E88E5)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            providerService.loadProviders(
                              categoryId: _activeCategoryId,
                              area: selectedArea,
                            ),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: providers.length,
                          itemBuilder: (context, index) {
                            return ProviderCard(provider: providers[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
