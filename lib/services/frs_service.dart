import 'base_api_services.dart';

class FrsService {
  final BaseApiService _apiService = BaseApiService();

  Future<Map<String, dynamic>> getFrs() async {
    return await _apiService.get('/mahasiswa/frs');
  }

  Future<Map<String, dynamic>> addMatakuliah(int matakuliahId) async {
    return await _apiService.post('/mahasiswa/frs', {'matakuliah_id': matakuliahId});
  }

  Future<Map<String, dynamic>> removeMatakuliah(int frsId) async {
    return await _apiService.delete('/mahasiswa/frs/$frsId');
  }
}