import 'package:flutter/material.dart';
import "login_page.dart";
import 'register_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // --- BAGIAN ATAS & TENGAH (Logo & Teks) ---
              // Menggunakan Expanded agar bagian ini mengisi ruang yang tersisa
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ikon
                    Container(
                      // Ukuran lingkaran
                      width: 150.0,
                      height: 150.0,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),

                      // Pusatkan gambar di dalam lingkaran
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo_monas.png',
                          // Ukuran gambar Logo
                          width: 150.0,
                          height: 150.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'MONAS',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Mari berkontribusi dan ciptakan perubahan nyata bersama kami.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Tombol Login dan Register
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tombol LOGIN
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                      // TODO Tambahkan navigasi ke halaman Login
                      print("Tombol Login Ditekan");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Warna utama
                      foregroundColor: Colors.white, // Warna teks
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tombol REGISTER
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                      // TODO Tambahkan navigasi ke halaman Register nanti
                      print("Tombol Register Ditekan");
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue, width: 3),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Create an Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20), // Jarak tambahan dari bawah layar
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
