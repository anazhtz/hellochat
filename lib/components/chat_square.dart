import 'package:flutter/material.dart';
import 'package:hellochat/services/chat_services/chat_service.dart';
import 'package:hellochat/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class ChatSquare extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String messageId;
  final String userID;

  const ChatSquare(
      {super.key,
      required this.message,
      required this.isCurrentUser,
      required this.messageId,
      required this.userID});

  //show options
  void _showOptions(BuildContext context, String messageId, String userID) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
              child: Wrap(
            children: [
              //report message button
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text("Report message"),
                onTap: () {
                  Navigator.pop(context);
                  _reportMessage(context, messageId, userID);
                },
              ),
              //block user button
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text("Block User"),
                onTap: () {},
              ),
              //cancel
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text("Cancel"),
                onTap: () {},
              ),
            ],
          ));
        });
  }

// Report message
  void _reportMessage(BuildContext context, String messageId, String userID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Report Message"),
        content: const Text("Are you sure you want to report the message?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          //report button
          TextButton(
            onPressed: () {
              ChatService().reportUser(messageId, userID);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Message Reported")),
              );
            },
            child: const Text("Report"),
          ),
        ],
      ),
    );
  }

  //blocked user

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

    return GestureDetector(
      onLongPress: () {
        if (!isCurrentUser) {
          //show options
          _showOptions(context, messageId, userID);
        }
      },
      child: Container(
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
      ),
    );
  }
}
