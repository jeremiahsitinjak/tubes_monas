import 'package:flutter/material.dart';

// 1. Definisikan Halaman Placeholder
// Biasanya, Anda akan membuat file terpisah untuk setiap halaman (HistoryPage, ProfilePage).
// Untuk tujuan pengujian, kita buat placeholder sederhana.

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Halaman Riwayat', style: TextStyle(fontSize: 24)));
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Halaman Profil', style: TextStyle(fontSize: 24)));
  }
}


// 2. Ubah HomePage menjadi StatefulWidget
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variabel untuk melacak indeks tab yang dipilih
  int _selectedIndex = 0;

  // Daftar widget/halaman yang akan ditampilkan (sesuai urutan di navbar)
  static final List<Widget> _widgetOptions = <Widget>[
    // Index 0: Home Page (konten asli HomePage Anda)
    const Center(child: Text('Konten Halaman Utama', style: TextStyle(fontSize: 24))),
    
    // Index 1: History Page
    const HistoryPage(), 
    
    // Index 2: Profile Page
    const ProfilePage(),
  ];

  // Fungsi yang dipanggil saat tab baru diklik
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Perbarui indeks yang dipilih
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_widgetOptions[_selectedIndex].toString()), // Menampilkan judul sesuai halaman
        backgroundColor: Colors.indigo,
      ),
      
      // 3. Menampilkan Halaman yang Dipilih
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      
      // 4. Implementasi BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        // Properti utama untuk mengontrol navbar:
        currentIndex: _selectedIndex, // Indeks mana yang sedang aktif
        selectedItemColor: Colors.indigo, // Warna ikon/teks yang dipilih
        onTap: _onItemTapped, // Fungsi yang dipanggil saat item diklik
      ),
    );
  }
}