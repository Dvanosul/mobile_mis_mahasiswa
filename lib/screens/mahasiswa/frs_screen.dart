import 'package:flutter/material.dart';
import 'package:mobile_mis_mahasiswa/widgets/custom_navbar.dart';
import 'package:mobile_mis_mahasiswa/services/frs_service.dart';
import 'package:provider/provider.dart';
import 'package:mobile_mis_mahasiswa/providers/auth_providers.dart';

class FrsPage extends StatefulWidget {
  const FrsPage({super.key});

  @override
  State<FrsPage> createState() => _FrsPageState();
}

class _FrsPageState extends State<FrsPage> {
  final FrsService _frsService = FrsService();
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  // FRS data
  Map<String, dynamic>? _frsData;
  List<dynamic> _selectedCourses = [];
  List<dynamic> _availableCourses = [];
  int _totalCredits = 0;
  final int _maxCredits = 24;

  @override
  void initState() {
    super.initState();
    _loadFrsData();
  }

  Future<void> _loadFrsData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _frsService.getFrs();
      setState(() {
        _frsData = data;
        
        // Get the selected courses
        _selectedCourses = data['selected_courses'] ?? [];
        _selectedCourses.sort((a, b) {
          int idA = a['id'] is int ? a['id'] : int.tryParse('${a['id']}') ?? 0;
          int idB = b['id'] is int ? b['id'] : int.tryParse('${b['id']}') ?? 0;
          return idA.compareTo(idB);
        });
        
        _availableCourses = data['available_courses'] ?? [];
        _calculateTotalCredits();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data FRS: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateTotalCredits() {
    _totalCredits = _selectedCourses.fold(0, (sum, course) {
      int sks = 0;
      if (course['sks'] != null) {
        if (course['sks'] is int) {
          sks = course['sks'];
        } else if (course['sks'] is String) {
          sks = int.tryParse(course['sks']) ?? 0;
        } else if (course['sks'] is double) {
          sks = course['sks'].toInt();
        }
      }
      return sum + sks;
    });
  }

  Future<void> _addCourse(dynamic matakuliahId) async {
    final int courseId =
        matakuliahId is int ? matakuliahId : int.tryParse('$matakuliahId') ?? 0;

    // Make sure we have a valid ID
    if (courseId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID mata kuliah tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Find the course to check credits
    final course = _availableCourses.firstWhere(
      (c) => c['id'] == courseId,
      orElse: () => <String, dynamic>{}, // Return empty map instead of null
    );

    // Safely convert SKS value to int, handling various data types
    int courseSks = 0;
    if (course['sks'] != null) {
      if (course['sks'] is int) {
        courseSks = course['sks'];
      } else if (course['sks'] is String) {
        courseSks = int.tryParse(course['sks']) ?? 0;
      } else if (course['sks'] is double) {
        courseSks = course['sks'].toInt();
      }
    }

    if (_totalCredits + courseSks > _maxCredits) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Total SKS tidak boleh melebihi $_maxCredits SKS'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _frsService.addMatakuliah(courseId);
      await _loadFrsData(); // Reload data after adding
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mata kuliah berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan mata kuliah: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _removeCourse(int frsId) async {
    setState(() => _isSubmitting = true);

    try {
      await _frsService.removeMatakuliah(frsId);
      await _loadFrsData(); // Reload data after removing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mata kuliah berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus mata kuliah: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitFrs() async {
    if (_selectedCourses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih minimal 1 mata kuliah'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await _frsService.submitFrs();

      // Update UI to show status as "pending" since we can't
      // modify the backend to actually change status
      setState(() {
        // If we have a status field in _frsData, update it
        if (_frsData != null) {
          _frsData!['status'] = 'pending';
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'FRS berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );

      // Reload data after submission to refresh the UI
      await _loadFrsData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan FRS: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Menghapus tombol panah kembali
        title: const Text(
          'Formulir Rencana Studi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B2B50),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.info_outline, color: Colors.black),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: 1, context: context),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadFrsData,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
              : Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Student Information Card
                        _buildStudentInfoCard(user),
                        const SizedBox(height: 16), 
                        Row(
                          children: [
                            _buildStatusIndicator('Menunggu', Colors.orange, 
                                _selectedCourses.where((c) => (c['status'] ?? 'pending').toLowerCase() == 'pending').length),
                            const SizedBox(width: 8),
                            _buildStatusIndicator('Disetujui', Colors.green, 
                                _selectedCourses.where((c) => (c['status'] ?? '').toLowerCase() == 'approved').length),
                            const SizedBox(width: 8),
                            _buildStatusIndicator('Ditolak', Colors.red, 
                                _selectedCourses.where((c) => (c['status'] ?? '').toLowerCase() == 'rejected').length),
                          ],
                        ),
                        const SizedBox(height: 16), // Tambahkan space setelah status summary

                        // SKS Counter
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD7D4FB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total SKS Dipilih:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '$_totalCredits / $_maxCredits SKS',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color:
                                      _totalCredits > _maxCredits
                                          ? Colors.red
                                          : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Selected Courses
                        if (_selectedCourses.isNotEmpty) ...[
                          const Text(
                            'Mata Kuliah Dipilih:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _selectedCourses.length,
                            itemBuilder: (context, index) {
                              final course = _selectedCourses[index];
                              return _buildSelectedCourseCard(course);
                            },
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Available Courses
                        const Text(
                          'Mata Kuliah Tersedia:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _availableCourses.length,
                          itemBuilder: (context, index) {
                            final course = _availableCourses[index];
                            // Check if course is already selected
                            final isSelected = _selectedCourses.any(
                              (selected) =>
                                  selected['mata_kuliah_id'] == course['id'],
                            );
                            return _buildAvailableCourseCard(
                              course,
                              isSelected,
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitFrs,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8F98F8),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child:
                                _isSubmitting
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text(
                                      'Simpan FRS',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                        // Add extra space at the bottom for better scrolling
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                  if (_isSubmitting)
                    const Opacity(
                      opacity: 0.3,
                      child: ModalBarrier(
                        dismissible: false,
                        color: Colors.black,
                      ),
                    ),
                ],
              ),
    );
  }

 Widget _buildStudentInfoCard(Map<String, dynamic>? user) {
  // Extract student information from frsData
  final studentInfo = _frsData?['student_info'] ?? {};

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informasi Akademik',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Modified fields as requested
        _infoRow('Dosen wali', studentInfo['dosen_wali'] ?? '-'),
        _infoRow('Kelas', studentInfo['kelas'] ?? '-'),
        _infoRow('Max SKS', '$_maxCredits'),
      ],
    ),
  );
}


  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCourseCard(Map<String, dynamic> course) {
      final String status = (course['status'] ?? 'pending').toLowerCase();
      final Color statusColor = {
        'pending': Colors.orange,
        'approved': Colors.green,
        'rejected': Colors.red,
      }[status] ?? Colors.orange;
      
      final IconData statusIcon = {
        'pending': Icons.hourglass_empty,
        'approved': Icons.check_circle,
        'rejected': Icons.cancel,
      }[status] ?? Icons.hourglass_empty;
      
      final String statusText = course['status_text'] ?? {
        'pending': 'Menunggu Persetujuan',
        'approved': 'Disetujui',
        'rejected': 'Ditolak',
      }[status] ?? 'Menunggu Persetujuan';

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: statusColor, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 16, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Course info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${course['kode_mk'] ?? course['kode'] ?? course['code'] ?? '-'} - ${course['nama_matakuliah'] ?? course['nama_mk'] ?? course['nama'] ?? course['name'] ?? '-'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _courseInfoItem(
                          Icons.person,
                          'Dosen: ${course['nama_dosen'] ?? course['dosen'] ?? course['lecturer'] ?? '-'}',
                        ),
                        _courseInfoItem(
                          Icons.calendar_today,
                          '${course['jadwal'] ?? course['schedule'] ?? '-'}',
                        ),
                        _courseInfoItem(
                          Icons.book,
                          'SKS: ${course['sks']?.toString() ?? '0'}',
                        ),
                        _courseInfoItem(
                          Icons.school,
                          'Semester: ${course['semester'] ?? course['smt'] ?? '-'}',
                        ),
                      ],
                    ),
                  ),
                  
                  // Remove button (hanya jika status pending)
                  if (status == 'pending')
                    IconButton(
                      onPressed: _isSubmitting ? null : () => _removeCourse(course['id']),
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }

  Widget _buildAvailableCourseCard(
    Map<String, dynamic> course,
    bool isSelected,
  ) {
    // Add debug print to help identify available keys

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap:
            isSelected || _isSubmitting ? null : () => _addCourse(course['id']),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // Updated to include nama_matakuliah in the keys to check
                      '${course['kode'] ?? course['kode_mk'] ?? course['code'] ?? '-'} - ${course['nama_matakuliah'] ?? course['nama'] ?? course['nama_mk'] ?? course['name'] ?? '-'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _courseInfoItem(
                      Icons.person,
                      'Dosen: ${course['dosen'] ?? course['nama_dosen'] ?? course['lecturer'] ?? '-'}',
                    ),
                    _courseInfoItem(
                      Icons.calendar_today,
                      '${course['jadwal'] ?? course['schedule'] ?? '-'}',
                    ),
                    _courseInfoItem(
                      Icons.book,
                      'SKS: ${course['sks']?.toString() ?? '0'}',
                    ),
                    _courseInfoItem(
                      Icons.school,
                      'Semester: ${course['semester'] ?? course['smt'] ?? '-'}',
                    ),
                  ],
                ),
              ),
              // Add button or Already added indicator
              if (isSelected)
                const Chip(
                  label: Text('Sudah dipilih'),
                  backgroundColor: Color(0xFFD7D4FB),
                )
              else
                IconButton(
                  onPressed:
                      _isSubmitting ? null : () => _addCourse(course['id']),
                  icon: const Icon(Icons.add_circle, color: Color(0xFF8F98F8)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _courseInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[800], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusIndicator(String label, Color color, int count) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );
    }
}
