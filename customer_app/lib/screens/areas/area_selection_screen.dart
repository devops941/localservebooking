import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/provider_service.dart';
import '../../core/models/area_model.dart';

class AreaSelectionScreen extends StatefulWidget {
  const AreaSelectionScreen({super.key});

  @override
  State<AreaSelectionScreen> createState() => _AreaSelectionScreenState();
}

class _AreaSelectionScreenState extends State<AreaSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderService>().loadAreas();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AreaModel> _getFilteredAreas(List<AreaModel> areas) {
    if (_searchQuery.trim().isEmpty) return areas;
    final q = _searchQuery.toLowerCase();
    return areas
        .where((a) =>
            a.name.toLowerCase().contains(q) ||
            a.pincode.contains(q) ||
            a.description.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final providerService = context.watch<ProviderService>();
    final selectedArea = providerService.selectedArea;
    final allAreas = providerService.areas;
    final filteredAreas = _getFilteredAreas(allAreas);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Select Madurai Area',
          style: TextStyle(
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
          // City Indicator Banner (Requirement 1: Madurai City Only)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF1E88E5).withValues(alpha: 0.08),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E88E5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_city_rounded,
                      color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Serving Madurai City Only',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      Text(
                        'Select your local area to find nearby approved specialists',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search Madurai locality (e.g. Anna Nagar, KK Nagar)...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1E88E5), size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Popular Madurai Localities Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MADURAI LOCALITIES',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${filteredAreas.length} Areas',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E88E5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Areas List
          Expanded(
            child: providerService.isAreasLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(strokeWidth: 2),
                        SizedBox(height: 12),
                        Text(
                          'Loading Madurai areas from database...',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : providerService.areasError != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_off_rounded,
                                  size: 48, color: Colors.redAccent),
                              const SizedBox(height: 12),
                              Text(
                                providerService.areasError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.black87, fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () =>
                                    context.read<ProviderService>().loadAreas(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : filteredAreas.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_off_outlined,
                                    size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  'No locality matching "$_searchQuery" found in Madurai.',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredAreas.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final area = filteredAreas[index];
                              final isSelected = selectedArea
                                      .toLowerCase()
                                      .contains(area.name.toLowerCase()) ||
                                  (selectedArea == area.name);

                              return ListTile(
                                onTap: () {
                                  final fullArea = '${area.name}, Madurai';
                                  // Update selected area and refresh providers
                                  context
                                      .read<ProviderService>()
                                      .setSelectedArea(fullArea);
                                  Navigator.pop(context, fullArea);
                                },
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF1E88E5)
                                            .withValues(alpha: 0.12)
                                        : Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.location_on_rounded,
                                    color: isSelected
                                        ? const Color(0xFF1E88E5)
                                        : Colors.grey.shade600,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  area.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    fontSize: 15,
                                    color: isSelected
                                        ? const Color(0xFF1E88E5)
                                        : const Color(0xFF1F2937),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2),
                                    Text(
                                      'Madurai · ${area.pincode.isNotEmpty ? 'PIN: ${area.pincode}' : 'Tamil Nadu'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    if (area.description.isNotEmpty) ...[
                                      const SizedBox(height: 1),
                                      Text(
                                        area.description,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (area.providerCount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981)
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${area.providerCount} active',
                                          style: const TextStyle(
                                            color: Color(0xFF059669),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    else
                                      Text(
                                        '0 active',
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 11,
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    if (isSelected)
                                      const Icon(Icons.check_circle_rounded,
                                          color: Color(0xFF1E88E5), size: 20)
                                    else
                                      Icon(Icons.chevron_right_rounded,
                                          color: Colors.grey.shade400, size: 20),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
