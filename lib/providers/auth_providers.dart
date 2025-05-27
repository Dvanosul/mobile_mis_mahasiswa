import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _user;
  String? _role;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;
  String? get role => _role;

  // Tambahkan getter untuk mengecek role
  bool get isMahasiswa => _role == 'mahasiswa';
  bool get isDosen => _role == 'dosen';

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Panggil metode login dari AuthService
      final data = await _authService.login(email: email, password: password);

      if (data['token'] != null) {
        _isAuthenticated = true;

        // Tentukan role berdasarkan email
        _role = _authService.determineRole(email);

        // Coba ambil data user
        try {
          _user = await _authService.getUser();
        } catch (e) {
          print('Error saat mengambil data user: $e');
          // Tidak perlu melempar error di sini, cukup buat user data dari login response
          _user = {
            'name': data['name'] ?? data['user']?['name'] ?? 'User',
            'email': email,
            'role': _role,
          };
        }

        if (_role != 'mahasiswa') {
          _error = 'Aplikasi ini hanya untuk mahasiswa';
          _isAuthenticated = false;
          _user = null;
          return false;
        }

        return true;
      } else {
        _error = 'Token tidak ditemukan';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _isAuthenticated = true;
      _user = await _authService.getUser();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _isAuthenticated = false;
      _user = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
