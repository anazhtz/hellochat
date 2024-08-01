import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hellochat/components/chat_square.dart';
import 'package:hellochat/services/chat_services/chat_service.dart';
import '../components/custome_textfield.dart';
import '../firebase_helper/firebase_helper.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  const ChatPage(
      {super.key, required this.receiverEmail, required this.receiverID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Text controller
  final TextEditingController _messageController = TextEditingController();

  // Chat and auth services
  final ChatService _chatService = ChatService();
  final FireHelper _fireHelper = FireHelper();

  // For text field focus
  FocusNode myFocusNode = FocusNode();

  // Scroll controller
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Delay scroll operation until after the widget has been built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollDown();
    });

    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_scrollController.hasClients) {
            scrollDown();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Send message
  Future<void> sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverID, _messageController.text);
      _messageController.clear();
      scrollDown();
    }
  }

  void scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear Chat"),
        content: const Text("Are you sure you want to clear this chat?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await _chatService.clearChat(widget.receiverID);
              Navigator.pop(context);
            },
            child: const Text("Clear"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverEmail),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clearChat') {
                _clearChat();
              }
              // Handle other menu options here
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'clearChat',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever),
                      SizedBox(width: 8),
                      Text('Clear Chat'),
                    ],
                  ),
                ),
                // Add other menu items here if needed
              ];
            },
          ),
        ],
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
      return const Center(child: Text("No user found"));
    }

    String senderID = currentUser.uid;
    String receiverID = widget.receiverID;

    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(senderID, receiverID),
      builder: (context, snapshot) {
        // Error
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text("Loading..."));
        }

        // No data
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No messages"));
        }

        // Build list view
        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs.map((doc) {
            final data =
                doc.data() as Map<String, dynamic>?; // Handle null data
            if (data == null) {
              return const SizedBox();
            }
            return _buildMessageItem(data, doc.id); // Pass doc.id as messageId
          }).toList(),
        );
      },
    );
  }

  // Build message item
  Widget _buildMessageItem(Map<String, dynamic> data, String messageId) {
  bool isCurrentUser = data['senderID'] == _fireHelper.currentUser?.uid;
  var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

  // Get the timestamp
  Timestamp timestamp = data['timestamp'];

  return ListTile(
    title: Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatSquare(
            message: data["message"],
            isCurrentUser: isCurrentUser,
            messageId: messageId,
            userID: data["senderID"],
            timestamp: timestamp, // Pass the timestamp here
          ),
        ],
      ),
    ),
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
            focusNode: myFocusNode,
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.arrow_upward, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
