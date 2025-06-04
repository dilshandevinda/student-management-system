// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginAuth {
  Future<String?> login(String emailOrUsername, String password) async {
    try {
      // Try to sign in with email
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailOrUsername,
        password: password,
      );

      // If successful, fetch user role
      print("Login successful with email: ${userCredential.user!.email}");
      return await _fetchUserRole(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        // If login with email fails, try with username
        try {
          // Fetch user's email using username
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: emailOrUsername)
              .limit(1)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            String email = querySnapshot.docs.first.get('email');

            // Sign in with the fetched email
            UserCredential userCredential =
                await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: password,
            );

            print("Login successful with username: $emailOrUsername");
            return await _fetchUserRole(userCredential.user!.uid);
          } else {
            print('No user found with that username.');
            return null;
          }
        } on FirebaseAuthException catch (e) {
          print('Error during login with username: ${e.message}');
          return null;
        }
      } else {
        print('Error during login with email: ${e.message}');
        return null;
      }
    }
  }

  Future<String?> _fetchUserRole(String uid) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      String role = userDoc.get('role');
      print("User role: $role");
      return role;
    } else {
      print("User data not found in Firestore.");
      return null;
    }
  }
}
