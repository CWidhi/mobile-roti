import 'package:flutter/material.dart';
import 'login.dart';
import 'package:frontend_roti/controlers/auth/signup.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final controller = SignUpController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final error = await controller.signup();

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFFF7643),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Berhasil daftar! Silakan login.",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),

              /// LOGO
              Image.asset(
                "assets/img/logo_rb_circle.png",
                height: 120,
              ),

              const SizedBox(height: 32),

              /// TITLE
              const Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Buat akun baru",
                style: TextStyle(color: Color(0xFF757575)),
              ),

              const SizedBox(height: 32),

              /// FORM
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _input(
                      hint: "First Name",
                      controller: controller.firstName,
                      
                    ),
                    const SizedBox(height: 16),
                    _input(
                      hint: "Last Name",
                      controller: controller.lastName,
                    ),
                    const SizedBox(height: 16),
                    _input(
                      hint: "Email",
                      controller: controller.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _input(
                      hint: "Password",
                      controller: controller.password,
                      obscure: true,
                    ),

                    const SizedBox(height: 24),

                    /// BUTTON
                    ValueListenableBuilder<bool>(
                      valueListenable: controller.loading,
                      builder: (_, loading, __) {
                        return ElevatedButton(
                          onPressed: loading ? null : _handleSignup,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFFFF7643),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 52),
                            shape: const StadiumBorder(),
                          ),
                          child: loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    /// LOGIN LINK
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignInScreen()),
                        );
                      },
                      child: const Text.rich(
                        TextSpan(
                          text: "Sudah punya akun? ",
                          children: [
                            TextSpan(
                              text: "Sign In",
                              style: TextStyle(
                                color: Color(0xFFFF7643),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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

  Widget _input({
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF5F6F9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
