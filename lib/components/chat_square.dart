import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:hellochat/services/chat_services/chat_service.dart';
import 'package:hellochat/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class ChatSquare extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String messageId;
  final String userID;
  final Timestamp timestamp; // Add Timestamp field

  const ChatSquare({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.messageId,
    required this.userID,
    required this.timestamp, // Add Timestamp parameter
  });

  // Show options
  void _showOptions(BuildContext context, String messageId, String userID) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text("Report message"),
                onTap: () {
                  Navigator.pop(context);
                  _reportMessage(context, messageId, userID);
                },
              ),
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text("Block User"),
                onTap: () {
                  Navigator.pop(context);
                  _blockUser(context, userID);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text("Cancel"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
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

  // Block user
  void _blockUser(BuildContext context, String userID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Block User"),
        content: const Text("Are you sure you want to block this user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              ChatService().blockUser(userID);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("User Blocked")),
              );
            },
            child: const Text("Block"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    Color backgroundColor;
    Color textColor;
    Color timeColor;

    if (isCurrentUser) {
      backgroundColor =
          isDarkMode ? Colors.green.shade600 : Colors.grey.shade500;
      textColor = Colors.white;
      timeColor = isDarkMode ? Colors.white70 : Colors.black54;
    } else {
      backgroundColor =
          isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
      textColor = isDarkMode ? Colors.white : Colors.black;
      timeColor = isDarkMode ? Colors.white70 : Colors.black54;
    }

    // Format the timestamp
    String formattedTime = DateFormat('hh:mm a').format(timestamp.toDate());

    return GestureDetector(
      onLongPress: () {
        if (!isCurrentUser) {
          // Show options
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
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 4), 
            Text(
              formattedTime,
              style: TextStyle(
                color: timeColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
