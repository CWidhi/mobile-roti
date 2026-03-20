import 'package:flutter/material.dart';
import 'package:frontend_roti/services/auth/signup.dart';

class SignUpController {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  final ValueNotifier<bool> loading = ValueNotifier(false);

  Future<String?> signup() async {
    loading.value = true;

    final error = await SignupService.signup(
      email: email.text.trim(),
      firstName: firstName.text.trim(),
      lastName: lastName.text.trim(),
      password: password.text.trim(),
    );

    loading.value = false;
    return error;
  }

  void dispose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    password.dispose();
    loading.dispose();
  }
}
