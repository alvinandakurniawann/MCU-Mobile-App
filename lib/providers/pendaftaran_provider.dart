import 'package:flutter/material.dart';
import '../models/pendaftaran_mcu.dart';
import '../services/api_service.dart';

class PendaftaranProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<PendaftaranMCU> _pendaftaranList = [];
  bool _isLoading = false;
  String? _error;

  List<PendaftaranMCU> get pendaftaranList => _pendaftaranList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPendaftaranList() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _pendaftaranList = await _apiService.getPendaftaranList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPendaftaran(Map<String, dynamic> pendaftaranData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newPendaftaran =
          await _apiService.createPendaftaran(pendaftaranData);
      _pendaftaranList.add(newPendaftaran);
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

  Future<Map<String, dynamic>> getLaporanPemasukan(
      String startDate, String endDate) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final report = await _apiService.getLaporanPemasukan(startDate, endDate);
      _isLoading = false;
      notifyListeners();
      return report;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {};
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
