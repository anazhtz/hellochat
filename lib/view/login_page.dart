import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hellochat/components/appcolor.dart';
import 'package:hellochat/components/custome_textfield.dart';
import 'package:hellochat/components/my_button.dart';
import 'package:hellochat/firebase_helper/firebase_helper.dart';
import 'package:hellochat/view/home_page.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _handleLogin() async {
    if (!isLoading && formKey.currentState?.validate() == true) {
      setState(() {
        isLoading = true;
      });

      // Saving form state
      formKey.currentState?.save();

      // Perform sign in
      bool isSuccess = await FireHelper().signIn(
        email: emailController.text,
        password: passwordController.text,
      );

      setState(() {
        isLoading = false;
      });

      if (isSuccess) {
        Get.snackbar(
          "Success",
          "Login successful!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green, // Adjust this color as needed
          colorText: Colors.white,
        );
        Future.delayed(const Duration(seconds: 1), () {
          Get.to(() => HomePage());
        });
      } else {
        Get.snackbar(
          "Error",
          "Invalid email or password",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Theme.of(context)
              .colorScheme
              .error, // Adjust this color as needed
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Update the background color
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //logo
                const Image(
                  image: AssetImage("assets/Designer__4_-removebg-preview.png"),
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 50),
                //welcome message
                const Text(
                  "Welcome to HelloChat",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                //email textfield
                CustomeTextfield(
                  controller: emailController,
                  obscureText: false,
                  hintText: "Email",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                //password textfield
                CustomeTextfield(
                  controller: passwordController,
                  obscureText: true,
                  hintText: "Password",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                //login button
                MyButton(
                  text: 'Login',
                  onTap: _handleLogin,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 25),
                //register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Not a member? ",
                        style: TextStyle(color: Colors.white54)),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Register now",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white), // Update color
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
