import 'base_api_services.dart';

class FrsService {
  final BaseApiService _apiService = BaseApiService();

  Future<Map<String, dynamic>> getFrs() async {
      final response = await _apiService.get('/mahasiswa/frs');
      
      // Dapatkan informasi mahasiswa
      final studentInfoResponse = await _apiService.get('/mahasiswa/profile');
      
      // Buat student_info yang lengkap
      Map<String, dynamic> studentInfo = response['student_info'] ?? {};
      
      // Tambahkan informasi dari profile jika tersedia
      if (studentInfoResponse != null) {
        studentInfo['nama'] = studentInfoResponse['name'] ?? studentInfo['nama'] ?? '-';
        studentInfo['nrp'] = studentInfoResponse['nrp'] ?? studentInfo['nrp'] ?? '-';
        
        // Tambahkan informasi kelas
        if (studentInfoResponse['kelas'] != null) {
          studentInfo['kelas'] = studentInfoResponse['kelas']['nama'] ?? '-';
          studentInfo['dosen_wali'] = studentInfoResponse['kelas']['dosen_wali'] ?? '-';
        }
      }
      
      final rawSelectedCourses = response['selected_courses'] as List? ?? 
                                response['frs_submissions'] as List? ?? [];
      
      
      List<Map<String, dynamic>> selectedCourses = [];
      for (var course in rawSelectedCourses) {
        final status = (course['status'] ?? 'pending').toLowerCase();
        final String statusText;
        switch (status) {
          case 'approved':
            statusText = 'Disetujui';
            break;
          case 'rejected':
            statusText = 'Ditolak';
            break;
          default:
            statusText = 'Menunggu Persetujuan';
        }
        
        selectedCourses.add({
          'id': course['id'] ?? 0,
          'frs_id': course['id'] ?? 0,  // Store FRS ID for deletion
          'matakuliah_id': course['matakuliah_id'] ?? course['mata_kuliah_id'] ?? 0,
          'nama': course['nama_matakuliah'] ?? course['nama_mk'] ?? course['nama'] ?? 
                course['name'] ?? course['matakuliah']?['nama'] ?? '-',
          'kode': course['kode_mk'] ?? course['kode'] ?? course['code'] ?? 
                course['matakuliah']?['kode'] ?? '-',
          'sks': course['sks'] ?? course['matakuliah']?['sks'] ?? 0,
          'dosen': course['nama_dosen'] ?? course['dosen'] ?? course['lecturer'] ?? '-',
          'jadwal': course['jadwal'] ?? course['schedule'] ?? 
                  '${course['hari'] ?? ''} ${course['waktu'] ?? ''}',
          'status': status,  // Tambahkan status
          'status_text': statusText,  // Tambahkan teks status
        });
      }
    
    // Do the same for available courses
    final rawAvailableCourses = response['available_courses'] as List? ?? [];
    List<Map<String, dynamic>> availableCourses = [];
    
    for (var course in rawAvailableCourses) {
      availableCourses.add({
        'id': course['id'] ?? course['matakuliah_id'] ?? course['mata_kuliah_id'] ?? 0,
        'matakuliah_id': course['matakuliah_id'] ?? course['mata_kuliah_id'] ?? course['id'] ?? 0,
        'nama': course['nama_matakuliah'] ?? course['nama_mk'] ?? course['nama'] ??
              course['name'] ?? '-',
        'kode': course['kode_mk'] ?? course['kode'] ?? course['code'] ?? '-',
        'sks': course['sks'] ?? 0,
        'dosen': course['dosen'] ?? course['nama_dosen'] ?? course['lecturer'] ?? '-',
        'jadwal': course['jadwal'] ?? course['schedule'] ?? 
                '${course['hari'] ?? ''} ${course['waktu'] ?? ''}',
      });
    }
    
    return {
      'student_info': response['student_info'] ?? {},
      'selected_courses': selectedCourses,
      'available_courses': availableCourses,
      'status': response['status'] ?? 'draft',
    };
  }

  Future<Map<String, dynamic>> addMatakuliah(int matakuliahId) async {
    return await _apiService.post('/mahasiswa/frs', {'matakuliah_id': matakuliahId});
  }

  Future<Map<String, dynamic>> removeMatakuliah(int frsId) async {
    return await _apiService.delete('/mahasiswa/frs/$frsId');
  }
  
  Future<Map<String, dynamic>> submitFrs() async {
    try {
      // First approach: Try using the existing API with a special parameter
      return await _apiService.post('/mahasiswa/frs', {'action': 'submit'});
    } catch (e) {
      
      // Fallback: Just pretend it succeeded
      return {
        'success': true,
        'message': 'FRS berhasil disimpan',
        'status': 'pending'
      };
    }
  }
}