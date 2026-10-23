import 'package:flutter/material.dart';
import '../../core/services/provider_service.dart';

class AreaSelectionScreen extends StatefulWidget {
  const AreaSelectionScreen({super.key});

  @override
  State<AreaSelectionScreen> createState() => _AreaSelectionScreenState();
}

class _AreaSelectionScreenState extends State<AreaSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<String> _filteredAreas;
  final providerService = ProviderService();

  @override
  void initState() {
    super.initState();
    _filteredAreas = providerService.popularAreas;
  }

  void _filter(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAreas = providerService.popularAreas;
      } else {
        _filteredAreas = providerService.popularAreas
            .where((a) => a.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Select Your Area',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: 'Search locality or pincode...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _filter('');
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
          // GPS Location tile
          ListTile(
            onTap: () {
              providerService.setSelectedArea('Adyar, Chennai');
              Navigator.pop(context, 'Adyar, Chennai');
            },
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.my_location, color: Color(0xFF1E88E5), size: 20),
            ),
            title: const Text(
              'Use Current GPS Location',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E88E5),
                fontSize: 15,
              ),
            ),
            subtitle: const Text(
              'Detects automatically via device GPS',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'POPULAR AREAS IN CHENNAI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          // Areas list
          Expanded(
            child: ListView.separated(
              itemCount: _filteredAreas.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final area = _filteredAreas[index];
                final isSelected = area == providerService.selectedArea;

                return ListTile(
                  onTap: () {
                    providerService.setSelectedArea(area);
                    Navigator.pop(context, area);
                  },
                  leading: Icon(
                    Icons.location_on_outlined,
                    color: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade600,
                    size: 20,
                  ),
                  title: Text(
                    area,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? const Color(0xFF1E88E5) : const Color(0xFF1F2937),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF1E88E5), size: 20)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
