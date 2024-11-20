import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireHelper {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final CollectionReference userDataRef =
      FirebaseFirestore.instance.collection('user');

  User? get currentUser => auth.currentUser;

   Future<void> updateOnlineStatus(bool isOnline) async {
    final user = auth.currentUser;
    if (user != null) {
      await userDataRef.doc(user.uid).update({'isOnline': isOnline});
    }
  }


  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential response = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = response.user?.uid; 
      if (uid == null) {
        return "User ID is null";
      }

      final data = {
        'UID': uid, 
        'Email': email,
        'Name': name,
      };

      await userDataRef.doc(uid).set(data);

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred: ${e.toString()}";
    }
  }
   Future<String> getUserName() async {
    final user = auth.currentUser;
    if (user != null) {
      final doc = await userDataRef.doc(user.uid).get();
      final data = doc.data() as Map<String, dynamic>?;
      return data?['Name'] ?? 'User';
    }
    return 'User';
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      print("Sign out error: $e");
    }
  }
}
//aa