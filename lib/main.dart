import 'package:flutter/material.dart';
import 'package:hellochat/theme/light_mode.dart';
import 'package:hellochat/view/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      theme: lightMode,
    );
  }
}
