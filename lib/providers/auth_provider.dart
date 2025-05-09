import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';
import 'user_provider.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  dynamic _currentUser;
  String? _error;
  bool _isLoading = false;
  bool _isAdmin = false;
  late UserProvider _userProvider;

  void initialize(UserProvider userProvider) {
    _userProvider = userProvider;
  }

  dynamic get currentUser => _currentUser;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAdmin => _isAdmin;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<bool> login(String email, String password) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        _error = 'Email atau password salah';
        return false;
      }

      // Ambil data user dari tabel users
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .single();

      _currentUser = User.fromJson(userData);
      _isAdmin = false;
      _error = null;

      if (_userProvider != null) {
        await _userProvider.setCurrentUser(_currentUser);
      }

      return true;
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String username,
    required String namaLengkap,
    String? noKtp,
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

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        _error = 'Gagal registrasi user';
        return false;
      }

      // Simpan data tambahan ke tabel users
      final now = DateTime.now().toIso8601String();
      await _supabase.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'username': username,
        'nama_lengkap': namaLengkap,
        'no_ktp': noKtp,
        'jenis_kelamin': jenisKelamin.toUpperCase(),
        'tempat_lahir': tempatLahir,
        'tanggal_lahir': tanggalLahir,
        'alamat': alamat,
        'no_handphone': noHandphone,
        'created_at': now,
        'updated_at': now,
      });

      return true;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('already registered')) {
        _error = 'Email sudah digunakan';
      } else {
        _error = msg;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (!_isAdmin) {
      await _supabase.auth.signOut();
    }
    _currentUser = null;
    _error = null;
    _isAdmin = false;
    _userProvider.clearCurrentUser();

    // Hapus kredensial yang tersimpan
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
    await prefs.remove('isAdmin');
    await prefs.remove('rememberMe');

    notifyListeners();
  }

  Future<bool> loginAdmin(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final hashedPassword = _hashPassword(password);
      print('DEBUG loginAdmin: username=[32m$username[0m, hash=[34m$hashedPassword[0m');
      final adminResponse = await _supabase
          .from('admin')
          .select()
          .eq('username', username)
          .eq('password', hashedPassword)
          .maybeSingle();

      if (adminResponse == null) {
        _error = 'Username atau password admin salah';
        return false;
      }

      _currentUser = adminResponse;
      _isAdmin = true;
      _error = null;
      return true;
    } catch (e) {
      _error = 'Terjadi kesalahan saat login admin';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerAdmin({
    required String username,
    required String password,
    required String namaLengkap,
    required String jabatan,
  }) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      // Cek username yang sudah ada
      final existingAdmin = await _supabase
          .from('admin')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (existingAdmin != null) {
        _error = 'Username admin sudah digunakan';
        return false;
      }

      // Hash password sebelum disimpan
      final hashedPassword = _hashPassword(password);

      // Insert admin baru
      final now = DateTime.now().toIso8601String();
      await _supabase.from('admin').insert({
        'username': username,
        'password': hashedPassword,
        'nama_lengkap': namaLengkap,
        'jabatan': jabatan,
        'created_at': now,
        'updated_at': now,
      });

      return true;
    } catch (e) {
      _error = 'Terjadi kesalahan saat registrasi admin';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
