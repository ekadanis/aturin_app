import 'package:aturin_app/features/login/ui/login_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isPasswordVisible = false;

  // VALIDATOR
  bool get hasUppercase => passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get hasSymbol =>
      passwordController.text.contains(RegExp(r'[!@#\$&*~._-]'));
  bool get hasMinLength => passwordController.text.length >= 8;
  bool get noSpaces => !passwordController.text.contains(' ');
  bool get isNotEmpty => passwordController.text.isNotEmpty;

  double get strengthValue {
    int passed =
        [
          hasUppercase,
          hasSymbol,
          hasMinLength,
          noSpaces,
          isNotEmpty,
        ].where((e) => e).length;

    return passed / 5;
  }

  String get strengthLabel {
    if (strengthValue <= 0.4) return "Lemah";
    if (strengthValue <= 0.7) return "Sedang";
    if (strengthValue <= 0.99) return "Baik";
    return "Kuat";
  }

  Color get strengthColor {
    if (strengthValue <= 0.4) return Colors.red;
    if (strengthValue <= 0.7) return Colors.yellow;
    if (strengthValue <= 0.99) return Colors.orange;
    return Colors.green;
  }

  @override
  void initState() {
    super.initState();
    passwordController.addListener(() => setState(() {}));
    confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Image.asset(
                  'assets/images/register2.png', // ilustrasi login
                  height: 150,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Masuk ke ',
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: 'Atur',
                            style: TextStyle(color: Color(0xFF5263F3)),
                          ),
                          TextSpan(
                            text: 'in',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      'Aturin siap bantu kamu, yuk mulai sekarang!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Text('Nama', style: GoogleFonts.plusJakartaSans(fontSize: 16)),
              const SizedBox(height: 8),
              _buildTextField(
                hintText: 'Masukkan Nama',
                icon: Icons.person_outline,
                obscureText: false,
              ),

              const SizedBox(height: 16),
              Text('Email', style: GoogleFonts.plusJakartaSans(fontSize: 16)),
              const SizedBox(height: 8),
              _buildTextField(
                hintText: 'contoh@gmail.com',
                icon: Icons.email_outlined,
                obscureText: false,
              ),

              const SizedBox(height: 16),
              Text(
                'Kata Sandi',
                style: GoogleFonts.plusJakartaSans(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  hintText: "****************",
                  prefixIcon: const Icon(Icons.vpn_key),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed:
                        () => setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        }),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 237, 243, 255),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'Konfirmasi Kata Sandi',
                style: GoogleFonts.plusJakartaSans(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmPasswordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  hintText: "****************",
                  prefixIcon: const Icon(Icons.vpn_key),
                  suffixIcon:
                      passwordController.text.isNotEmpty
                          ? Icon(
                            confirmPasswordController.text ==
                                    passwordController.text
                                ? Icons.check_circle
                                : Icons.cancel,
                            color:
                                confirmPasswordController.text ==
                                        passwordController.text
                                    ? Colors.green
                                    : Colors.red,
                          )
                          : null,
                  filled: true,
                  fillColor: const Color.fromARGB(255, 237, 243, 255),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              if (passwordController.text.isNotEmpty) ...[
                const SizedBox(height: 10),
                segmentedProgressIndicator(strengthValue),

                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      strengthLabel,
                      style: TextStyle(color: strengthColor, fontSize: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildCriteria('8+ karakter', hasMinLength),
                    _buildCriteria('huruf besar (A–Z)', hasUppercase),
                    _buildCriteria('simbol (!@#...)', hasSymbol),
                    _buildCriteria('tanpa spasi', noSpaces),
                    _buildCriteria('tidak boleh kosong', isNotEmpty),
                  ],
                ),
              ],

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (passwordController.text !=
                      confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Konfirmasi kata sandi tidak cocok."),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: const Color(0xFF5C6EF8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Daftar"),
              ),

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sudah punya akun? Yuk langsung ',
                      style: TextStyle(
                        color: Color.fromARGB(255, 128, 128, 128),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero, // Hapus padding bawaan
                        minimumSize: Size(0, 2), // Hapus ukuran minimum
                      ),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    required bool obscureText,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 237, 243, 255),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20),
          suffixIcon: suffixIcon,
          hintText: hintText,
          filled: true,
          fillColor: const Color.fromARGB(255, 237, 243, 255),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCriteria(String text, bool passed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          passed ? Icons.check_circle : Icons.circle,
          color: passed ? Colors.green : Colors.grey,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: passed ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget segmentedProgressIndicator(double strengthValue) {
    int totalSegments = 4;
    double segmentValue = 1.0 / totalSegments;

    return Row(
      children: List.generate(totalSegments, (index) {
        bool isFilled = strengthValue >= (segmentValue * (index + 1));
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 2), // Jarak antar segmen
            height: 4,
            decoration: BoxDecoration(
              color: isFilled ? strengthColor : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
