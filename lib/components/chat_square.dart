import 'package:flutter/material.dart';

class ChatSquare extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  const ChatSquare(
      {super.key, required this.message, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isCurrentUser ? Colors.green : Colors.grey.shade500,
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
