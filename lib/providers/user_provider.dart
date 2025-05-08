import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<User> _userList = [];
  User? _currentUser;
  String? _error;
  bool _isLoading = false;

  List<User> get userList => _userList;
  User? get currentUser => _currentUser;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('username', username)
          .eq('password', password)
          .single();

      _currentUser = User.fromJson(response);
      _error = null;
      return true;
    } catch (e) {
      _error = 'Username atau password salah';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String username,
    required String password,
    required String namaLengkap,
    required String noKtp,
    required String jenisKelamin,
    required String tempatLahir,
    required DateTime tanggalLahir,
    required String alamat,
    required String noHandphone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userData = {
        'username': username,
        'password': password,
        'nama_lengkap': namaLengkap,
        'no_ktp': noKtp,
        'jenis_kelamin': jenisKelamin,
        'tempat_lahir': tempatLahir,
        'tanggal_lahir': tanggalLahir.toIso8601String(),
        'alamat': alamat,
        'no_handphone': noHandphone,
      };

      final response =
          await _supabase.from('users').insert(userData).select().single();

      final newUser = User.fromJson(response);
      _userList = [newUser, ..._userList];
      _error = null;
      return true;
    } catch (e) {
      _error = 'Terjadi kesalahan saat mendaftar';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  Future<void> loadUserList() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);

      _userList = (response as List<dynamic>)
          .map((json) => User.fromJson(json))
          .toList();
      _error = null;
    } catch (e) {
      _error = 'Terjadi kesalahan saat memuat data user';
      _userList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await _supabase.from('users').insert(userData).select().single();

      final newUser = User.fromJson(response);
      _userList = [newUser, ..._userList];
      _error = null;
      return true;
    } catch (e) {
      _error = 'Terjadi kesalahan saat membuat data pasien';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser(String id, Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('users')
          .update(userData)
          .eq('id', id)
          .select()
          .single();

      final updatedUser = User.fromJson(response);
      _userList = _userList.map((user) {
        if (user.id == updatedUser.id) {
          return updatedUser;
        }
        return user;
      }).toList();
      _error = null;
      return true;
    } catch (e) {
      _error = 'Terjadi kesalahan saat memperbarui data pasien';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase.from('users').delete().eq('id', id);
      _userList = _userList.where((user) => user.id != id).toList();
      _error = null;
      return true;
    } catch (e) {
      _error = 'Terjadi kesalahan saat menghapus data pasien';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setCurrentUser(User user) async {
    _currentUser = user;
    notifyListeners();
  }

  Future<bool> loadCurrentUser(String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('username', username.trim())
          .single();

      _currentUser = User.fromJson(response);
      _error = null;
      return true;
    } catch (e) {
      _error = 'Gagal memuat data user';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCurrentUser() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String namaLengkap,
    required String noKtp,
    required String jenisKelamin,
    required String tempatLahir,
    required String tanggalLahir,
    required String alamat,
    required String noHandphone,
  }) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      if (_currentUser == null) {
        _error = 'User tidak ditemukan';
        return false;
      }

      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from('users')
          .update({
            'nama_lengkap': namaLengkap,
            'no_ktp': noKtp,
            'jenis_kelamin': jenisKelamin,
            'tempat_lahir': tempatLahir,
            'tanggal_lahir': tanggalLahir,
            'alamat': alamat,
            'no_handphone': noHandphone,
            'updated_at': now,
          })
          .eq('id', _currentUser!.id)
          .select()
          .single();

      if (response != null) {
        _currentUser = User.fromJson(response);
        return true;
      } else {
        _error = 'Gagal memperbarui profil';
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfilePhoto(String photoUrl) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      if (_currentUser == null) {
        _error = 'User tidak ditemukan';
        return false;
      }

      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from('users')
          .update({
            'foto_profil': photoUrl,
            'updated_at': now,
          })
          .eq('id', _currentUser!.id)
          .select()
          .single();

      if (response != null) {
        _currentUser = User.fromJson(response);
        return true;
      } else {
        _error = 'Gagal memperbarui foto profil';
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
