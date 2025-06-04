// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterAuth {
  Future<bool> register(
    String name,
    String email,
    String username,
    String index,
    String contact,
    String role,
    String password, // Add password parameter
  ) async {
    try {
      // Create User in Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password, // Use the provided password
      );

      // Get User ID
      String uid = userCredential.user!.uid;

      // Add user data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'username': username,
        'index': index,
        'contact': contact,
        'role': role,
        'uid': uid, // Add the UID here for reference
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("Registration successful!");
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      } else {
        print(
            "FirebaseAuthException during registration: ${e.code}: ${e.message}");
      }
      return false;
    } catch (e) {
      print("Error during registration: $e");
      return false;
    }
  }
}
