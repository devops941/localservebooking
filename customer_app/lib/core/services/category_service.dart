import 'package:flutter/material.dart';
import 'api_client.dart';
import '../models/category_model.dart';

class CategoryService extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/categories');
      final List data = (res.data['data']?['categories']) ?? [];
      _categories = data.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load categories';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
