import 'package:flutter/material.dart';
import '../models/pasien.dart';
import '../database/connection.dart';

class PasienProvider with ChangeNotifier {
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

      final response = await SupabaseConnection.client
          .from('pasien')
          .select()
          .order('created_at', ascending: false);

      if (response == null) {
        _error = 'Gagal memuat data pasien';
        return;
      }

      _pasienList =
          (response as List).map((data) => Pasien.fromJson(data)).toList();
      _error = null;
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPasien(Map<String, dynamic> pasienData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await SupabaseConnection.client
          .from('pasien')
          .insert(pasienData)
          .select()
          .single();

      if (response == null) {
        _error = 'Gagal menambahkan pasien';
        return false;
      }

      await loadPasienList();
      return true;
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePasien(String id, Map<String, dynamic> pasienData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await SupabaseConnection.client
          .from('pasien')
          .update(pasienData)
          .eq('id', id)
          .select()
          .single();

      if (response == null) {
        _error = 'Gagal mengupdate pasien';
        return false;
      }

      await loadPasienList();
      return true;
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePasien(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await SupabaseConnection.client
          .from('pasien')
          .delete()
          .eq('id', id)
          .select()
          .single();

      if (response == null) {
        _error = 'Gagal menghapus pasien';
        return false;
      }

      await loadPasienList();
      return true;
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
