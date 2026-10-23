import 'package:flutter/material.dart';
import 'api_client.dart';
import '../models/provider_model.dart';
import '../models/area_model.dart';

class ProviderService extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<ProviderModel> _providers = [];
  List<AreaModel> _areas = [];
  bool _isLoading = false;
  bool _isAreasLoading = false;
  String? _error;
  String? _areasError;
  String _selectedArea = '';
  String? _selectedCategoryId;

  List<ProviderModel> get providers => _providers;
  List<AreaModel> get areas => _areas;
  bool get isLoading => _isLoading;
  bool get isAreasLoading => _isAreasLoading;
  String? get error => _error;
  String? get areasError => _areasError;
  String get selectedArea => _selectedArea;
  String? get selectedCategoryId => _selectedCategoryId;

  /// Update selected Madurai area and automatically refresh providers
  void setSelectedArea(String area, {bool refresh = true, String? categoryId}) {
    _selectedArea = area;
    if (categoryId != null) {
      _selectedCategoryId = categoryId;
    }
    notifyListeners();
    if (refresh) {
      loadProviders(area: area, categoryId: _selectedCategoryId);
    }
  }

  /// Update selected category and automatically refresh providers
  void setSelectedCategory(String? categoryId, {bool refresh = true}) {
    _selectedCategoryId = categoryId;
    notifyListeners();
    if (refresh) {
      loadProviders(categoryId: categoryId, area: _selectedArea);
    }
  }

  /// Fetch Madurai city areas from MongoDB database
  Future<void> loadAreas({String? search, bool popularOnly = false}) async {
    _isAreasLoading = true;
    _areasError = null;
    notifyListeners();

    try {
      final res = await _api.get('/areas', queryParameters: {
        'city': 'Madurai',
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (popularOnly) 'popularOnly': 'true',
      });

      final List data = (res.data['data']?['areas']) ?? [];
      _areas = data
          .map((e) => AreaModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _areasError = null;
    } catch (e) {
      _areasError = 'Failed to load Madurai areas from server.';
    } finally {
      _isAreasLoading = false;
      notifyListeners();
    }
  }

  /// Load Admin KYC-approved and active service providers for the selected area & category
  Future<void> loadProviders({
    String? categoryId,
    String? area,
    String? search,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final activeArea = area ?? _selectedArea;
    final activeCategory = categoryId ?? _selectedCategoryId;

    try {
      final res = await _api.get('/providers', queryParameters: {
        'city': 'Madurai',
        if (activeArea.isNotEmpty) 'area': activeArea,
        if (activeCategory != null && activeCategory.isNotEmpty)
          'categoryId': activeCategory,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      });

      final List data = (res.data['data']?['providers']) ?? [];
      _providers = data
          .map((e) => ProviderModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load service providers.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get single provider details and recent ratings
  Future<Map<String, dynamic>> getProviderDetails(String id) async {
    try {
      final res = await _api.get('/providers/$id');
      final d = res.data['data'];
      return {
        'provider':
            ProviderModel.fromJson(d['provider'] as Map<String, dynamic>),
        'reviews': d['reviews'] ?? [],
      };
    } catch (_) {
      return {};
    }
  }
}
