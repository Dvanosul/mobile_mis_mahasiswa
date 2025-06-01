import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_mis_mahasiswa/providers/auth_providers.dart';
import 'package:mobile_mis_mahasiswa/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Panggil metode di AuthProvider untuk memeriksa status login
    // dan memuat data pengguna jika sudah login
    bool isLoggedIn = await authProvider.tryAutoLogin();

    if (mounted) { // Pastikan widget masih ada di tree
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, Routes.home);
      } else {
        Navigator.pushReplacementNamed(context, Routes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Atau tampilkan logo aplikasi Anda
      ),
    );
  }
}