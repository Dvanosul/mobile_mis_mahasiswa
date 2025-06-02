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

  Map<String, List<dynamic>> jadwal = {};
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

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan saat memuat jadwal';
        isLoading = false;
      });
    }
  }

  Map<String, List<dynamic>> _groupJadwalByDay(List<dynamic> jadwalList) {
    final Map<String, List<dynamic>> grouped = {};

    for (var item in jadwalList) {
      if (item is! Map) continue;

      final String hari = item['hari']?.toString() ?? 'Tidak diketahui';

      if (!grouped.containsKey(hari)) {
        grouped[hari] = [];
      }

      grouped[hari]!.add(item);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF8F98F8);
    final List<String> hariUrut = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];

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
                  children:
                      hariUrut.where((hari) => jadwal.containsKey(hari)).map((
                        hari,
                      ) {
                        final List<dynamic> matkulList = jadwal[hari]!;

                        return SizedBox(
                          width: double.infinity,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    hari,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children:
                                        matkulList.map((matkul) {
                                          return Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 6,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: primaryColor.withOpacity(
                                                  0.3,
                                                ),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  matkul['mata_kuliah'] ?? '',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color: primaryColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text('Kode: ${matkul['kode']}'),
                                                Text(
                                                  'Ruang: ${matkul['ruang']}',
                                                ),
                                                Text('Jam: ${matkul['waktu']}'),
                                                Text(
                                                  'Dosen: ${matkul['dosen']}',
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                  ),
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
      ),
    );
  }
}
