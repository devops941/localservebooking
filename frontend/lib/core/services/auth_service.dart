import 'package:flutter/material.dart';
import '../models/customer_model.dart';

enum UserRole {
  customer,
  provider,
  admin;

  String get label {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.provider:
        return 'Service Provider';
      case UserRole.admin:
        return 'Administrator';
    }
  }
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  CustomerModel? _currentUser = CustomerModel.mockCustomer;
  UserRole _currentRole = UserRole.customer;
  bool _isAuthenticated = true;

  CustomerModel? get currentUser => _currentUser;
  UserRole get currentRole => _currentRole;
  bool get isAuthenticated => _isAuthenticated;

  // General login
  Future<bool> login(String email, String password) async {
    return loginCustomer(email, password);
  }

  // Customer Login
  Future<bool> loginCustomer(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (email.isNotEmpty && password.length >= 6) {
      _currentUser = CustomerModel.mockCustomer.copyWith(email: email);
      _currentRole = UserRole.customer;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Service Provider Login
  Future<bool> loginProvider(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (email.isNotEmpty && password.length >= 6) {
      _currentUser = CustomerModel(
        id: 'prov_01',
        name: 'Suresh Kumar',
        email: email,
        phone: '+91 98401 23456',
      );
      _currentRole = UserRole.provider;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Admin Login
  Future<bool> loginAdmin(String email, String password, {String? securityPin}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (email.isNotEmpty && password.length >= 6) {
      _currentUser = CustomerModel(
        id: 'admin_01',
        name: 'System Admin',
        email: email,
        phone: '+91 99999 00000',
      );
      _currentRole = UserRole.admin;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Register Customer
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty) {
      _currentUser = CustomerModel(
        id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
        addresses: CustomerModel.mockCustomer.addresses,
      );
      _currentRole = UserRole.customer;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Register Provider (Partner Onboarding)
  Future<bool> registerProvider({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String profession,
    required String area,
    required double hourlyRate,
    required int experienceYears,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty) {
      _currentUser = CustomerModel(
        id: 'prov_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
      );
      _currentRole = UserRole.provider;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return email.isNotEmpty;
  }

  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  void updateProfile({String? name, String? phone, String? email}) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name ?? _currentUser!.name,
      phone: phone ?? _currentUser!.phone,
      email: email ?? _currentUser!.email,
    );
    notifyListeners();
  }

  void addAddress(AddressModel address) {
    if (_currentUser == null) return;
    final updatedList = List<AddressModel>.from(_currentUser!.addresses)..add(address);
    _currentUser = _currentUser!.copyWith(addresses: updatedList);
    notifyListeners();
  }

  void removeAddress(String addressId) {
    if (_currentUser == null) return;
    final updatedList = _currentUser!.addresses.where((a) => a.id != addressId).toList();
    _currentUser = _currentUser!.copyWith(addresses: updatedList);
    notifyListeners();
  }

  void setDefaultAddress(String addressId) {
    if (_currentUser == null) return;
    final updatedList = _currentUser!.addresses.map((a) {
      return a.copyWith(isDefault: a.id == addressId);
    }).toList();
    _currentUser = _currentUser!.copyWith(addresses: updatedList);
    notifyListeners();
  }
}
