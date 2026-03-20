import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_roti/constants/svgs.dart';
import 'package:frontend_roti/screens/profileScreen.dart';
import 'package:frontend_roti/services/auth/login.dart';
import 'package:frontend_roti/screens/auth/login.dart';
import 'package:frontend_roti/screens/home.dart';
import 'package:frontend_roti/screens/purchase/purchaseListScreen.dart';
import 'package:frontend_roti/screens/payment/paymentScreen.dart';
import 'package:frontend_roti/services/auth/userService.dart';
import 'package:frontend_roti/screens/order/orderListScreen.dart';

const Color inActiveIconColor = Color(0xFFB6B6B6);

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int currentSelectedIndex = 0;

  bool isLoading = true;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  Future<void> _loadMe() async {
    try {
      final me = await UserService.getMe();
      if (me != null) {
        isAdmin = me['is_staff'] == true;
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void updateCurrentIndex(int index) {
    setState(() {
      currentSelectedIndex = index;
    });
  }

  List<Widget> get pages => [
    const HomeScreen(),
    OrderPickingListScreen(isAdmin: isAdmin),
   isAdmin
      ? const PurchaseListScreen() // admin lihat semua purchase
      : const PaymentListScreen(), // user biasa ke pembayaran dia sendiri
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return WillPopScope(
      onWillPop: () async {
        // 🔥 JIKA BUKAN HOME → BALIK KE HOME
        if (currentSelectedIndex != 0) {
          setState(() {
            currentSelectedIndex = 0;
          });
          return false; // jangan keluar app
        }
        return true; // boleh keluar app dari home
      },
      child: Scaffold(
        endDrawer: Drawer(
          width: MediaQuery.of(context).size.width * 0.6,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                /// PROFILE
                ListTile(
                  leading: const Icon(Icons.person_rounded),
                  title: const Text("Profile"),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      currentSelectedIndex = 3;
                    });
                  },
                ),

                /// LOGOUT
                ListTile(
                  leading: const Icon(Icons.logout_rounded),
                  title: const Text("Logout"),
                  onTap: () async {
                    Navigator.pop(context);
                    await LoginService.logout();

                    if (!context.mounted) return;

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignInScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        /// 🔥 PENTING: IndexedStack biar state aman
        body: IndexedStack(
          index: currentSelectedIndex,
          children: pages,
        ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentSelectedIndex,
          onTap: updateCurrentIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.string(
                homeIcon,
                colorFilter: const ColorFilter.mode(
                  inActiveIconColor,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.string(
                homeIcon,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFFF7643),
                  BlendMode.srcIn,
                ),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.string(
                orderingIcon,
                colorFilter: const ColorFilter.mode(
                  inActiveIconColor,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.string(
                orderingIcon,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFFF7643),
                  BlendMode.srcIn,
                ),
              ),
              label: "Ordering",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.string(
                chatIcon,
                colorFilter: const ColorFilter.mode(
                  inActiveIconColor,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.string(
                chatIcon,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFFF7643),
                  BlendMode.srcIn,
                ),
              ),
              label: "Purchase",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.string(
                userIcon,
                colorFilter: const ColorFilter.mode(
                  inActiveIconColor,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.string(
                userIcon,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFFF7643),
                  BlendMode.srcIn,
                ),
              ),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
