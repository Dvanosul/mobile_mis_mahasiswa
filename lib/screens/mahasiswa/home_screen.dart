import 'package:flutter/material.dart';
import 'package:mobile_mis_mahasiswa/screens/mahasiswa/frs_screen.dart';
import 'package:mobile_mis_mahasiswa/screens/mahasiswa/jadwal_screen.dart';
import 'package:mobile_mis_mahasiswa/screens/mahasiswa/nilai_screen.dart';
import 'package:mobile_mis_mahasiswa/services/jadwal_service.dart';
import 'package:mobile_mis_mahasiswa/services/nilai_service.dart';
import 'package:mobile_mis_mahasiswa/widgets/custom_navbar.dart';
import 'package:provider/provider.dart';
import 'package:mobile_mis_mahasiswa/providers/auth_providers.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final JadwalService _jadwalService = JadwalService();
  final NilaiService _nilaiService = NilaiService();
  
  bool _isLoading = true;
  String? _errorMessage;
  
  // Data jadwal dan nilai
  Map<String, List<dynamic>>? _jadwalPerHari;
  List<dynamic> _jadwalHariIni = [];
  Map<String, dynamic>? _nilaiData;
  double _ipk = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final jadwalData = await _jadwalService.getJadwal();
      final String hariIni = _getHariIni();
      final Map<String, List<dynamic>> jadwalMap = {};
      
      if (jadwalData['jadwal'] is Map) {
        final Map<String, dynamic> rawJadwal = jadwalData['jadwal'] as Map<String, dynamic>;
        
        rawJadwal.forEach((key, value) {
          if (value is List) {
            jadwalMap[key] = value;
          } else if (value is Map) {
            jadwalMap[key] = [value];
          }
        });
      }
      
      setState(() {
        _jadwalPerHari = jadwalMap;
        _jadwalHariIni = _jadwalPerHari?[hariIni] ?? [];
      });

      // Ambil data nilai
      final nilaiData = await _nilaiService.getNilai();
      setState(() {
        _nilaiData = nilaiData;
        // Gunakan IPK langsung dari server daripada menghitung ulang
        _ipk = (nilaiData['ip'] as num?)?.toDouble() ?? 0.0;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Mendapatkan hari ini dalam bahasa Indonesia
  String _getHariIni() {
    final now = DateTime.now();
    final dayNames = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    return dayNames[now.weekday % 7]; // weekday returns 1-7 (Monday-Sunday)
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B2B50),
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.info_outline, color: Colors.black),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: 0, context: context), 
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
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
                          onPressed: _loadData,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8F98F8), Color(0xFFD7D4FB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Color(0xFF8F98F8),
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Selamat Datang',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?['name'] ?? 'Mahasiswa',
                                    style: const TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    user?['nrp'] ?? '-',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // IPK Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD7D4FB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.school,
                                color: Color(0xFF8F98F8),
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'IPK',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  _ipk.toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B2B50),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const NilaiCardPage()),
                                );
                              },
                              child: const Text(
                                'Lihat Detail',
                                style: TextStyle(
                                  color: Color(0xFF8F98F8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Jadwal Hari Ini
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Jadwal Hari Ini (${_getHariIni()})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2B50),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const JadwalCardPage()),
                              );
                            },
                            child: const Text(
                              'Lihat Semua',
                              style: TextStyle(
                                color: Color(0xFF8F98F8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Jadwal Hari Ini Cards
                      _jadwalHariIni.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  'Tidak ada jadwal untuk hari ini',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: _jadwalHariIni.map((jadwal) => _buildJadwalCard(jadwal)).toList(),
                            ),
                      const SizedBox(height: 24),

                      // Features
                      const Text(
                        'Fitur Akademik',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B2B50),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Main Features Row - Only FRS, Jadwal, Nilai
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _featureCard(context, Icons.edit_note, 'FRS', const FrsPage()),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _featureCard(context, Icons.calendar_month, 'Jadwal', const JadwalCardPage()),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _featureCard(context, Icons.bar_chart, 'Nilai', const NilaiCardPage()),
                          ),
                        ],
                      ),
                      
                      // Additional info or content can be added here
                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          'Sistem Informasi Akademik Mahasiswa',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Versi 1.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildJadwalCard(Map<String, dynamic> jadwal) {
    final String waktu = jadwal['waktu'] ?? '-';
    final String mataKuliah = jadwal['mata_kuliah'] ?? '-';
    final String ruang = jadwal['ruang'] ?? '-';
    final String dosen = jadwal['dosen'] ?? '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFD7D4FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.access_time,
                  color: Color(0xFF8F98F8),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mataKuliah,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1B2B50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ruang: $ruang',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Dosen: $dosen',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD7D4FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                waktu,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8F98F8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard(BuildContext context, IconData icon, String title, Widget destinationPage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationPage),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7D4FB),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: const Color(0xFF8F98F8),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2B50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}