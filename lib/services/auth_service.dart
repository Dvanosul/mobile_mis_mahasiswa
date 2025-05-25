import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl;
  final storage = FlutterSecureStorage();
  
  AuthService({this.baseUrl = 'http://104.214.168.47/api'});
  
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['token'] != null) {
        await storage.write(key: 'auth_token', value: data['token']);
      }
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Registration failed');
    }
  }

  String determineRole(String email) {
  if (email.endsWith('@student.pens.ac.id')) {
    return 'mahasiswa';
  } else if (email.endsWith('@dosen.pens.ac.id')) {
    return 'dosen';
  } else {
    return 'unknown';
  }
}

  // Login user
  Future<Map<String, dynamic>> login({
  required String email, 
  required String password
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/login'),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['token'] != null) {
      await storage.write(key: 'auth_token', value: data['token']);
      
      // Menentukan role berdasarkan email dan menyimpannya
      final role = determineRole(email);
      await storage.write(key: 'user_role', value: role);
      
      // Tambahkan role ke data response
      data['role'] = role;
    }
    return data;
  } else {
    final error = jsonDecode(response.body);
    throw Exception(error['message'] ?? 'Login failed');
  }
}

  Future<String?> getUserRole() async {
  return await storage.read(key: 'user_role');
}
  
  // Logout user
  Future<void> logout() async {
    final token = await storage.read(key: 'auth_token');
    
    if (token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } catch (e) {
        print('Logout error: $e');
      }
    }
    
    await storage.delete(key: 'auth_token');
  }
  
  // Get user data
  Future<Map<String, dynamic>> getUser() async {
    final token = await storage.read(key: 'auth_token');
    
    if (token == null) {
      throw Exception('Not authenticated');
    }
    
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user');
    }
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: 'auth_token');
    return token != null;
  }
}