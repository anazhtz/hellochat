import 'package:flutter/material.dart';

class CustomeTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;

  const CustomeTextfield({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.validator, this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        focusNode: focusNode,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary), // Update border color
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary), // Update border color
          ),
          fillColor: Theme.of(context).colorScheme.secondary, // Update fill color
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary), // Update hint text color
        ),
        validator: validator,
      ),
    );
  }
}
