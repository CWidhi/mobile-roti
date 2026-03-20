import 'package:flutter/material.dart';
import 'screens/first_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_roti/services/auth/userService.dart';
import 'package:frontend_roti/screens/navScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const RotiBabeApp());
}

class RotiBabeApp extends StatelessWidget {
  const RotiBabeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Roti Babe',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: FutureBuilder(
        future: UserService.getMe(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.data != null) {
            return const BottomNavScreen();
          }

          return const SigninOrSignupScreen();
        },
      ),
    );
  }
}
