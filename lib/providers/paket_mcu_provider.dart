import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/paket_mcu.dart';

class PaketMCUProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<PaketMCU> _paketList = [];
  String? _error;
  bool _isLoading = false;

  List<PaketMCU> get paketList => _paketList;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> loadPaketList() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('paket_mcu')
          .select()
          .order('created_at', ascending: false);

      _paketList = (response as List<dynamic>)
          .map((json) => PaketMCU.fromJson(json))
          .toList();
      _error = null;
    } catch (e) {
      _error = 'Terjadi kesalahan saat memuat data paket MCU';
      _paketList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPaket(Map<String, dynamic> paketData) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from('paket_mcu')
          .insert({
            ...paketData,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      if (response != null) {
        _paketList.add(PaketMCU.fromJson(response));
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating paket: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePaket(String id, Map<String, dynamic> paketData) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from('paket_mcu')
          .update({
            ...paketData,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      if (response != null) {
        final index = _paketList.indexWhere((p) => p.id == id);
        if (index != -1) {
          _paketList[index] = PaketMCU.fromJson(response);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating paket: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePaketMCU(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase.from('paket_mcu').delete().eq('id', id);
      _paketList = _paketList.where((paket) => paket.id != id).toList();
      _error = null;
      return true;
    } catch (e) {
      _error = 'Terjadi kesalahan saat menghapus paket MCU';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
