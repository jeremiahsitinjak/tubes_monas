import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubes_monas/register_page.dart';
import 'package:tubes_monas/user/nav.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue,
      body: SingleChildScrollView(
        child: Column(
          children: [_HeaderTampilan(), _FormLogin()]),
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
        // Konten Teks (Log in)
        Container(
          padding: const EdgeInsets.only(top: 75, bottom: 50),
          width: double.infinity,
          child: Column(
            children: const [
              Text(
                'Log in',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please sign in to your existing account',
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
            // SafeArea memastikan tombol tidak ketutup jam/sinyal HP
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new, // Ikon panah ke kiri
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  // Reverse navigation ke halaman sebelumnya
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

class _FormLogin extends StatefulWidget {
  const _FormLogin();

  @override
  State<_FormLogin> createState() => _FormLoginState();
}

class _FormLoginState extends State<_FormLogin> {
  bool _passwordVisible = false;
  bool _rememberMe = false;

  // Controller untuk validasi sederhana form (kosong atau tidak)
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Widget _socialMediaButton({required IconData icon, required Color color}) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      margin: EdgeInsets.only(right: 30),
      child: Icon(icon, color: Colors.white, size: 20),
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
          const Text(
            'Email',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'email@example.com',
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
            ),
          ),

          //Container Password
          const SizedBox(height: 24),

          const Text(
            'Password',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _passwordController,
            obscureText: !_passwordVisible,
            decoration: InputDecoration(
              hintText: '••••••••',
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
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  StatefulBuilder(
                    builder: (context, setState) {
                      bool rememberMe = false;
                      return Checkbox(
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF3234EE),
                      );
                    },
                  ),
                  const Text(
                    "Remember me",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),

              // TextButton(
              //   onPressed: () {},
              //   child: const Text(
              //     "Forgot password?",
              //     style: TextStyle(
              //       color: Colors.grey,
              //       fontSize: 14,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),

            ],
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () { // TODO koneksikan ke backend autentikasi
                // Untuk sementara disable validasi
                // if (_emailController.text.isEmpty || 
                //     _passwordController.text.isEmpty) {
                //   // Tampilkan pesan error jika email atau password kosong
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(
                //       content: Text('Please enter both email and password.'),
                //     ),
                //   );
                //   return;
                // }

                // Jika validasi berhasil, navigasi ke HomePage
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const NavPage()),
                );

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),

              child: const Text(
                'LOG IN',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

            ),
          ),

// Pastikan Anda mengimpor halaman register Anda
// import 'package:nama_aplikasi/register_page.dart'; 

SizedBox(height: 38),
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Text('Dont have an account?'),
    const SizedBox(width: 10),
    
    // Ganti Text biasa dengan GestureDetector
    GestureDetector(
      onTap: () {
        // --- LOGIKA NAVIGASI DITAMBAHKAN DI SINI ---
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RegisterPage(), // Ganti dengan nama widget Register Anda
          ),
        );
      },
      child: const Text(
        'Sign Up',
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
),

          // Row(
          //   children: [
          //     Expanded(child: Divider()),
          //     Padding(
          //       padding: EdgeInsets.symmetric(horizontal: 10),
          //       child: Text('OR'),
          //     ),
          //     Expanded(child: Divider()),
          //   ],
          // ),

          // SizedBox(height: 15),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     _socialMediaButton(
          //       icon: Icons.facebook,
          //       color: Color(0xFF395998),
          //     ),
          //     _socialMediaButton(icon: Icons.apple, color: Color(0xFF1B1F2F)),
          //     _socialMediaButton(
          //       icon: Icons.add_shopping_cart,
          //       color: Color(0xFF169CE8),
          //     ),
          //   ],
          // ),

        ],
      ),
    );
  }
}
