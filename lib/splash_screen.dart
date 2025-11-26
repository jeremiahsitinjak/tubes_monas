import 'package:flutter/material.dart';
import 'dart:async'; // Diperlukan untuk Timer
import 'landing_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Memulai timer untuk navigasi setelah beberapa detik
    Timer(const Duration(seconds: 5), () {
      // Setelah 5 detik, navigasi ke HomePage dan hapus semua rute sebelumnya
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => const LandingPage(), // Ganti widget
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Warna latar belakang splash screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Ikon
              Image.asset(
                'assets/images/logo_monas.png',
                width: 100.0,
                height: 100.0,
                color: Colors.white,
              ),

            SizedBox(height: 20.0),

            // Teks
            Text(
              "MONAS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Progress Indicator
            SizedBox(height: 50.0),
            CircularProgressIndicator(color: Colors.white),
            
          ],
        ),
      ),
    );
  }
}