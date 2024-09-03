import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hellochat/components/appcolor.dart';
import 'package:hellochat/firebase_helper/firebase_helper.dart';
import 'package:hellochat/view/login_page.dart';
import 'package:hellochat/view/settings_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.snackbar(
        "Success",
        "Logout completed!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Future.delayed(const Duration(seconds: 1), () {
        Get.off(() => const LoginPage());
      });
    } catch (e) {
      print("Sign out error: $e");
      Get.snackbar(
        "Error",
        "Failed to sign out. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fireHelper = FireHelper(); // Create an instance of FireHelper

    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          Container(
            color: AppColors.primary,
            child: Column(
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(16)), // Rounded corners
                  ),
                  child: FutureBuilder<String>(
                    future: fireHelper.getUserName(), // Fetch user name
                    builder: (context, snapshot) {
                      String userName = 'User';
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          userName = snapshot.data!;
                        }
                      }
                      return Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(
                              'https://img.freepik.com/premium-vector/vector-professional-icon-business-illustration-line-symbol-people-management-career-set-c_1013341-74706.jpg',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Hello, $userName',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Column(
                  children: [
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      tileColor: AppColors.primaryLight,
                      title: const Text("H O M E",
                          style: TextStyle(color: Colors.white)),
                      leading: const Icon(Icons.home, color: Colors.white),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      height: 2,
                      color: Colors.white.withOpacity(0.3), // Decorative line
                    ),
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      tileColor: AppColors.primaryLight,
                      title: const Text("S E T T I N G S",
                          style: TextStyle(color: Colors.white)),
                      leading: const Icon(Icons.settings, color: Colors.white),
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => const SettingsPage());
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _signOut,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.white),
                  SizedBox(width: 8),
                  Text("L O G O U T", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
