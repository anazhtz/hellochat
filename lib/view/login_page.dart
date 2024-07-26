import 'package:flutter/material.dart';
import 'package:hellochat/components/custome_textfield.dart';
import 'package:hellochat/components/my_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

   final TextEditingController emailController = TextEditingController();
   final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //logo
            Icon(
              Icons.message,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(
              height: 50,
            ),
            //welcomeback message
            Text(
              "Welcome back, you've been missed",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary, fontSize: 16),
            ),
            const SizedBox(
              height: 25,
            ),
            //email textfield
             CustomeTextfield(
              controller: emailController,
              obscureText: false,
              hintText: "Email",
            ),
            const SizedBox(
              height: 25,
            ),
            //pw textfield
             CustomeTextfield(
              controller: passwordController,
              obscureText: true,
              hintText: "Password",
            ),
             const SizedBox(
              height: 25,
            ),
            //login button
            MyButton(text: 'Login',
            onTap: () {
              
            },
            ),
             const SizedBox(
              height: 25,
            ),
            //register now
             Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Not a member? ",style: TextStyle(color: Theme.of(context).colorScheme.primary),),
                const Text("Register now",style: TextStyle(
                  fontWeight: FontWeight.bold
                ),)
              ],
            )
          ],
        ),
      ),
    );
  }
}
