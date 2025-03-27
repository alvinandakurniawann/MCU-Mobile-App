import 'package:flutter/material.dart';
import '../models/admin.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  Admin? _currentAdmin;
  bool _isLoading = false;
  String? _error;

  Admin? get currentAdmin => _currentAdmin;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentAdmin != null;

  Future<bool> login(String username, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.login(username, password);
      if (response['success']) {
        _currentAdmin = Admin.fromJson(response['data']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> adminData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.register(adminData);
      if (response['success']) {
        _currentAdmin = Admin.fromJson(response['data']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentAdmin = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
