import 'package:flutter/material.dart';
import 'package:mobile_mis_mahasiswa/widgets/custom_navbar.dart';
import 'package:mobile_mis_mahasiswa/services/nilai_service.dart';

class NilaiCardPage extends StatefulWidget {
  const NilaiCardPage({super.key});

  @override
  State<NilaiCardPage> createState() => _NilaiCardPageState();
}

class _NilaiCardPageState extends State<NilaiCardPage> {
  final NilaiService _nilaiService = NilaiService();
  String selectedSemester = 'Semua';
  bool _isLoading = true;
  String? _errorMessage;

  // Data from API
  List<Map<String, dynamic>> _nilaiList = [];
  double _ip = 0.0;
  int _totalSks = 0;

  @override
  void initState() {
    super.initState();
    _loadNilaiData();
  }

  Future<void> _loadNilaiData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _nilaiService.getNilai();

      setState(() {
        _nilaiList = List<Map<String, dynamic>>.from(data['nilai_list'] ?? []);
        _ip = (data['ip'] as num?)?.toDouble() ?? 0.0;
        _totalSks = (data['total_sks'] as num?)?.toInt() ?? 0;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data nilai: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Filter nilai based on selected semester if needed
  List<Map<String, dynamic>> get filteredNilai {
    if (selectedSemester == 'Semua') {
      return _nilaiList;
    }
    // If your API provides semester info, filter here
    // For now, return all grades since the API doesn't seem to have semester info
    return _nilaiList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomNavBar(currentIndex: 3, context: context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Menghapus tombol panah kembali
        title: const Text(
          'Nilai Akademik',
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
                      onPressed: _loadNilaiData,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // IP and SKS Summary Card
                    _buildIpSummaryCard(),
                    const SizedBox(height: 16),

                    // Dropdown semester
                    Align(
                      alignment: Alignment.centerLeft,
                      child: DropdownButton<String>(
                        value: selectedSemester,
                        underline: Container(),
                        items:
                            ['Semua', '1', '2', '3', '4', '5', '6', '7', '8']
                                .map(
                                  (sem) => DropdownMenuItem(
                                    value: sem,
                                    child: Text(
                                      sem == 'Semua'
                                          ? 'Semua Semester'
                                          : 'Semester $sem',
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSemester = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Daftar nilai
                    Expanded(
                      child:
                          filteredNilai.isEmpty
                              ? const Center(
                                child: Text(
                                  'Tidak ada data nilai',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                              : ListView.builder(
                                itemCount: filteredNilai.length,
                                itemBuilder: (context, index) {
                                  final item = filteredNilai[index];
                                  return _buildNilaiCard(item);
                                },
                              ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildIpSummaryCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text(
                  'IP Kumulatif',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  _ip.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2B50),
                  ),
                ),
              ],
            ),
            Container(height: 40, width: 1, color: Colors.grey[300]),
            Column(
              children: [
                const Text(
                  'Total SKS',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  _totalSks.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2B50),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNilaiCard(Map<String, dynamic> item) {
    final nilaiHuruf = item['nilai_huruf'] ?? 'Belum Terisi';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item['kode'] ?? '-'} - ${item['nama_matakuliah'] ?? '-'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1B2B50),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getNilaiColor(nilaiHuruf),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    nilaiHuruf,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Dosen: ${item['dosen'] ?? '-'}',
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            Text(
              'SKS: ${item['sks'] ?? '0'}',
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            if (item['nilai_angka'] != null)
              Text(
                'Nilai Angka: ${item['nilai_angka']}',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }

  Color _getNilaiColor(String nilai) {
    switch (nilai) {
      case 'A':
        return Colors.green;
      case 'AB':
      case 'B':
        return Colors.blue;
      case 'BC':
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      case 'E':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
