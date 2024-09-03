import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hellochat/components/appcolor.dart';
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
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FireHelper _fireHelper = FireHelper();
  FocusNode myFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  String? receiverName;

  @override
  void initState() {
    super.initState();
    _fetchReceiverName();
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

  Future<void> _fetchReceiverName() async {
    final userData = await _fireHelper.userDataRef.doc(widget.receiverID).get();
    if (userData.exists) {
      setState(() {
        receiverName = userData['Name'] ?? widget.receiverEmail;
      });
    }
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
        title: Text(
          receiverName ?? widget.receiverEmail,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clearChat') {
                _clearChat();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'clearChat',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Text('Clear Chat'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildUserInput(),
        ],
      ),
    );
  }

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
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No messages"));
        }

        return ListView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          children: snapshot.data!.docs.map((doc) {
            final data =
                doc.data() as Map<String, dynamic>?;
            if (data == null) {
              return const SizedBox();
            }
            return _buildMessageItem(data, doc.id);
          }).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> data, String messageId) {
    bool isCurrentUser = data['senderID'] == _fireHelper.currentUser?.uid;
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    Timestamp timestamp = data['timestamp'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: alignment,
        child: Column(
          crossAxisAlignment: isCurrentUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            ChatSquare(
              message: data["message"],
              isCurrentUser: isCurrentUser,
              messageId: messageId,
              userID: data["senderID"],
              timestamp: timestamp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: CustomeTextfield(
              controller: _messageController,
              hintText: "Type a message...",
              obscureText: false,
              focusNode: myFocusNode,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
