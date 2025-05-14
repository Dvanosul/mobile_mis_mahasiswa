import 'package:flutter/material.dart';
import 'package:mobile_mis_mahasiswa/widgets/custom_navbar.dart';

class FrsPage extends StatefulWidget {
  const FrsPage({super.key});

  @override
  State<FrsPage> createState() => _FrsPageState();
}

class _FrsPageState extends State<FrsPage> {
  // Dummy data mata kuliah
  final List<Map<String, String>> allCourses = [
    {
      'kode': 'MPI',
      'dosen': 'Pak Rosyid',
      'nama': 'Praktek Kecerdasan Buatan',
      'jadwal': 'Senin 08.00 - 09.40'
    },
    {
      'kode': 'MW',
      'dosen': 'Pak Rosyid',
      'nama': 'Praktek Kecerdasan Buatan',
      'jadwal': 'Senin 08.00 - 09.40'
    },
    {
      'kode': 'MPI',
      'dosen': 'Pak Rosyid',
      'nama': 'Praktek Kecerdasan Buatan',
      'jadwal': 'Senin 08.00 - 09.40'
    },
  ];

  List<Map<String, String>> selectedCourses = [];

  void addCourse(Map<String, String> course) {
    if (!selectedCourses.contains(course)) {
      setState(() {
        selectedCourses.add(course);
      });
    }
  }

  void removeCourse(Map<String, String> course) {
    setState(() {
      selectedCourses.remove(course);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'FRS D3 IT A',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.info_outline, color: Colors.black),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Kotak atas (selected courses)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                children: selectedCourses.map((course) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(
                        course['nama']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B2B50),
                        ),
                      ),
                      subtitle: Text('${course['dosen']} \n${course['jadwal']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => removeCourse(course),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Kotak bawah (all courses)
            ...allCourses.map((course) {
              final isSelected = selectedCourses.contains(course);
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(
                    course['nama']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2B50),
                    ),
                  ),
                  subtitle: Text('${course['kode']} \n${course['jadwal']}'),
                  trailing: IconButton(
                    icon: Icon(
                      isSelected ? Icons.check_circle : Icons.add_circle_outline,
                      color: isSelected ? Colors.green : Colors.grey,
                    ),
                    onPressed: isSelected ? null : () => addCourse(course),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: 1, // 1 karena FrsPage adalah halaman kedua
        context: context,
      ),
    );
  }
}
