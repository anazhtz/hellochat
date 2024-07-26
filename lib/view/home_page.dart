import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hellochat/components/my_drawer.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "H O M E",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: MyDrawer(),
    );
  }
}
