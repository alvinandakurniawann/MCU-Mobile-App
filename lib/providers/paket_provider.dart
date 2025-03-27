import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/paket_mcu.dart';

class PaketProvider with ChangeNotifier {
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

  Future<void> createPaket(PaketMCU paket) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('paket_mcu')
          .insert(paket.toJson())
          .select()
          .single();

      final newPaket = PaketMCU.fromJson(response);
      _paketList = [newPaket, ..._paketList];
      _error = null;
    } catch (e) {
      _error = 'Terjadi kesalahan saat membuat paket MCU baru';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePaket(PaketMCU paket) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('paket_mcu')
          .update(paket.toJson())
          .eq('id', paket.id)
          .select()
          .single();

      final updatedPaket = PaketMCU.fromJson(response);
      _paketList = _paketList.map((p) {
        if (p.id == updatedPaket.id) {
          return updatedPaket;
        }
        return p;
      }).toList();
      _error = null;
    } catch (e) {
      _error = 'Terjadi kesalahan saat memperbarui paket MCU';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePaket(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase.from('paket_mcu').delete().eq('id', id);
      _paketList = _paketList.where((p) => p.id != id).toList();
      _error = null;
    } catch (e) {
      _error = 'Terjadi kesalahan saat menghapus paket MCU';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
