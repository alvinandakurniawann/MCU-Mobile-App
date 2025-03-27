import 'package:flutter/material.dart';
import '../models/paket_mcu.dart';
import '../services/api_service.dart';

class PaketMCUProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<PaketMCU> _paketList = [];
  bool _isLoading = false;
  String? _error;

  List<PaketMCU> get paketList => _paketList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPaketList() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _paketList = await _apiService.getPaketMCUList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPaket(Map<String, dynamic> paketData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newPaket = await _apiService.createPaketMCU(paketData);
      _paketList.add(newPaket);
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
