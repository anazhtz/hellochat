import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hellochat/components/appcolor.dart';
import 'package:hellochat/components/custome_textfield.dart';
import 'package:hellochat/components/my_button.dart';
import 'package:hellochat/firebase_helper/firebase_helper.dart';
import 'package:hellochat/view/login_page.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> _handleRegistration() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      formKey.currentState!.save();
      String? errorMessage = await FireHelper().signUp(
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text,
      );

      setState(() {
        isLoading = false;
      });

      if (errorMessage == null) {
        Get.snackbar(
          "Success",
          "Registration successful!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        await Future.delayed(const Duration(seconds: 1));
        Get.to(() => const LoginPage());
      } else {
        Get.snackbar(
          "Error",
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
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
                const SizedBox(
                  height: 50,
                ),
                //welcome message
                const Text(
                  "Let's create an account for you",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 25,
                ),
                //name
                CustomeTextfield(
                  controller: nameController,
                  obscureText: false,
                  hintText: "Name",
                  validator: (value) => value != null && value.isNotEmpty
                      ? null
                      : 'Please enter your name',
                ),
                const SizedBox(
                  height: 25,
                ),
                //email textfield
                CustomeTextfield(
                  controller: emailController,
                  obscureText: false,
                  hintText: "Email",
                  validator: _validateEmail,
                ),
                const SizedBox(
                  height: 25,
                ),
                //password textfield
                CustomeTextfield(
                  controller: passwordController,
                  obscureText: false,
                  hintText: "Password",
                  validator: _validatePassword,
                ),
                const SizedBox(
                  height: 25,
                ),
                //confirm password textfield
                CustomeTextfield(
                  controller: confirmPasswordController,
                  obscureText: true,
                  hintText: "Confirm password",
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(
                  height: 25,
                ),
                //register button
                MyButton(
                  text: 'Register',
                  onTap: _handleRegistration,
                  isLoading: isLoading,
                ),

                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.white54),
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Login now",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
