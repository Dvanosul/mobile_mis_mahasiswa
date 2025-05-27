// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl;
  final storage = const FlutterSecureStorage();
  
  AuthService({this.baseUrl = 'http://104.214.168.47/api'});

  String determineRole(String email) {
    if (email.endsWith('@student.pens.ac.id')) {
      return 'mahasiswa';
    } else if (email.endsWith('@dosen.pens.ac.id')) {
      return 'dosen';
    } else {
      return 'mahasiswa'; // Default ke mahasiswa untuk memudahkan testing
    }
  }

  // Login user dengan debugging tambahan
  Future<Map<String, dynamic>> login({
    required String email, 
    required String password
  }) async {
    try {
      print('Mencoba login ke: $baseUrl/login');
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String? token;
        
        // Cek berbagai kemungkinan struktur response untuk token
        if (data['token'] != null) {
          token = data['token'];
        } else if (data['access_token'] != null) {
          token = data['access_token'];
        } else if (data['data'] is Map && data['data']['token'] != null) {
          token = data['data']['token'];
        }
        
        if (token != null) {
          print('Token ditemukan: ${token.substring(0, 10)}...');
          await storage.write(key: 'auth_token', value: token);
          
          // Menentukan dan menyimpan role berdasarkan email
          final role = determineRole(email);
          await storage.write(key: 'user_role', value: role);
          await storage.write(key: 'user_email', value: email);
          
          // Tambahkan role ke data response
          final result = Map<String, dynamic>.from(data);
          result['role'] = role;
          result['token'] = token; // Pastikan token ada di result
          return result;
        } else {
          print('Tidak ada token dalam response');
          throw Exception('Token tidak ditemukan dalam response');
        }
      } else {
        if (response.body.isNotEmpty) {
          try {
            final error = jsonDecode(response.body);
            throw Exception(error['message'] ?? 'Login gagal dengan status: ${response.statusCode}');
          } catch (e) {
            throw Exception('Login gagal dengan status: ${response.statusCode}');
          }
        } else {
          throw Exception('Login gagal dengan status: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Login error: $e');
    }
  }
  
  Future<String?> getUserRole() async {
    return await storage.read(key: 'user_role');
  }
  
  Future<String?> getUserEmail() async {
    return await storage.read(key: 'user_email');
  }
  
  // Logout user
  Future<void> logout() async {
    final token = await storage.read(key: 'auth_token');
    
    if (token != null) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        print('Logout response: ${response.statusCode}');
      } catch (e) {
        print('Logout error (mengabaikan): $e');
      }
    }
    
    // Hapus semua data autentikasi
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'user_role');
    await storage.delete(key: 'user_email');
  }
  
  // Get user data dengan penanganan error yang lebih baik
  Future<Map<String, dynamic>> getUser() async {
    final token = await storage.read(key: 'auth_token');
    
    if (token == null) {
      throw Exception('Not authenticated');
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('Get user response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          // Jika response body kosong, buat user data dari role dan email yang disimpan
          final role = await getUserRole();
          final email = await getUserEmail();
          return {
            'role': role,
            'email': email,
          };
        }
        
        try {
          return jsonDecode(response.body);
        } catch (e) {
          print('Error parsing user data JSON: $e');
          throw Exception('Invalid user data format');
        }
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      print('Get user error: $e');
      
      // Jika gagal mengambil user data, coba gunakan data yang disimpan
      final role = await getUserRole();
      final email = await getUserEmail();
      
      if (role != null) {
        return {
          'role': role,
          'email': email,
          'name': email?.split('@')[0] ?? 'User'
        };
      } else {
        throw Exception('User data tidak tersedia');
      }
    }
  }
  
  // Check if user is logged in with token validation
  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) {
      return false;
    }
    return true;
  }
}