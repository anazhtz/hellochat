import 'package:flutter/material.dart';
import 'package:hellochat/components/user_tile.dart';
import 'package:hellochat/firebase_helper/firebase_helper.dart';
import 'package:hellochat/services/chat_services/chat_service.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  _BlockedUsersPageState createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  // Chat and auth service
  final ChatService _chatService = ChatService();
  final FireHelper _fireHelper = FireHelper();

  void _showUnblockBox(BuildContext context, String userID) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Unblock user"),
              content:
                  const Text("Are you sure you want to unblock this user?"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: () {
                      _chatService.unblockUser(userID).then((_) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User unblocked!")));
                        setState(() {}); // Trigger a rebuild to reflect the changes
                      });
                    },
                    child: const Text("Unblock")),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.getBlockedUsersStream(),
        builder: (context, snapshot) {
          // Error
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error loading.."),
            );
          }

          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Loading complete
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No blocked users"),
            );
          }

          final blockedUsers = snapshot.data ?? [];

          // Data loaded
          return ListView.builder(
            itemCount: blockedUsers.length,
            itemBuilder: (context, index) {
              final user = blockedUsers[index];
              return UserTile(
                text: user["Email"],
                onTap: () => _showUnblockBox(context, user['UID']),
              );
            },
          );
        },
      ),
    );
  }
}
