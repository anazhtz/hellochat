import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hellochat/components/chat_square.dart';
import 'package:hellochat/services/chat_services/chat_service.dart';
import '../components/custome_textfield.dart';
import '../firebase_helper/firebase_helper.dart';

class ChatPage extends StatelessWidget {
  final String receiverEmail;
  final String receiverID;
  
  ChatPage({super.key, required this.receiverEmail, required this.receiverID}) {
    // Debug prints to check the values passed to the constructor
    print("Receiver Email: $receiverEmail");
    print("Receiver ID: $receiverID");
  }

  // Text controller
  final TextEditingController _messageController = TextEditingController();

  // Chat and auth services
  final ChatService _chatService = ChatService();
  final FireHelper _fireHelper = FireHelper();

  // Send message
  Future<void> sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(receiverID, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receiverEmail),
      ),
      body: Column(
        children: [
          // Display all messages
          Expanded(
            child: _buildMessageList(),
          ),
          // User input
          _buildUserInput(),
        ],
      ),
    );
  }

  // Build message list
  Widget _buildMessageList() {
    final currentUser = _fireHelper.currentUser;
    if (currentUser == null) {
      return Center(child: Text("No user found"));
    }

    String senderID = currentUser.uid;
    String receiverID = this.receiverID;

    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(senderID, receiverID),
      builder: (context, snapshot) {
        // Error
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text("Loading..."));
        }

        // No data
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No messages"));
        }

        // Build list view
        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final data =
                doc.data() as Map<String, dynamic>?; // Handle null data
            if (data == null) {
              return SizedBox(); // Handle null data gracefully
            }
            return _buildMessageItem(data);
          }).toList(),
        );
      },
    );
  }

  // Build message item
  Widget _buildMessageItem(Map<String, dynamic> data) {

    //is current user 
   bool isCurrentUser = data['senderID'] == _fireHelper.currentUser?.uid;
    //align message to the right if sender is the current user , otherwise left 
    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return ListTile(
      title: Container(
        alignment: alignment,
        child: Column(
          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            ChatSquare(message: data["message"], isCurrentUser: isCurrentUser)
          ],
        )), // Handle null message
    );
  }

  // Message input
  Widget _buildUserInput() {
    return Row(
      children: [
        Expanded(
          child: CustomeTextfield(
            controller: _messageController,
            hintText: "Type a message",
            obscureText: false,
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.arrow_upward,color: Colors.white,),
          ),
        ),
      ],
    );
  }
}
