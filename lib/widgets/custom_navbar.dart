// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mobile_mis_mahasiswa/screens/mahasiswa/home_screen.dart';
import 'package:mobile_mis_mahasiswa/screens/mahasiswa/frs_screen.dart';
import 'package:mobile_mis_mahasiswa/screens/mahasiswa/jadwal_screen.dart';
import 'package:mobile_mis_mahasiswa/screens/mahasiswa/nilai_screen.dart';
import 'package:mobile_mis_mahasiswa/screens/mahasiswa/profile_screen.dart';

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
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar untuk responsif
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF8F98F8),
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 10 : 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: isSmallScreen ? 9 : 11,
          ),
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: _onTap,
          items: [
            _buildNavItem(Icons.home_rounded, Icons.home_outlined, 'Home', isSmallScreen),
            _buildNavItem(Icons.assignment_rounded, Icons.assignment_outlined, 'FRS', isSmallScreen),
            _buildNavItem(Icons.calendar_today_rounded, Icons.calendar_today_outlined, 'Jadwal', isSmallScreen),
            _buildNavItem(Icons.grade_rounded, Icons.grade_outlined, 'Nilai', isSmallScreen),
            _buildNavItem(Icons.person_rounded, Icons.person_outline, 'Profil', isSmallScreen),
          ],
        ),
      ),
    );
  }

  // Helper method untuk membuat item navbar dengan ikon aktif dan non-aktif
  BottomNavigationBarItem _buildNavItem(
    IconData activeIcon, 
    IconData inactiveIcon, 
    String label, 
    bool isSmallScreen
  ) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(bottom: isSmallScreen ? 2 : 4),
        child: Icon(
          inactiveIcon,
          size: isSmallScreen ? 22 : 26,
        ),
      ),
      activeIcon: Padding(
        padding: EdgeInsets.only(bottom: isSmallScreen ? 2 : 4),
        child: Icon(
          activeIcon,
          size: isSmallScreen ? 24 : 28,
        ),
      ),
      label: label,
    );
  }
}