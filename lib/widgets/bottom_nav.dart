import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home_page.dart';
import '../tools_page.dart';
import '../login_page.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            FirebaseAuth.instance.signOut().then((_) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            });
            break;
          case 1:
            if (currentIndex != 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            }
            break;
          case 2:
            if (currentIndex != 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ToolsPage()),
              );
            }
            break;
        }
      },
      backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      elevation: 10,
      selectedItemColor: isDark ? Colors.lightBlueAccent : Colors.blueAccent,
      unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: 'Logout',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Tools',
        ),
      ],
    );
  }
}
