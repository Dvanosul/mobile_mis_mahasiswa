// ignore_for_file: use_build_context_synchronously, use_super_parameters

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_mis_mahasiswa/providers/auth_providers.dart';
import 'package:mobile_mis_mahasiswa/services/mahasiswa_service.dart';
import 'package:mobile_mis_mahasiswa/screens/auth/login_screen.dart';
import 'package:mobile_mis_mahasiswa/widgets/custom_navbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final MahasiswaService _mahasiswaService = MahasiswaService();
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _mahasiswaService.getProfile();
      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data profil: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true, // Memungkinkan body area diperluas ke belakang AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar transparan
        elevation: 0,
        title: const Text(
          'Profil Mahasiswa',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProfileData,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    // Background gradient header yang menutupi seluruh bagian atas
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 350, // Tinggi ditambah agar mencakup area status bar dan app bar
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF8F98F8), Color(0xFFD7D4FB)],
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    
                    // Content
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Tambahkan padding di atas untuk memperhitungkan AppBar
                          SizedBox(height: AppBar().preferredSize.height + MediaQuery.of(context).padding.top),
                          // Profile card
                            SizedBox(
                            width: 320,
                            height: 220, 
                            child: Card(
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                // Avatar
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                  child: Container(
                                    color: const Color(0xFFD7D4FB),
                                    child: const Icon(
                                    Icons.person,
                                    size: 100,
                                    color: Color(0xFF8F98F8),
                                    ),
                                  ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Nama mahasiswa
                                Text(
                                  _profileData?['name'] ?? '-',
                                  style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B2B50),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _profileData?['nrp'] ?? '-',
                                  style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  ),
                                ),
                                ],
                              ),
                              ),
                            ),
                            ),
                          
                          const SizedBox(height: 24),

                          // Email card
                          _buildDetailCard(
                            'Email',
                            _profileData?['email'] ?? '-',
                            Icons.email,
                            const Color(0xFFE3F2FD),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Semester dan Kelas dalam satu baris
                          _buildDualDetailCard(
                            'Semester', 
                            _profileData?['semester']?.toString() ?? '-',
                            Icons.calendar_today,
                            const Color(0xFFE8F5E9),
                            'Kelas',
                            (_profileData?['kelas'] as Map<String, dynamic>?)?['nama'] ?? '-',
                            Icons.class_,
                            const Color(0xFFF3E5F5),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Dosen Wali card
                          _buildDetailCard(
                            'Dosen Wali',
                            (_profileData?['kelas'] as Map<String, dynamic>?)?['dosen_wali'] ?? '-',
                            Icons.person_outline,
                            const Color(0xFFE0F2F1),
                          ),
  
                          const SizedBox(height: 30),
                          
                          // Tombol logout
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await authProvider.logout();
                                if (!mounted) return;
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                  (route) => false,
                                );
                              },
                              icon: const Icon(Icons.logout),
                              label: const Text('Logout'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          
                          // Padding at bottom for comfort
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: CustomNavBar(currentIndex: 4, context: context),
    );
  }


  Widget _buildDetailCard(String label, String value, IconData icon, Color backgroundColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24, color: const Color(0xFF1B2B50)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2B50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDualDetailCard(
    String label1,
    String value1,
    IconData icon1,
    Color backgroundColor1,
    String label2,
    String value2,
    IconData icon2,
    Color backgroundColor2,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildDetailCard(label1, value1, icon1, backgroundColor1),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDetailCard(label2, value2, icon2, backgroundColor2),
        ),
      ],
    );
  }
}