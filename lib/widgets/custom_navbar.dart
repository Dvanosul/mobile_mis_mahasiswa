import 'package:flutter/material.dart';
import 'package:mobile_mis_mahasiswa/dashboard.dart';
import 'package:mobile_mis_mahasiswa/widgets/frs_form.dart';
import 'package:mobile_mis_mahasiswa/widgets/jadwal_card.dart';
import 'package:mobile_mis_mahasiswa/widgets/nilai_card.dart';
import 'package:mobile_mis_mahasiswa/login_page.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final BuildContext context;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.context,
  });

  void _onTap(int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
          (route) => false,
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FrsPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const JadwalCardPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NilaiCardPage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      backgroundColor: const Color(0xFF8F98F8),
      currentIndex: currentIndex,
      onTap: _onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          label: 'FRS',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          label: 'Jadwal',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grade_outlined),
          label: 'Nilai',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: 'Logout',
        ),
      ],
    );
  }
}
