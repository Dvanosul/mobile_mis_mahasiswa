import 'base_api_services.dart';

class JadwalService {
  final BaseApiService _apiService = BaseApiService();
  
  Future<Map<String, dynamic>> getJadwal() async {
    return await _apiService.get('/mahasiswa/jadwal');
  }
}