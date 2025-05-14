import 'package:flutter/material.dart';
import 'package:mobile_mis_mahasiswa/widgets/frs_form.dart'; 
import 'package:mobile_mis_mahasiswa/widgets/jadwal_card.dart'; 
import 'package:mobile_mis_mahasiswa/widgets/nilai_card.dart'; 
import 'package:mobile_mis_mahasiswa/widgets/custom_navbar.dart'; 

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomNavBar(currentIndex: 0, context: context), 
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD7D4FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 6,
                      backgroundColor: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Selamat Datang',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('M Ghazali'),
                        Text('3123500033'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Features
              const Text(
                'Features',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _featureCard(context, Icons.edit_note, 'FRS', const FrsPage()),
                  _featureCard(context, Icons.calendar_month, 'Jadwal Kuliah', const JadwalCardPage()),
                  _featureCard(context, Icons.bar_chart, 'Nilai', const NilaiCardPage()),
                ],
              ),

              const SizedBox(height: 32),

              // Announcements
              const Text(
                'Announcements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _announcementCard('Judul Berita', 'Isi Berita'),
              _announcementCard('Judul Berita', 'Isi Berita'),
              _announcementCard('Judul Berita', 'Isi Berita'),
            ],
          ),
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
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _announcementCard(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1B2B50),
            ),
          ),
          const SizedBox(height: 4),
          Text(content),
        ],
      ),
    );
  }
}
