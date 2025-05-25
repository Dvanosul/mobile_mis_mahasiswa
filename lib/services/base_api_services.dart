import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BaseApiService {
  final String baseUrl;
  final storage = FlutterSecureStorage();
  
  BaseApiService({this.baseUrl = 'http://104.214.168.47/api'});
  
  // Get token from secure storage
  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }
  
  // Get standard headers with token
  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  // GET request
  Future<dynamic> get(String endpoint) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    
    return _handleResponse(response);
  }
  
  // POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    
    return _handleResponse(response);
  }
  
  // DELETE request
  Future<dynamic> delete(String endpoint) async {
    final headers = await getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    
    return _handleResponse(response);
  }
  
  // Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } else {
      // Handle different error status codes
      String message = 'Request failed';
      try {
        final error = jsonDecode(response.body);
        message = error['message'] ?? message;
      } catch (_) {}
      
      throw Exception('$message (${response.statusCode})');
    }
  }
}