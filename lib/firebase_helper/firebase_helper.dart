import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireHelper {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final CollectionReference userDataRef =
      FirebaseFirestore.instance.collection('user');

  User? get user => auth.currentUser;


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

      final data = {
        'Email': email,
        'Name': name,
      };

      await userDataRef.doc(response.user?.uid).set(data);

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred: ${e.toString()}";
    }
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
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print("Sign out error: $e");
    }
  }
}