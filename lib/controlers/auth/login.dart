import 'package:flutter/material.dart';
import 'package:frontend_roti/services/auth/login.dart';

class LoginController {
  final email = TextEditingController();
  final password = TextEditingController();

  final ValueNotifier<bool> loading = ValueNotifier(false);

  Future<String?> login() async {
    loading.value = true;

    final error = await LoginService.login(
      email: email.text.trim(),
      password: password.text.trim(),
    );

    loading.value = false;
    return error;
  }

  void dispose() {
    email.dispose();
    password.dispose();
    loading.dispose();
  }
}
