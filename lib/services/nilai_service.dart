import 'base_api_services.dart';

class NilaiService {
  final BaseApiService _apiService = BaseApiService();
  
  Future<Map<String, dynamic>> getNilai() async {
    return await _apiService.get('/mahasiswa/nilai');
  }
}