import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isAdmin = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  SharedPreferences? _prefs;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (!_initialized) {
      await _checkSavedCredentials();
      _initialized = true;
    }
  }

  Future<void> _checkSavedCredentials() async {
    if (_prefs == null) return;

    try {
      final savedUsername = _prefs!.getString('username');
      final savedPassword = _prefs!.getString('password');
      final savedIsAdmin = _prefs!.getBool('isAdmin') ?? false;
      final rememberMe = _prefs!.getBool('rememberMe') ?? false;

      if (rememberMe && savedUsername != null && savedPassword != null) {
        setState(() {
          _usernameController.text = savedUsername;
          _passwordController.text = savedPassword;
          _isAdmin = savedIsAdmin;
          _rememberMe = true;
        });

        // Auto login jika remember me aktif
        final authProvider = context.read<AuthProvider>();
        bool success;

        if (_isAdmin) {
          success = await authProvider.loginAdmin(savedUsername, savedPassword);
        } else {
          success = await authProvider.login(savedUsername, savedPassword);
        }

        if (success && mounted) {
          if (_isAdmin) {
            Navigator.pushReplacementNamed(context, '/admin');
          } else {
            Navigator.pushReplacementNamed(context, '/user');
          }
        }
      }
    } catch (e) {
      // Jika terjadi error, hapus kredensial tersimpan
      await _prefs!.remove('username');
      await _prefs!.remove('password');
      await _prefs!.remove('isAdmin');
      await _prefs!.remove('rememberMe');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveCredentials() async {
    if (_prefs == null) return;

    if (_rememberMe) {
      await _prefs!.setString('username', _usernameController.text);
      await _prefs!.setString('password', _passwordController.text);
      await _prefs!.setBool('isAdmin', _isAdmin);
      await _prefs!.setBool('rememberMe', true);
    } else {
      await _prefs!.remove('username');
      await _prefs!.remove('password');
      await _prefs!.remove('isAdmin');
      await _prefs!.remove('rememberMe');
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      bool success;

      if (_isAdmin) {
        success = await authProvider.loginAdmin(
          _usernameController.text,
          _passwordController.text,
        );
      } else {
        success = await authProvider.login(
          _usernameController.text,
          _passwordController.text,
        );
      }

      if (success) {
        // Simpan kredensial jika remember me dicentang
        await _saveCredentials();

        if (_isAdmin) {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/user');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Username atau password salah'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'MedCheck',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF40E0D0),
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SwitchListTile(
                          title: const Text('Login sebagai Admin'),
                          value: _isAdmin,
                          onChanged: (value) {
                            setState(() {
                              _isAdmin = value;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: const Text('Remember Me'),
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Login'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Daftar sebagai User'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
