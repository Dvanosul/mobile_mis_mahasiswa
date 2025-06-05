import 'package:flutter/material.dart';
import 'package:mobile_mis_mahasiswa/widgets/custom_navbar.dart';
import 'package:mobile_mis_mahasiswa/services/jadwal_service.dart';

class JadwalCardPage extends StatefulWidget {
  const JadwalCardPage({super.key});

  @override
  State<JadwalCardPage> createState() => _JadwalCardPageState();
}

class _JadwalCardPageState extends State<JadwalCardPage> {
  final JadwalService _jadwalService = JadwalService();

  // Ordered list of days to ensure consistent display order
  final List<String> orderedDays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  Map<String, List<dynamic>> jadwal = {};
  bool isLoading = true;
  String? errorMessage;
  
  // Add selected day state variable
  String? _selectedDay;
  
  // List to store days in correct order
  List<String> _orderedAvailableDays = [];

  @override
  void initState() {
    super.initState();
    fetchJadwal();
  }

  Future<void> fetchJadwal() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final dynamic response = await _jadwalService.getJadwal();

      setState(() {
        if (response is List) {
          jadwal = _groupJadwalByDay(response);
        } else if (response is Map<String, dynamic>) {
          if (response.containsKey('jadwal')) {
            final dynamic jadwalData = response['jadwal'];

            if (jadwalData is List) {
              jadwal = _groupJadwalByDay(jadwalData);
            } else if (jadwalData is Map) {
              final result = <String, List<dynamic>>{};
              jadwalData.forEach((key, value) {
                if (key is String && value is List) {
                  result[key] = value;
                }
              });
              jadwal = result;
            } else {
              jadwal = {};
            }
          } else {
            jadwal = {};
          }
        } else {
          jadwal = {};
        }
        
        // Create ordered list of available days
        _orderedAvailableDays = _getOrderedAvailableDays();
        
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan saat memuat jadwal: ${e.toString()}';
        isLoading = false;
      });
      print('Error fetching jadwal: $e');
    }
  }

  // Get days with schedule data in the correct order
  List<String> _getOrderedAvailableDays() {
    return orderedDays.where((day) => jadwal.containsKey(day)).toList();
  }

  Map<String, List<dynamic>> _groupJadwalByDay(List<dynamic> jadwalList) {
    final Map<String, List<dynamic>> grouped = {};

    // Initialize with empty lists for all days to ensure proper ordering
    for (var day in orderedDays) {
      grouped[day] = [];
    }

    for (var item in jadwalList) {
      if (item is! Map) continue;

      // Try multiple possible field names for the day
      String? hari = item['hari']?.toString();
      if (hari == null || hari.isEmpty) {
        hari = item['day']?.toString();
      }
      if (hari == null || hari.isEmpty) {
        hari = 'Tidak diketahui';
      }

      // Capitalize first letter for consistency
      hari = _capitalizeFirstLetter(hari);

      // Skip if the day is not in our ordered list
      if (!grouped.containsKey(hari)) {
        grouped[hari] = [];
      }

      grouped[hari]!.add(item);
    }

    // Remove days with no classes
    grouped.removeWhere((key, value) => value.isEmpty);

    return grouped;
  }

  // Helper to capitalize first letter of a string
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Sort courses by time for better readability
  List<dynamic> _sortCoursesByTime(List<dynamic> courses) {
    courses.sort((a, b) {
      final timeA = a['waktu']?.toString() ?? '';
      final timeB = b['waktu']?.toString() ?? '';
      return timeA.compareTo(timeB);
    });
    return courses;
  }

  // Handle day selection
  void _selectDay(String day) {
    setState(() {
      // If the same day is clicked again, clear the filter
      if (_selectedDay == day) {
        _selectedDay = null;
      } else {
        _selectedDay = day;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF8F98F8);

    return Scaffold(
      bottomNavigationBar: CustomNavBar(currentIndex: 2, context: context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Jadwal Kuliah',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B2B50),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: fetchJadwal,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.info_outline, color: Colors.black),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day selection buttons - NO SHADOWS
            if (!isLoading && errorMessage == null && jadwal.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Show all button only when a day is selected
                  if (_selectedDay != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.calendar_view_week),
                        label: const Text('Tampilkan Semua Hari'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                          elevation: 0, // No shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedDay = null;
                          });
                        },
                      ),
                    ),
                  
                  Container(
                    height: 50,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _orderedAvailableDays.map((day) {
                        final isSelected = _selectedDay == day;
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected ? primaryColor.withOpacity(0.8) : primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0, // No shadow!
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            onPressed: () => _selectDay(day),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(day),
                                if (isSelected)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Icon(Icons.check, size: 16),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              
            // Content area
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (errorMessage != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchJadwal,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              )
            else if (jadwal.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "Tidak ada data jadwal tersedia.",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedDay != null ? 1 : _orderedAvailableDays.length,
                  itemBuilder: (context, index) {
                    final day = _selectedDay ?? _orderedAvailableDays[index];
                    final List<dynamic> courses = _sortCoursesByTime(jadwal[day]!);
                    
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Day header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  day,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${courses.length} mata kuliah',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Course list for this day
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: courses.length,
                            itemBuilder: (context, courseIndex) {
                              final matkul = courses[courseIndex];
                              return Container(
                                margin: EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  top: 12,
                                  bottom: courseIndex == courses.length - 1 ? 16 : 8,
                                ),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: primaryColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            matkul['mata_kuliah'] ?? 
                                            matkul['nama_matkul'] ?? 
                                            matkul['nama'] ?? '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: primaryColor.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            matkul['waktu'] ?? '',
                                            style: TextStyle(
                                              color: primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      Icons.confirmation_number,
                                      'Kode',
                                      matkul['kode'] ?? '',
                                    ),
                                    _buildInfoRow(
                                      Icons.room,
                                      'Ruang',
                                      matkul['ruang'] ?? '',
                                    ),
                                    _buildInfoRow(
                                      Icons.person,
                                      'Dosen',
                                      matkul['dosen'] ?? '',
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
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
}