import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Pastikan path ini benar

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _user; // Menggunakan Map untuk data user
  String? _role;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;
  String? get role => _role;

  bool get isMahasiswa => _role == 'mahasiswa';
  bool get isDosen => _role == 'dosen';

  Future<bool> tryAutoLogin() async {
    _isLoading = true;
    notifyListeners();

    final token = await _authService.storage.read(key: 'auth_token');
    if (token == null || token.isEmpty) {
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      // Verifikasi token dengan mengambil data pengguna
      final userData = await _authService.getUser();
      if (userData.isNotEmpty) {
        _user = userData; // Simpan data user sebagai Map
        _role = await _authService.getUserRole(); // Ambil role dari storage
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Jika getUser mengembalikan data kosong meskipun ada token, anggap tidak login
        await _authService.logout(); // Hapus token yang tidak valid
        _isAuthenticated = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Jika terjadi error saat getUser (misalnya token expired), logout
      print('Error during auto login: $e');
      await _authService.logout();
      _user = null;
      _role = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _authService.login(email: email, password: password);

      if (data['token'] != null) {
        _role = _authService.determineRole(email); // Tentukan role

        if (_role != 'mahasiswa') {
          _error = 'Aplikasi ini hanya untuk mahasiswa.';
          // Meskipun login berhasil di backend, kita tidak set _isAuthenticated = true
          // karena role tidak sesuai. Token akan tetap tersimpan, tapi auto-login
          // berikutnya akan gagal di tahap validasi role jika tidak di-handle.
          // Sebaiknya logout jika role tidak sesuai.
          await _authService.logout(); // Logout jika role tidak sesuai
          _isAuthenticated = false;
          _user = null;
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // Jika role adalah mahasiswa, lanjutkan
        _isAuthenticated = true;
        // Coba ambil data user setelah login berhasil dan role valid
        try {
          _user = await _authService.getUser();
        } catch (e) {
          print('Error saat mengambil data user setelah login: $e');
          // Fallback jika getUser gagal setelah login
          _user = {
            'name': data['name'] ?? data['user']?['name'] ?? 'Mahasiswa',
            'email': email,
            'role': _role,
          };
        }
        _error = null; // Bersihkan error jika login berhasil
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = data['message'] ?? 'Login gagal. Token tidak ditemukan.';
        _isAuthenticated = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Login exception: $e');
      _error = e.toString().contains('SocketException')
          ? 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.'
          : 'Terjadi kesalahan: ${e.toString()}';
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _isAuthenticated = false;
      _user = null;
      _role = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  }
