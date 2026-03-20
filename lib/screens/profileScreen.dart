import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_roti/constants/svgs.dart';
import 'package:frontend_roti/services/auth/login.dart';
import 'package:frontend_roti/screens/auth/login.dart';
import 'package:frontend_roti/screens/auth/accountScreen.dart';
import 'package:frontend_roti/services/auth/userService.dart';
import 'package:frontend_roti/screens/users/listUsersScreen.dart';
import 'package:frontend_roti/screens/addUser/addRuteToUserScreen.dart';
import 'package:frontend_roti/screens/addUser/removeRuteToUserScreen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        // title: const Text("Profile"),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: UserService.getMe(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Gagal memuat data user"));
          }

          final user = snapshot.data!;
          final bool isStaff = user['is_staff'] == true;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const ProfilePic(),
                const SizedBox(height: 20),

                ProfileMenu(
                  text: "My Account",
                  iconSvg: profileIcon,
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AccountScreen()),
                    );
                  },
                ),

                if (isStaff)
                  ProfileMenu(
                    text: "Users Data",
                    iconSvg: usersGroupIcon,
                    press: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UsersScreen()),
                    );
                    },
                  ),
                if (isStaff)
                  ProfileMenu(
                    text: "Add User to Rute",
                    iconSvg: routeIcon,
                    press: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RuteAddUserScreen()),
                    );
                    },
                  ),
                if (isStaff)
                  ProfileMenu(
                    text: "Remove User to Rute",
                    iconSvg: routeIcon,
                    press: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RuteRemoveUserScreen()),
                    );
                    },
                  ),

                ProfileMenu(
                  text: "Log Out",
                  iconSvg: logoutIcon,
                  press: () async {
                    await LoginService.logout();

                    if (!context.mounted) return;

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProfilePic extends StatelessWidget {
  const ProfilePic({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 115,
      width: 115,
      child: CircleAvatar(
        backgroundImage: AssetImage("assets/img/avatar.png"),
      ),
    );
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    Key? key,
    required this.text,
    this.icon,
    this.iconSvg,
    this.press,
  }) : super(key: key);

  final String text;
  final String? icon; // untuk asset SVG
  final String? iconSvg; // untuk SVG string
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFFF7643),
          padding: const EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: const Color(0xFFF5F6F9),
        ),
        onPressed: press,
        child: Row(
          children: [
            if (icon != null)
              SvgPicture.asset(
                icon!,
                colorFilter:
                    const ColorFilter.mode(Color(0xFFFF7643), BlendMode.srcIn),
                width: 22,
              ),
            if (iconSvg != null)
              SvgPicture.string(
                iconSvg!,
                colorFilter:
                    const ColorFilter.mode(Color(0xFFFF7643), BlendMode.srcIn),
                width: 22,
              ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF757575),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
