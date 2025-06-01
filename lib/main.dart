import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_mis_mahasiswa/providers/auth_providers.dart';
import 'package:mobile_mis_mahasiswa/screens/auth/login_screen.dart';
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
      ),
      routes: Routes.getRoutes(),
      initialRoute: Routes.login,
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (_) => const LoginPage());
      },
    );
  }
}
