import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_mis_mahasiswa/providers/auth_providers.dart';
import 'package:mobile_mis_mahasiswa/screens/splash_screen.dart'; // Import SplashScreen
import 'package:mobile_mis_mahasiswa/routes.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MIS Mahasiswa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: Routes.getRoutes(),
      initialRoute: Routes.splash,
      onUnknownRoute: (settings) {
        // Jika rute tidak diketahui, arahkan ke SplashScreen sebagai fallback
        // atau bisa juga ke LoginPage jika preferensi seperti itu
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      },
    );
  }
}