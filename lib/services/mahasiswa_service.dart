import 'base_api_services.dart';

class MahasiswaService {
  final BaseApiService _apiService = BaseApiService();
  
  Future<Map<String, dynamic>> getProfile() async {
    return await _apiService.get('/mahasiswa/profile');
  }
}