import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hellochat/components/my_drawer.dart';
import 'package:hellochat/view/login_page.dart';


class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Home",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout, size: 30),
          ),
        ],
      ),
      drawer: MyDrawer(),
    );
  }
}
