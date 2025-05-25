import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_mis_mahasiswa/widgets/custom_navbar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class JadwalCardPage extends StatefulWidget {
  const JadwalCardPage({super.key});

  @override
  State<JadwalCardPage> createState() => _JadwalCardPageState();
}

class _JadwalCardPageState extends State<JadwalCardPage> {
  String selectedTahun = '2024/2025';
  String selectedSemester = 'Genap';

  Map<String, dynamic> jadwal = {};
  bool isLoading = true;
  String? errorMessage;

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
      // final prefs = await SharedPreferences.getInstance();
      // final token = prefs.getString('token');

       final storage = FlutterSecureStorage();
       final token = await storage.read(key: 'auth_token');

      if (token == null) {
        setState(() {
          errorMessage = 'Token tidak ditemukan. Silakan login ulang.';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://104.214.168.47/api/mahasiswa/jadwal'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          jadwal = Map<String, dynamic>.from(data['jadwal'] ?? {});
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Gagal memuat data jadwal.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomNavBar(currentIndex: 2, context: context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Jadwal Kuliah',
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dropdown Tahun & Semester
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedTahun,
                    decoration: const InputDecoration(labelText: 'Tahun Ajaran'),
                    items: ['2023/2024', '2024/2025', '2025/2026']
                        .map((tahun) => DropdownMenuItem(
                              value: tahun,
                              child: Text(tahun),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTahun = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedSemester,
                    decoration: const InputDecoration(labelText: 'Semester'),
                    items: ['Ganjil', 'Genap']
                        .map((sem) => DropdownMenuItem(
                              value: sem,
                              child: Text(sem),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSemester = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Konten jadwal
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (errorMessage != null)
              Expanded(
                child: Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (jadwal.isEmpty)
              const Expanded(
                child: Center(child: Text("Tidak ada data jadwal tersedia.")),
              )
            else
              Expanded(
                child: ListView(
                  children: jadwal.entries.map((entry) {
                    final hari = entry.key;
                    final List<dynamic> matkulList = entry.value;

                    return Card(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              hari,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...matkulList.map((matkul) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                color: Colors.grey[200],
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(matkul['mata_kuliah'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text('Kode: ${matkul['kode']}'),
                                    Text('Ruang: ${matkul['ruang']}'),
                                    Text('Jam: ${matkul['waktu']}'),
                                    Text('Dosen: ${matkul['dosen']}'),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
