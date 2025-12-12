import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubes_monas/landing_page.dart';
import 'package:tubes_monas/user/edit_profile.dart';
import 'package:http/http.dart' as http;
import 'package:tubes_monas/models/constants.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = "Loading...";
  String userEmail = "...";
  String? profileImagePath;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getProfileData();
  }

  Future<void> _getProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token != null) {
      try {
        final url = Uri.parse("$apiBase/profile");

        final response = await http.get(
          url,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
          },
        );

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final dataUser = jsonResponse['data'];

          if (mounted) {
            setState(() {
              userName = dataUser['name'];
              userEmail = dataUser['email'];
              profileImagePath = dataUser['image'];
              _isLoading = false;
            });
          }
        } else {
          print('Gagal ambil data: ${response.statusCode}');
          if (mounted) setState(() => _isLoading = false);
        }
      } catch (e) {
        print("Error koneksi: $e");
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    if (token != null) {
      try {
        final url = Uri.parse("$apiBase/logout");
        await http.post(
          url,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
          },
        );
      } catch (e) {
        print("Gagal request logout ke server: $e");
      }
    }

    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      print("Semua notifikasi berhasil dihapus.");
    } catch (e) {
      print("Gagal menghapus notifikasi: $e");
    }

    await prefs.remove('token');

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LandingPage()),
            (route) => false,
      );
    }
  }

  ImageProvider _buildProfileImage() {
    final path = profileImagePath;

    if (path == null || path.isEmpty) {
      return const AssetImage('assets/images/logo_monas.png');
    }

    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }

    if (path.contains('profile/')) {
      String baseUrl = apiBase.endsWith('/')
          ? apiBase.substring(0, apiBase.length - 1)
          : apiBase;
      return NetworkImage("$baseUrl/image-proxy/$path");
    }

    if (path.startsWith('http')) {
      return NetworkImage(path);
    }

    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 60),
            _buildUserInfoSection(),
            const SizedBox(height: 30),
            _buildActionButtons(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 160,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
        ),
        Positioned(
          top: 50,
          child: const Text(
            "Profile Saya",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Positioned(
          bottom: -50,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              backgroundImage: _buildProfileImage(),
              child: profileImagePath == null
                  ? null
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoSection() {
    return Column(
      children: [
        Text(
          userName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userEmail,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildModernTile(Icons.person_outline, "Nama Lengkap", userName),
              Divider(height: 1, color: Colors.grey[200], indent: 60),
              _buildModernTile(
                  Icons.email_outlined, "Email Address", userEmail),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
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
              icon: const Icon(Icons.edit_outlined, size: 20),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2193b0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
            label: const Text(
              "Keluar Akun",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}