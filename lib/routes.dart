import 'package:flutter/material.dart';
import 'package:mobile_mis_mahasiswa/screens/auth/login_screen.dart';
import 'package:mobile_mis_mahasiswa/screens/mahasiswa/home_screen.dart';
import 'package:mobile_mis_mahasiswa/screens/mahasiswa/frs_screen.dart';
import 'package:mobile_mis_mahasiswa/screens/mahasiswa/jadwal_screen.dart';
import 'package:mobile_mis_mahasiswa/screens/mahasiswa/nilai_screen.dart';
import 'package:mobile_mis_mahasiswa/screens/mahasiswa/profile_screen.dart';
import 'package:mobile_mis_mahasiswa/screens/splash_screen.dart';

class Routes {
  static const String login = '/login';
  static const String home = '/home';
  static const String frs = '/frs';
  static const String jadwal = '/jadwal';
  static const String nilai = '/nilai';
  static const String profile = '/profile';
  static const String splash = '/splash';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginPage(),
      home: (context) => const DashboardPage(),
      frs: (context) => const FrsPage(),
      jadwal: (context) => const JadwalCardPage(),
      nilai: (context) => const NilaiCardPage(),
      profile: (context) => const ProfileScreen(),
      splash: (context) => const SplashScreen(),
    };
  }
}