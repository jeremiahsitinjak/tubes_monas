import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tubes_monas/user/edit_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = "Anna Ann";
  String userEmail = "user@gmail.com";
  String? profileImagePath = 'assets/images/logo_monas.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // Appbar Profile
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        automaticallyImplyLeading: false, // HILANGKAN TOMBOL BACK
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white),
        ),

        // Tombol Logout di AppBar
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout, 
              color: Colors.white
            ),
            onPressed: () {
                // --- LOGIKA ALERT DI SINI ---
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Konfirmasi Logout"),
                    content: const Text("Apakah Anda yakin ingin keluar (logout)?"),
                    actions: <Widget>[
                      // Tombol NO (Membatalkan)
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Tutup dialog
                        },
                        child: const Text("TIDAK", style: TextStyle(color: Colors.grey)),
                      ),
                      // Tombol YES (Melanjutkan Logout)
                      TextButton(
                        onPressed: () {
                          // Tutup dialog
                          Navigator.of(context).pop(); 
                          
                          // TODO Tambahkan logika logout dan navigasi ke halaman login di sini
                          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                          
                          // Notifikasi untuk sementara
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Anda Berhasil Logout!')),
                          );
                        },
                        child: const Text("YA", style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  );
                },
              );

            },
          ),
        ],

      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bagian Header menggunakan warna tunggal (Colors.blue)
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 40),
              decoration: BoxDecoration(
                // Menggunakan satu warna solid biru
                color: Colors.blue,
              ),

              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Profile Picture
                  Positioned(
                    // top:20,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white, // Border putih
                      child: CircleAvatar(
                        radius: 54,
                        backgroundImage: _buildProfileImage(),
                        backgroundColor: Colors.grey.shade200,
                        child: profileImagePath == null
                            ? const Icon(Icons.person, size: 60, color: Colors.grey)
                            : null,
                      ),
                    ),
                  ),

                ],
              ),
            ),

            // Bagian Informasi (Nama dan Email)
            _buildProfileInfoTile(
              icon: Icons.person,
              label: 'Nama',
              value: userName,
              showArrow: false,
            ),
            const Divider(indent: 16, endIndent: 16),
            
            _buildProfileInfoTile(
              icon: Icons.email,
              label: 'Email',
              value: userEmail,
              showArrow: false,
            ),
            const Divider(indent: 16, endIndent: 16),

            const SizedBox(height: 40),

            // Tombol Edit Profile (Warna Solid Colors.blue)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final updatedData = await Navigator.push<Map<String, String>>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfilePage(
                          initialName: userName,
                          initialEmail: userEmail,
                          initialImagePath: profileImagePath,
                        ),
                      ),
                    );

                    if (updatedData != null) {
                      setState(() {
                        userName = updatedData['name'] ?? userName;
                        userEmail = updatedData['email'] ?? userEmail;
                        profileImagePath = updatedData['image'] ?? profileImagePath;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    // Menggunakan warna solid Colors.blue
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Edit profile',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget Pembantu untuk Baris Informasi
  Widget _buildProfileInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool showArrow = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Warna ikon diubah menjadi Colors.blue
          Icon(icon, color: Colors.blue, size: 24), 
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          if (showArrow)
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        ],
      ),
    );
  }

  ImageProvider _buildProfileImage() {
    final path = profileImagePath;
    if (path == null || path.isEmpty) {
      return const AssetImage('assets/images/logo_monas.png');
    }
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    return FileImage(File(path));
  }
}