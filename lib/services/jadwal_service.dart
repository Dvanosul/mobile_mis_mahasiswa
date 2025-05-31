import 'base_api_services.dart';

class JadwalService {
  final BaseApiService _apiService = BaseApiService();

  Future<Map<String, dynamic>> getJadwal() async {
    final response = await _apiService.get('/mahasiswa/jadwal');
    return response;
  }
}