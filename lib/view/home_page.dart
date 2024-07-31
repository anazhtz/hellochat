import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hellochat/components/my_drawer.dart';
import 'package:hellochat/components/user_tile.dart';
import 'package:hellochat/firebase_helper/firebase_helper.dart';
import 'package:hellochat/services/chat_services/chat_service.dart';
import 'chat_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // Chat and auth service
  final ChatService _chatService = ChatService();
  final FireHelper _fireHelper = FireHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "U S E R S",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: const MyDrawer(),
      body: _buildUserList(),
    );
  }

  // Build a list of users except the current logged-in user
  Widget _buildUserList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        // Error handling
        if (snapshot.hasError) {
          return const Text("Error");
        }
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading..");
        }
        // Check if data is null
        final data = snapshot.data;
        if (data == null) {
          return const Text("No data available");
        }
        // Return list view
        return ListView(
          children: data
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  // Build individual list tile for user
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
        print( userData["UID"]);
    final email = userData["Email"] as String?;

    if (email == null) {
      return const SizedBox();
    }

    final currentUserEmail = _fireHelper.currentUser?.email;

    if (email != currentUserEmail) {
      return UserTile(
        text: email,
        onTap: () {
          Get.to(() => ChatPage(
                receiverEmail: email,
                receiverID:
                    userData['UID'] ,
              ));
        },
      );
    } else {
      return Container();
    }
  }
}
