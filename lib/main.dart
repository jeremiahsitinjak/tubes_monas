import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Impor file splash screen yang baru dibuat

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monetary Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Tampilan pertama yaitu splashscreen
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}