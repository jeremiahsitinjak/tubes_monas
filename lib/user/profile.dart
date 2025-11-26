import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  // Data dummy
  final String userName = "Anna Avetisyan";
  final String userEmail = "info@aplusdesign.co";
  final String profileImageUrl = 'https://via.placeholder.com/150';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bagian Header menggunakan warna tunggal (Colors.blue)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                // Menggunakan satu warna solid biru
                color: Colors.blue,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Profile Picture
                  Positioned(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white, // Border putih
                      child: CircleAvatar(
                        radius: 47,
                        backgroundImage: NetworkImage(profileImageUrl),
                        backgroundColor: Colors.grey.shade200,
                        child: profileImageUrl.isEmpty
                            ? const Icon(Icons.person, size: 60, color: Colors.grey)
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 60), 

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

            const SizedBox(height: 30),

            // Tombol Edit Profile (Warna Solid Colors.blue)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit profile pressed')),
                    );
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
}