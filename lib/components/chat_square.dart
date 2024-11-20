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
  final Timestamp timestamp;
  
  const ChatSquare({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.messageId,
    required this.userID,
    required this.timestamp,
  });

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

    if (isCurrentUser) {
      backgroundColor = isDarkMode
          ? Colors.lightBlue.shade300
          : Colors.grey.shade300;
      textColor = Colors.black;
    } else {
      backgroundColor = isDarkMode
          ? Colors.deepPurple.shade200
          : Colors.white;
      textColor = isDarkMode ? Colors.black : Colors.black;
    }

    String formattedTime = DateFormat('hh:mm a').format(timestamp.toDate());

    return GestureDetector(
      onLongPress: () {
        if (!isCurrentUser) {
          _showOptions(context, messageId, userID);
        }
      },
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isCurrentUser)
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                    'https://img.freepik.com/premium-vector/vector-professional-icon-business-illustration-line-symbol-people-management-career-set-c_1013341-74706.jpg'),
              ),
            if (!isCurrentUser) const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(15),
                margin: isCurrentUser
                    ? const EdgeInsets.only(bottom: 10, left: 50)
                    : const EdgeInsets.only(bottom: 10, right: 50),
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: isCurrentUser
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        )
                      : const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                  border: Border.all(color: Colors.blue.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: isCurrentUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: TextStyle(color: textColor,fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        color: isCurrentUser ? Colors.black54 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isCurrentUser) const SizedBox(width: 10),
            if (isCurrentUser)
              const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                      'https://img.freepik.com/premium-vector/vector-professional-icon-business-illustration-line-symbol-people-management-career-set-c_1013341-74706.jpg')),
          ],
        ),
      ),
    );
  }
}
