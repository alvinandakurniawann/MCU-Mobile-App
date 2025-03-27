import 'package:flutter/material.dart';
import '../models/pasien.dart';
import '../services/api_service.dart';

class PasienProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Pasien> _pasienList = [];
  bool _isLoading = false;
  String? _error;

  List<Pasien> get pasienList => _pasienList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPasienList() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _pasienList = await _apiService.getPasienList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPasien(Map<String, dynamic> pasienData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newPasien = await _apiService.createPasien(pasienData);
      _pasienList.add(newPasien);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
