import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/provider_model.dart';

class ProviderService extends ChangeNotifier {
  static final ProviderService _instance = ProviderService._internal();
  factory ProviderService() => _instance;
  ProviderService._internal();

  String _selectedArea = 'Adyar, Chennai';
  String get selectedArea => _selectedArea;

  void setSelectedArea(String area) {
    _selectedArea = area;
    notifyListeners();
  }

  List<String> get popularAreas => [
        'Adyar, Chennai',
        'T. Nagar, Chennai',
        'Anna Nagar, Chennai',
        'Velachery, Chennai',
        'Tambaram, Chennai',
        'Mylapore, Chennai',
        'Guindy, Chennai',
        'Porur, Chennai',
        'OMR - Thoraipakkam, Chennai',
      ];

  List<CategoryModel> getCategories() {
    return CategoryModel.mockCategories;
  }

  CategoryModel? getCategoryById(String categoryId) {
    try {
      return CategoryModel.mockCategories.firstWhere((cat) => cat.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  List<ProviderModel> getProviders({
    String? categoryId,
    String? query,
    String? area,
    bool? verifiedOnly,
  }) {
    List<ProviderModel> list = List.from(ProviderModel.mockProviders);

    if (categoryId != null && categoryId.isNotEmpty) {
      list = list.where((p) => p.categoryId == categoryId).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.profession.toLowerCase().contains(q) ||
            p.area.toLowerCase().contains(q) ||
            p.services.any((s) => s.title.toLowerCase().contains(q));
      }).toList();
    }

    if (area != null && area.trim().isNotEmpty) {
      final a = area.toLowerCase().trim();
      list = list.where((p) => p.area.toLowerCase().contains(a)).toList();
    }

    if (verifiedOnly == true) {
      list = list.where((p) => p.isVerified).toList();
    }

    return list;
  }

  ProviderModel? getProviderById(String id) {
    try {
      return ProviderModel.mockProviders.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ProviderModel> getFeaturedProviders() {
    return ProviderModel.mockProviders.where((p) => p.rating >= 4.8).toList();
  }
}
