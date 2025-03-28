import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
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

  Future<bool> login(String username, String password) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final hashedPassword = _hashPassword(password);

      final result =
          await _supabase.from('users').select().eq('username', username);

      if (result.isEmpty) {
        _error = 'Username tidak ditemukan';
        return false;
      }

      final user = result.first;
      if (user['password'] != hashedPassword) {
        _error = 'Password salah';
        return false;
      }

      _currentUser = User.fromJson(user);
      _isAdmin = false;
      _error = null;

      // Update UserProvider
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
    required String username,
    required String password,
    required String namaLengkap,
    required String noKtp,
    String? email,
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

      // Check if username exists
      final existingUser =
          await _supabase.from('users').select().eq('username', username);
      if (existingUser.isNotEmpty) {
        _error = 'Username sudah digunakan';
        return false;
      }

      // Check if KTP exists
      final existingKtp =
          await _supabase.from('users').select().eq('no_ktp', noKtp);
      if (existingKtp.isNotEmpty) {
        _error = 'Nomor KTP sudah terdaftar';
        return false;
      }

      final hashedPassword = _hashPassword(password);
      final now = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('users')
          .insert({
            'username': username,
            'password': hashedPassword,
            'nama_lengkap': namaLengkap,
            'no_ktp': noKtp,
            'email': email,
            'jenis_kelamin': jenisKelamin.toUpperCase(),
            'tempat_lahir': tempatLahir,
            'tanggal_lahir': tanggalLahir,
            'alamat': alamat,
            'no_handphone': noHandphone,
            'created_at': now,
            'updated_at': now,
          })
          .select()
          .single();

      if (response != null) {
        _currentUser = User.fromJson(response);
        return true;
      } else {
        _error = 'Gagal menyimpan data pengguna';
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

  void logout() {
    _currentUser = null;
    _error = null;
    _isAdmin = false;
    _userProvider.clearCurrentUser();
    notifyListeners();
  }

  Future<bool> loginAdmin(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final hashedPassword = _hashPassword(password);

      // Cek apakah admin ada di tabel admin
      final adminResponse = await _supabase
          .from('admin')
          .select('id, username, nama_lengkap, jabatan')
          .eq('username', username)
          .maybeSingle();

      if (adminResponse == null) {
        _error = 'Username admin tidak ditemukan';
        return false;
      }

      // Verifikasi password secara terpisah untuk keamanan
      final passwordCheck = await _supabase
          .from('admin')
          .select('password')
          .eq('username', username)
          .maybeSingle();

      if (passwordCheck == null ||
          passwordCheck['password'] != hashedPassword) {
        _error = 'Password salah';
        return false;
      }

      _currentUser = adminResponse;
      _isAdmin = true;
      _error = null;
      return true;
    } catch (e) {
      _error = 'Username atau password admin salah';
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
      // Cek username yang sudah ada
      final existingAdmin = await _supabase
          .from('admin')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (existingAdmin != null) {
        throw Exception('Username admin sudah digunakan');
      }

      // Hash password sebelum disimpan
      final hashedPassword = _hashPassword(password);

      // Insert admin baru
      await _supabase.from('admin').insert({
        'username': username,
        'password': hashedPassword,
        'nama_lengkap': namaLengkap,
        'jabatan': jabatan,
      });

      return true;
    } catch (e) {
      rethrow;
    }
  }
}
