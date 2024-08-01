import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hellochat/models/message.dart';

class ChatService {
  // Get instance of Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // GET ALL USERS
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('user').snapshots().map((snapshot) {
      snapshot.docs.forEach((doc) {
        // Handle any necessary debug information or processing
      });

      // Map snapshot data to a list of maps
      return snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    });
  }

  // GET ALL USERS STREAM EXCEPT BLOCKED USERS
  Stream<List<Map<String, dynamic>>> getUsersStreamExcludingBlocked() {
    final currentUser = _auth.currentUser;
    return _firestore
        .collection('user')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
      // Get blocked user IDs
      final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();

      // Get all users
      final usersSnapshot = await _firestore.collection('user').get();

      // Return as a stream list, excluding current user and blocked users
      return usersSnapshot.docs
          .where((doc) =>
              doc.data()['Email'] != currentUser.email &&
              !blockedUserIds.contains(doc.id))
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> sendMessage(String receiverID, String message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  // GET MESSAGES
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false) // Order by timestamp
        .snapshots();
  }

  // REPORT USER
  Future<void> reportUser(String messageId, String userID) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final report = {
      'reportedBy': currentUser.uid,
      'messageId': messageId,
      'messageOwnerId': userID,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('Reports').add(report);
  }

  // BLOCK USER
  Future<void> blockUser(String userID) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore
        .collection('user') // Correct the collection name if needed
        .doc(currentUser.uid)
        .collection('BlockedUsers') // Correct the collection name if needed
        .doc(userID)
        .set({
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // UNBLOCK USER
  Future<void> unblockUser(String userID) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore
        .collection('user') // Correct the collection name if needed
        .doc(currentUser.uid)
        .collection('BlockedUsers') // Correct the collection name if needed
        .doc(userID)
        .delete();
  }

  // GET BLOCKED USERS STREAM
  Stream<List<Map<String, dynamic>>> getBlockedUsersStream() async* {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      yield [];
      return;
    }

    // Fetch blocked users
    final blockedUsersSnapshot = await _firestore
        .collection('user') // Correct the collection name if needed
        .doc(currentUser.uid)
        .collection('BlockedUsers') // Correct the collection name if needed
        .get();

    final blockedUserIds =
        blockedUsersSnapshot.docs.map((doc) => doc.id).toList();

    // Fetch user details
    final userDocs = await Future.wait(blockedUserIds
        .map((id) => _firestore.collection('user').doc(id).get()));

    // Map user details to a list of maps
    final blockedUsers = userDocs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();

    yield blockedUsers;
  }

  // CLEAR CHAT
  Future<void> clearChat(String receiverID) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final senderID = currentUser.uid;

    // Construct chat room ID
    List<String> ids = [senderID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    // Delete messages in both directions
    final batch = _firestore.batch();

    // Messages from sender to receiver
    final senderToReceiverMessages = _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .get();
    final senderToReceiverDocs = await senderToReceiverMessages;
    for (var doc in senderToReceiverDocs.docs) {
      batch.delete(doc.reference);
    }

    // Messages from receiver to sender
    final receiverToSenderMessages = _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .get();
    final receiverToSenderDocs = await receiverToSenderMessages;
    for (var doc in receiverToSenderDocs.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
