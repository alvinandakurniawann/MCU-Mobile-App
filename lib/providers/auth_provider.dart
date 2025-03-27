import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
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

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Cek apakah user ada di tabel users
      final userResponse = await _supabase
          .from('users')
          .select()
          .eq('username', username.trim())
          .maybeSingle();

      if (userResponse == null) {
        _error = 'Username tidak ditemukan';
        return false;
      }

      // Verifikasi password
      if (userResponse['password'] != password) {
        _error = 'Password salah';
        return false;
      }

      final user = User.fromJson(userResponse);
      _currentUser = user;
      _isAdmin = false;
      _error = null;

      // Update UserProvider
      await _userProvider.setCurrentUser(user);

      return true;
    } catch (e) {
      _error = 'Username atau password salah';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Cek apakah username sudah ada
      final existingUser = await _supabase
          .from('users')
          .select()
          .eq('username', userData['username'])
          .maybeSingle();

      if (existingUser != null) {
        _error = 'Username sudah digunakan';
        return false;
      }

      final response =
          await _supabase.from('users').insert(userData).select().single();

      _currentUser = User.fromJson(response);
      _isAdmin = false;
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
    _isAdmin = false;
    _userProvider.clearCurrentUser();
    notifyListeners();
  }

  Future<bool> loginAdmin(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
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

      if (passwordCheck == null || passwordCheck['password'] != password) {
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

  Future<bool> registerAdmin(Map<String, dynamic> adminData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validasi field yang diperlukan
      if (!adminData.containsKey('username') ||
          !adminData.containsKey('password') ||
          !adminData.containsKey('nama_lengkap') ||
          !adminData.containsKey('jabatan')) {
        _error = 'Data admin tidak lengkap';
        return false;
      }

      // Cek apakah username admin sudah ada
      final existingAdmin = await _supabase
          .from('admin')
          .select('username')
          .eq('username', adminData['username'])
          .maybeSingle();

      if (existingAdmin != null) {
        _error = 'Username admin sudah digunakan';
        return false;
      }

      // Hanya masukkan field yang diperlukan
      final adminDataToInsert = {
        'username': adminData['username'],
        'password': adminData['password'],
        'nama_lengkap': adminData['nama_lengkap'],
        'jabatan': adminData['jabatan'],
      };

      final response = await _supabase
          .from('admin')
          .insert(adminDataToInsert)
          .select('id, username, nama_lengkap, jabatan')
          .single();

      _currentUser = response;
      _isAdmin = true;
      _error = null;
      return true;
    } catch (e) {
      _error = 'Terjadi kesalahan saat mendaftar admin';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
