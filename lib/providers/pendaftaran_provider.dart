import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pendaftaran_mcu.dart';

class PendaftaranProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<PendaftaranMCU> _pendaftaranList = [];
  String? _error;
  bool _isLoading = false;

  List<PendaftaranMCU> get pendaftaranList => _pendaftaranList;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> loadPendaftaranList() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase.from('pendaftaran').select('''
            *,
            user:user_id(*),
            paket_mcu:paket_mcu_id(*)
          ''').order('created_at', ascending: false);

      _pendaftaranList = (response as List<dynamic>)
          .map((json) => PendaftaranMCU.fromJson(json))
          .toList();
      _error = null;
    } catch (e) {
      _error = 'Terjadi kesalahan saat memuat data pendaftaran';
      _pendaftaranList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPendaftaran({
    required String userId,
    required String paketMcuId,
    required DateTime tanggalPendaftaran,
    required double totalHarga,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase.from('pendaftaran').insert({
        'user_id': userId,
        'paket_mcu_id': paketMcuId,
        'tanggal_pendaftaran': tanggalPendaftaran.toIso8601String(),
        'status': 'pending',
        'total_harga': totalHarga,
      }).select('''
        *,
        user:user_id(*),
        paket_mcu:paket_mcu_id(*)
      ''').single();

      final newPendaftaran = PendaftaranMCU.fromJson(response);
      _pendaftaranList = [newPendaftaran, ..._pendaftaranList];
      _error = null;
      return true;
    } catch (e) {
      _error = 'Terjadi kesalahan saat membuat pendaftaran';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePendaftaran(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('pendaftaran')
          .update(data)
          .eq('id', id)
          .select('''
            *,
            user:user_id(*),
            paket_mcu:paket_mcu_id(*)
          ''').single();

      final updatedPendaftaran = PendaftaranMCU.fromJson(response);
      _pendaftaranList = _pendaftaranList.map((pendaftaran) {
        if (pendaftaran.id == updatedPendaftaran.id) {
          return updatedPendaftaran;
        }
        return pendaftaran;
      }).toList();
      _error = null;
      return true;
    } catch (e) {
      _error = 'Terjadi kesalahan saat memperbarui pendaftaran';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePendaftaran(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase.from('pendaftaran').delete().eq('id', id);
      _pendaftaranList = _pendaftaranList.where((p) => p.id != id).toList();
      _error = null;
      return true;
    } catch (e) {
      _error = 'Terjadi kesalahan saat menghapus pendaftaran';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getLaporanPemasukan({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('pendaftaran')
          .select('*, user:users(*), paket_mcu:paket_mcu(*)')
          .gte('tanggal_pendaftaran', startDate.toIso8601String())
          .lte('tanggal_pendaftaran', endDate.toIso8601String())
          .eq('status', 'completed');

      final List<Map<String, dynamic>> result = [];
      double totalPemasukan = 0;

      for (final item in response as List<dynamic>) {
        final pendaftaran = PendaftaranMCU.fromJson(item);
        totalPemasukan += pendaftaran.totalHarga;
        result.add({
          'tanggal': pendaftaran.tanggalPendaftaran,
          'nama_pasien': pendaftaran.user.namaLengkap,
          'paket_mcu': pendaftaran.paketMcu.namaPaket,
          'total_harga': pendaftaran.totalHarga,
        });
      }

      result.add({
        'total_pemasukan': totalPemasukan,
      });

      return result;
    } catch (e) {
      _error = 'Terjadi kesalahan saat memuat laporan pemasukan';
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
