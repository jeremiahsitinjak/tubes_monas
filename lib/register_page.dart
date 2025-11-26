import 'package:flutter/material.dart';
// import 'login_page.dart'; // Asumsikan Anda ingin kembali ke LoginPage

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Warna latar belakang yang sama dengan halaman login
      backgroundColor: const Color.fromARGB(255, 25, 75, 175), 
      body: SingleChildScrollView(
        child: Column(
          children: [
            const _HeaderTampilan(), 
            _FormRegister(),
          ],
        ),
      ),
    );
  }
}

class _HeaderTampilan extends StatelessWidget {
  const _HeaderTampilan();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Konten Teks (Sign Up)
        Container(
          padding: const EdgeInsets.only(top: 118, bottom: 50),
          width: double.infinity,
          child: const Column(
            children: [
              Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Create your new account easily',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),

        // Tombol Return
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new, // Ikon panah ke kiri
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  // Kembali ke halaman sebelumnya (misalnya LoginPage)
                  Navigator.pop(context); 
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FormRegister extends StatefulWidget {
  @override
  State<_FormRegister> createState() => _FormRegisterState();
}

class _FormRegisterState extends State<_FormRegister> {
  bool _passwordVisible = false;
  // State untuk konfirmasi password agar bisa disembunyikan/ditampilkan terpisah
  bool _confirmPasswordVisible = false; 

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // Controller baru untuk konfirmasi password
  final TextEditingController _confirmPasswordController = TextEditingController(); 

  // Widget pembantu untuk input field
  Widget _inputField({
      required String label,
      required String hint,
      required TextEditingController controller,
      bool isPassword = false,
      bool isConfirmPassword = false}) {
    // Tentukan state visibility mana yang akan digunakan
    bool currentVisibility = isConfirmPassword ? _confirmPasswordVisible : _passwordVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? !currentVisibility : false,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF0F5FA),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 19,
              horizontal: 22.5,
            ),
            // Tambahkan ikon visibilitas hanya untuk password
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        if (isConfirmPassword) {
                          _confirmPasswordVisible = !_confirmPasswordVisible;
                        } else {
                          _passwordVisible = !_passwordVisible;
                        }
                      });
                    },
                    icon: Icon(
                      currentVisibility
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Input Nama Lengkap
          _inputField(
            label: 'Full Name',
            hint: 'Enter your full name',
            controller: _nameController,
          ),

          const SizedBox(height: 24),

          // 2. Input Email
          _inputField(
            label: 'Email',
            hint: 'email@example.com',
            controller: _emailController,
          ),

          const SizedBox(height: 24),

          // 3. Input Password
          _inputField(
            label: 'Password',
            hint: '••••••••',
            controller: _passwordController,
            isPassword: true,
            isConfirmPassword: false,
          ),

          const SizedBox(height: 24), // Spasi tambahan untuk konfirmasi password

          // Input Konfirmasi Password BARU
          _inputField(
            label: 'Confirm Password',
            hint: '••••••••',
            controller: _confirmPasswordController,
            isPassword: true,
            isConfirmPassword: true, // Set flag konfirmasi password
          ),

          const SizedBox(height: 32),

          // Tombol SIGN UP
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // 1. Cek apakah semua field terisi
                if (_nameController.text.isEmpty ||
                    _emailController.text.isEmpty ||
                    _passwordController.text.isEmpty ||
                    _confirmPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields.'),
                    ),
                  );
                  return;
                }
                
                // 2. Cek apakah password cocok
                if (_passwordController.text != _confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password and Confirm Password do not match.'),
                    ),
                  );
                  return;
                }
                
                // TODO: Hubungkan ke fungsi autentikasi register
                
                // Jika validasi berhasil, navigasi
                Navigator.pop(context); // Kembali ke halaman sebelumnya
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'SIGN UP',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 38),
          
          // Link ke Halaman Login (sudah punya akun)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already have an account?'),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                   Navigator.pop(context); // Kembali ke LoginPage
                },
                child: const Text(
                  'Log in', 
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}