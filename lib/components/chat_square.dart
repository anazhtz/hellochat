import 'package:flutter/material.dart';
import 'package:hellochat/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class ChatSquare extends StatelessWidget {
  final String message;
  final bool isCurrentUser;

  const ChatSquare(
      {super.key, required this.message, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    Color backgroundColor;
    Color textColor;

    if (isCurrentUser) {
      backgroundColor =
          isDarkMode ? Colors.green.shade600 : Colors.grey.shade500;
      textColor = Colors.white;
    } else {
      backgroundColor =
          isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
      textColor = isDarkMode ? Colors.white : Colors.black;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor,
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
      child: Text(
        message,
        style: TextStyle(color: textColor),
      ),
    );
  }
}
