import 'package:flutter/material.dart';
import 'package:mobile_mis_mahasiswa/widgets/custom_navbar.dart';

class NilaiCardPage extends StatefulWidget {
  const NilaiCardPage({super.key});

  @override
  State<NilaiCardPage> createState() => _NilaiCardPageState();
}

class _NilaiCardPageState extends State<NilaiCardPage> {
  String selectedSemester = '1';

  final List<Map<String, String>> nilaiList = [
    {
      'dosen': 'Pak Rosyid',
      'matkul': 'Praktek Kecerdasan Buatan',
      'nilai': 'A',
    },
    {
      'dosen': 'Pak Rosyid',
      'matkul': 'Praktek Kecerdasan Buatan',
      'nilai': 'A',
    },
    {
      'dosen': 'Pak Rosyid',
      'matkul': 'Praktek Kecerdasan Buatan',
      'nilai': 'A',
    },
    {
      'dosen': 'Pak Rosyid',
      'matkul': 'Praktek Kecerdasan Buatan',
      'nilai': 'A',
    },
    {
      'dosen': 'Pak Rosyid',
      'matkul': 'Praktek Kecerdasan Buatan',
      'nilai': 'A',
    },
    {
      'dosen': 'Pak Rosyid',
      'matkul': 'Praktek Kecerdasan Buatan',
      'nilai': 'Belum Terisi',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomNavBar(currentIndex: 4, context: context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'NILAI',
          style: TextStyle(
            color: Color(0xFF1B2B50),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
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
            // Dropdown semester
            Align(
              alignment: Alignment.centerLeft,
              child: DropdownButton<String>(
                value: selectedSemester,
                underline: Container(),
                items: ['1', '2', '3', '4', '5', '6']
                    .map((sem) => DropdownMenuItem(
                          value: sem,
                          child: Text('Semester $sem'),
                        ))
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
              child: ListView.builder(
                itemCount: nilaiList.length,
                itemBuilder: (context, index) {
                  final item = nilaiList[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['dosen']!),
                              Text(
                                item['matkul']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B2B50),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            item['nilai']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: item['nilai'] == 'Belum Terisi'
                                  ? Colors.grey
                                  : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
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
}
