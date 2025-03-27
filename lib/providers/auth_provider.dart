import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  User? _currentUser;
  String? _error;
  bool _isLoading = false;

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

  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await _supabase.from('users').insert(userData).select().single();

      _currentUser = User.fromJson(response);
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
}
