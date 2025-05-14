import 'package:flutter/material.dart';
import 'package:mobile_mis_mahasiswa/widgets/custom_navbar.dart';

class JadwalCardPage extends StatefulWidget {
  const JadwalCardPage({super.key});

  @override
  State<JadwalCardPage> createState() => _JadwalCardPageState();
}

class _JadwalCardPageState extends State<JadwalCardPage> {
  String selectedTahun = '2024/2025';
  String selectedSemester = 'Genap';

  final List<Map<String, dynamic>> jadwal = [
    {
      'hari': 'Senin',
      'matkul': [
        {'nama': 'Kecerdasan Buatan', 'ruang': 'C203', 'jam': '08.00 - 09.40'},
        {'nama': 'Kecerdasan Buatan', 'ruang': 'C203', 'jam': '08.00 - 09.40'},
        {'nama': 'Kecerdasan Buatan', 'ruang': 'C203', 'jam': '08.00 - 09.40'},
      ]
    },
    {
      'hari': 'Selasa',
      'matkul': [
        {'nama': 'Kecerdasan Buatan', 'ruang': 'C203', 'jam': '08.00 - 09.40'},
        {'nama': 'Kecerdasan Buatan', 'ruang': 'C203', 'jam': '08.00 - 09.40'},
        {'nama': 'Kecerdasan Buatan', 'ruang': 'C203', 'jam': '08.00 - 09.40'},
      ]
    },
    {
      'hari': 'Rabu',
      'matkul': [
        {'nama': 'Kecerdasan Buatan', 'ruang': 'C203', 'jam': '08.00 - 09.40'},
        {'nama': 'Kecerdasan Buatan', 'ruang': 'C203', 'jam': '08.00 - 09.40'},
      ]
    },
  ];

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

            // Daftar Jadwal
            Expanded(
              child: ListView.builder(
                itemCount: jadwal.length,
                itemBuilder: (context, index) {
                  final hari = jadwal[index];
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
                            hari['hari'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...hari['matkul'].map<Widget>((matkul) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              color: Colors.grey[200],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(matkul['nama'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('${matkul['ruang']}'),
                                  Text(matkul['jam']),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
