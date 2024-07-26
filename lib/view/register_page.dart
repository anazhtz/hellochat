import 'package:flutter/material.dart';
import 'package:hellochat/components/custome_textfield.dart';
import 'package:hellochat/components/my_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: SingleChildScrollView(
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
                  "Lets create an account for you",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary, fontSize: 16),
                ),
                const SizedBox(
                  height: 25,
                ),
                //name
                CustomeTextfield(
                  controller: emailController,
                  obscureText: false,
                  hintText: "Name",
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
                  obscureText: false,
                  hintText: "Password",
                ),
                //confrm pass
                const SizedBox(
                  height: 25,
                ),
                 CustomeTextfield(
                  controller: passwordController,
                  obscureText: true,
                  hintText: "Confirm password",
                ),
                const SizedBox(
                  height: 25,
                ),
                //login button
                MyButton(
                  text: 'Register',
                  onTap: () {},
                ),
                const SizedBox(
                  height: 25,
                ),
                    Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an member? ",style: TextStyle(color: Theme.of(context).colorScheme.primary),),
                const Text("Login now",style: TextStyle(
                  fontWeight: FontWeight.bold
                ),)
              ],
            )
              
              ],
            ),
          ),
        ));
  }
}
