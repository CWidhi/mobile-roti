import 'package:flutter/material.dart';
// import 'package:frontend_roti/screens/home.dart';
import 'package:frontend_roti/screens/navScreen.dart';
import 'package:frontend_roti/screens/auth/login.dart';
import 'package:frontend_roti/services/auth/login.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: LoginService.isLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return snapshot.data!
            ? const BottomNavScreen()
            : const SignInScreen();
      },
    );
  }
}
